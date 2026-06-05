library(tidyverse)
library(readxl)
library(lubridate)
library(sf)
library(ggspatial)
library(osmdata)
library(ggforce)
library(gt)


source("./utils.R")

detection <- read_excel(path = "./data/datasheet_landsurvey.xlsx", sheet = "detection_log")

effort_log <- read_excel(path = "./data/datasheet_landsurvey.xlsx", sheet = "effort_log")

coast <- st_read("./data/bayofalgib.gpkg")

# Spots that cover the bay of Gibraltar
coast_spots <- c("WestSide")


# Convert to sf
effort_log <- st_as_sf(effort_log, coords = c("lon", "lat"), crs = 4326)


data <- detection %>% 
  # Join dataframes
  left_join(effort_log, by = "survey_id") %>% 
  
  # Convert times to HH:MM
  mutate(across(c(start_time, observation_start, observation_end),
                ~ hms::as_hms(.))) %>% 
  
  
  # Convert to boolean
  mutate(across(c(on_effort, bird_presence, fish_presence),
                ~ as.logical(.))) %>% 
  
  
  # Calculate distance first check if Westside to account for coastline
  mutate(ref_distance = pmap_dbl(
    list(spot_name, geometry, horizontal_bearing),
    function(sp, obs, bg) {
      if (!sp %in% coast_spots) return(NA_real_)
      coast_distance(obs, bg, coast)
    })) %>%
  
  # Then use rest 
  mutate(
    distance = case_when(
      !is.na(reticles) ~ calculate_distance_bino(reticles = reticles, height = observer_height, ref_distance = ref_distance), # If reticles available reticles will be used to calculate distance
      !is.na(vert_angle) ~ calculate_distance_inclino(angle = vert_angle, height = observer_height),
      TRUE ~ NA_real_
    ) ) %>% 
  mutate(
    method_used = case_when(
      !is.na(reticles) ~ "reticle", 
      !is.na(vert_angle) ~ "angle",
      TRUE ~ "missing"
    )) %>% 
  
  
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

write.table(data, file = "./data/datasheet_cleaned.csv", sep = ";", col.names = NA,
            qmethod = "double")


spot_label <- data %>% 
  select(spot_name, geometry, observer_height) %>% 
  mutate(y_nudge = case_when(
    spot_name == "SandyBay" ~ 0.003,
    spot_name == "Europa" ~ 0.003,
    spot_name == "WestSide" ~ 0.003,
    
    TRUE ~ - 0.003),
    
    x_nudge = case_when(
      spot_name == "WestSide" ~ -0.002,
      spot_name == "MedSteps" ~ 0.002,
      
      TRUE ~ 0
    )
  )


sightings <- data %>%
  ggplot() +
  geom_sf(data = gibraltar, fill = "lightgray", alpha = .8) +
  geom_sf(data = st_set_geometry(data, "geometry")) +   # Set geometry so aes does not missalign
  #geom_sf(data = sectors, aes(fill = name), colour = "black", alpha = 0.4) +
  geom_sf(data = st_set_geometry(data, "sighting_poi"),
          aes(color = spot_name), size = 3) +
  geom_sf_label(data = st_set_geometry(data, "geometry"),
               aes(label = spot_name), size = 2, nudge_y = spot_label$y_nudge) +
  geom_sf_text(data = st_set_geometry(data, "sighting_poi"),
              aes(label = species), size = 3, nudge_y = -0.003) +
  
  # coord_sf(
  #   xlim = c(-5.44, -5.25),
  #   ylim = c(36.05, 36.2)
  # ) +
  labs(color = "Spots") +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "transparent", colour = NA),
    panel.background = element_rect(fill = "transparent", colour = NA),
    legend.box.background = element_rect(fill = "transparent"),
    legend.background = element_rect(fill = "transparent", colour = NA)
  )

sightings

st_distance(data$sighting_poi, data$geometry)

data %>% 
  select(spot_name, distance, species, group_size, observer_height)




## Add sectors to the map ---------------

# Pie wedge as an sf polygon. Radius in metres.
# Bearings in degrees, clockwise from north (compass convention).
make_wedge <- function(x0, y0, r, start, end, crs, n = 120) {
  b   <- seq(start, end, length.out = n) * pi / 180
  pts <- cbind(x0 + r * sin(b), y0 + r * cos(b))   # compass: x=sin, y=cos
  ring <- rbind(c(x0, y0), pts, c(x0, y0))         # close through the centre
  st_sfc(st_polygon(list(ring)), crs = crs)
}

proj <- 32630   # UTM zone 30N — metres, correct for Gibraltar

centres <- data.frame(
  name  = c("Europa", "MedSteps", "WestSide", "SandyBay"),
  lon   = c(-5.345641859, -5.342792071, -5.346930922, -5.34272596),
  lat   = c(36.10935173, 36.12133795, 36.12221254, 36.13006488),
  start = c(60, 33, 210, 16),
  end   = c(220, 161, 315, 155),
  r_m   = c(10000, 10000, 10000, 8000)        # radius in METRES now, not degrees
)

# project the centres into metres
xy <- st_coordinates(
  st_transform(st_as_sf(centres, coords = c("lon", "lat"), crs = 4326), proj)
)

sectors <- do.call(rbind, lapply(seq_len(nrow(centres)), function(i) {
  g <- make_wedge(xy[i, 1], xy[i, 2], centres$r_m[i],
                  centres$start[i], centres$end[i], crs = proj)
  st_sf(name = centres$name[i], geometry = g)
}))

sectors <- st_transform(sectors, 4326)   # back to lon/lat for the map


# Sector map
sector_map <- ggplot() +
  geom_sf(data = gibraltar) +
  geom_sf(data = sectors, aes(fill = name), colour = "black", alpha = 0.4) +
  geom_sf(data = data$geometry,  colour = "black", alpha = 0.4) +
  # coord_sf(
  #   ylim = c(36.149, 36.08)
  # ) +
  
  labs(fill = "Sectors") +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "transparent", colour = NA),
    panel.background = element_rect(fill = "transparent", colour = NA),
    legend.box.background = element_rect(fill = "transparent"),
    legend.background = element_rect(fill = "transparent", colour = NA)
  )

sector_map


# Test compare location of buoy to measured spot ---------------
# Fairway buoy in the middle of the bay


buoy <- st_as_sf(
  data.frame(name = "FairwayBuoy", lat = 36.14954, lon = -5.40154),
  coords = c("lon", "lat"),   # x (lon) first, then y (lat) — order matters
  crs = 4326
)

measurements <- st_as_sf(
  data.frame(
    name               = c("Inclinometer", "Binos"),
    reticles           = c(NA_real_, 1.25),
    vert_angle         = c(0.1, NA_real_),
    observer_height    = c(167, 167),
    horizontal_bearing = c(301, 301),
    lon                = c(-5.346930922, -5.346930922),
    lat                = c(36.12221254, 36.12221254)
  ),                         # <- data.frame() closes here
  coords = c("lon", "lat"),  # <- argument to st_as_sf, not a column
  crs    = 4326
)


measurements <- measurements %>% 
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
    )) %>% 
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


ggplot() +
  geom_sf(data = gibraltar, fill = "lightgray", alpha = .8) +
  geom_sf(data = measurements$sighting_poi, aes(
    color = measurements$method_used
  )) +
  geom_sf(data = buoy) +
  geom_sf_text(data = buoy, 
               aes(label = name), size = 3, nudge_y = 0.005)

st_distance(measurements$sighting_poi, buoy)



ggsave(filename = "sightings.png", sightings, width = 1920, height = 1920, dpi = 200, units = "px")
ggsave(filename = "sector_map.png", sector_map, width = 1920, height = 1920, dpi = 200, units = "px")


data %>% 
  group_by(species) %>% 
  summarise(n_sightings = n())

