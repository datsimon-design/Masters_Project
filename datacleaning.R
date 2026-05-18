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
  geom_sf(data = data$incl_poi) +
  geom_sf(data = data$bino_poi)

data %>% 
  mutate(perp_dis = st_distance(
    sighting_poi, gps_track
  )) %>% 
  select(perp_dis)



data %>% 
  ggplot() +
  geom_sf(data = data$sighting_poi, aes(colour = data$species), size = 3) +
  facet_wrap(~ data$sector)

data %>% 
  ggplot() +
  geom_histogram(aes(x = distance), binwidth = 10)


gps_track_points %>% 
  ggplot() +
  geom_sf(aes(fill = ele))
