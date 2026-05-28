library(tidyverse)
library(readxl)
library(lubridate)
library(sf)
library(ggspatial)
library(osmdata)


source("./utils.R")

detection <- read_excel(path = "./data/datasheet_landsurvey.xlsx", sheet = "detection_log")

effort_log <- read_excel(path = "./data/datasheet_landsurvey.xlsx", sheet = "effort_log")

gibraltar <- st_read("./data/gib.gpkg")

# Convert to sf
effort_log <- st_as_sf(effort_log, coords = c("lon", "lat"), crs = 4326)


data <- detection %>% 
  # Join dataframes
  left_join(effort_log, by = "survey_id") %>% 
  
  # Convert times to HH:MM
  mutate(across(c(start_time, observation_start, observation_end),
                ~ hms::as_hms(.))) %>% 
  
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





data %>% 
  ggplot() +
  geom_sf(data = gibraltar, fill = "lightgray", alpha = .8) + 
  geom_sf(data = data$geometry) +
  geom_sf(data = data$sighting_poi, color = "blue", size = 3)+
  annotate()
  coord_sf(
    ylim = c(36.115, 36.10),
    xlim = c(-5.355, -5.335)
  ) +
  theme_minimal()
