library(tidyverse)
library(readxl)
library(lubridate)
library(sf)
library(ggspatial)

source("./utils.R")


detection <- read_excel(path = "./data/datasheet_complete.xlsx", sheet = "detection_log")

effort_log <- read_excel(path = "./data/datasheet_complete.xlsx", sheet = "effort_log")

gps_wps <- st_read("./data/GIS/2026_05_08/Waypoints_08-MAY-26.gpx", layer = "waypoints")

gps_track_points <- st_read("./data/GIS/2026_05_08/Track_A026-05-08 122436.gpx", layer = "track_points")


# QC ---------------------------------------------------
stopifnot(
  "❗ Missing start time" = !any(is.na(detection$start_time)),
  "❗ Missing date" = !any(is.na(detection$date)),
  "❗ Missing transect ID" = !any(is.na(detection$transect_id))
)

if (any(is.na(detection$vert_angle) & is.na(detection$reticles)))
   warning("⚠️  ", sum(is.na(detection$vert_angle) & is.na(detection$reticles)),
     " rows missing both vert_angle AND reticles — distance cannot be calculated for those observations!")

if (any(is.na(detection$POI)))
  warning("⚠️  ", sum(is.na(detection$POI)),
          " rows have missing POIs! Make sure to check if those were recorded!")

cat("✅ Quality control checked!")

Sys.sleep(3)

# Assign transect ID to gpx points
effort_log <- effort_log %>% 
  # Convert times to HH:MM
  mutate(across(c(leg_start,	leg_end),
                ~ hms::as_hms(.)))


# Assign transect ID to gpx points
gps_track_points <- gps_track_points %>%
  mutate(time_hms = hms::as_hms(with_tz(time, "Europe/Gibraltar"))) %>%
  left_join(
    effort_log %>% select(transect_id, leg_start, leg_end),
    by = join_by(between(time_hms, leg_start, leg_end))
  ) %>% 
  mutate(transect_id =
           if_else(NA_real_, "off_effort", transect_id))
  
  




# Join and mutate data -------------------------------------
data <- detection %>% 
  # Join dataframes
  left_join(effort_log, by = "transect_id") %>% 
  
  # Convert times to HH:MM
   mutate(across(c(start_time, end_time, time_off_effort, time_on_effort, leg_start,	leg_end),
                 ~ hms::as_hms(.))) %>% 
  
  # Join gps data
  left_join(gps_wps %>% 
              select(name, geometry) %>% 
              mutate(name = as.double(name)),
            by = c("POI" = "name")) %>% 
  
  # Calculate distance
  mutate(
    distance = case_when(
      !is.na(reticles) ~ calculate_distance_bino(reticles = reticles, height = observer_height), # If reticles available reticles will be used to calculate distance
      !is.na(vert_angle) ~ calculate_distance_inclino(angle = vert_angle, height = observer_height),
      TRUE ~ NA_real_
    ) ) %>% 
  mutate(
    method_used = case_when(
      !is.na(reticles) ~ "reticle", 
      !is.na(vert_angle) ~ "angle",
      TRUE ~ "missing"
    )
  ) %>% 

  # Calculate sighting POIs if nor reticles, inclino available use geometry (POI)
  rowwise() %>%
  mutate(sighting_poi = list(
    if (!is.na(distance)){
      calculate_sighting(
      location = geometry,
      bearing  = horizontal_bearing,
      distance = distance 
  )}else {
    geometry
  } ))    %>% 
  ungroup() %>%
  mutate(sighting_poi = do.call(c, sighting_poi))


  # Calculate perpendicular distance (need to seperate legID)
  

head(data)

Sys.sleep(3)

#-----------------TEST--------------------------------------------------------

data_test <- data %>% 
  mutate(bino_dis = calculate_distance_bino(reticles = reticles, height = observer_height)) %>% 
  mutate(incl_dis = calculate_distance_inclino(angle = vert_angle, height = observer_height)) %>% 
  rowwise() %>%
  mutate(incl_poi = list(calculate_sighting(
    location = geometry,
    bearing  = horizontal_bearing,
    distance = incl_dis
  ))) %>% 
    ungroup() %>%
    mutate(incl_poi = do.call(c, incl_poi)) %>% 
  rowwise() %>%
  mutate(bino_poi = list(calculate_sighting(
    location = geometry,
    bearing  = horizontal_bearing,
    distance = bino_dis
  ))) %>% 
    ungroup() %>%
    mutate(bino_poi = do.call(c, bino_poi)) %>% 
  select(bino_dis, bino_poi, incl_dis, incl_poi)
  

data_test %>% 
  ggplot() +
  geom_sf(data = data_test$incl_poi, color = "red") +
  geom_sf(data = data_test$bino_poi, color = "blue")

data %>% 
  mutate(perp_dis = st_distance(
    sighting_poi, gps_track_points
  )) %>% 
  select(perp_dis)


ggplot() +
  geom_sf(data = gps_track_points, aes(
    color = transect_id
  ))
  geom_sf(data = data$sighting_poi, aes(colour = data$species), size = 3)




data %>% 
  ggplot() +
  geom_histogram(aes(x = distance), binwidth = 50)


gps_track_points %>% 
  ggplot() +
  geom_sf(aes(fill = ele))



library(leaflet)


# Proper sf object
sightings_sf <- st_sf(
  geometry = st_sfc(data$sighting_poi, crs = 4326)
)

# Transform track if needed
gps_track_points <- st_transform(gps_track_points, 4326)

track_line <- gps_track_points %>%
  summarise(do_union = FALSE) %>%
  st_cast("LINESTRING")

# Interactive map
leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  
  addPolylines(
    data = track_line,
    color = "green",
    weight = 2,
    label = "Track"
  ) %>%
  
  addCircleMarkers(
    data = sightings_sf,
    radius = 5,
    color = "red",
    popup = c(data$notes, data$species)
  ) %>%
  
  addScaleBar(position = "bottomleft")


# Compare inclinometer distance to bino distance -------------
angles <- (0:89)

df <- data.frame(
  angle = angles,
  inclino_dis = calculate_distance_inclino(angles, 18)
)

reticles <- seq(0,10, by = 0.5)

bino <- data.frame(
  reticles = reticles,
  bino_dis = calculate_distance_bino(reticles, 18)
)


df %>% 
  ggplot(aes(
    x = angle,
    y = inclino_dis,
    color = "Inclino"
  )) +
  geom_line(aes(color = "Inclino"), alpha = .5) +
  geom_point(alpha = .5, size = 4) +

  geom_line(data = bino, aes(
    x = reticles,
    y = bino_dis,
    color = "Binocular"), alpha = .5) +
  
  geom_point(data = bino, aes(
    x = reticles,
    y = bino_dis,
    color = "Binocular"
  ),  alpha = .5, size = 4) +
  scale_x_continuous(
    limits = c(0,10)
  ) +  
  
  scale_color_manual(
    name = "Method",
    values = c(
      "Inclino" = "black",
      "Binocular" = "darkblue"
    )) +
    
    
  labs(
    x = "Angle / Reticles",
    y = "Distance",
    title = "Inclino vs Binocular Distance"
  ) +
  
  theme_minimal()
  
