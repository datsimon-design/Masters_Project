library(tidyverse)
library(readxl)
library(lubridate)
library(sf)
library(ggspatial)

source("./utils.R")


detection <- read_excel(path = "./data/datasheet_complete.xlsx", sheet = "detection_log")

effort_log <- read_excel(path = "./data/datasheet_complete.xlsx", sheet = "effort_log")

gps_wps <- st_read("./data/GIS/2026_05_08/Waypoints_08-MAY-26.gpx", layer = "waypoints")

#### QC
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


# Join and mutate data
data <- detection %>% 
  # Join dataframes
  left_join(effort_log, by = "transect_id") %>% 
  
  # Convert times to HH:MM
   mutate(across(c(start_time, end_time, time_off_effort, time_on_effort, departure, arrival),
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
  )

  # Calculate sighting POIs

  # Calculate perpendicular distance
  
  
 

data %>% 
  mutate(bino_dis = calculate_distance_bino(reticles = reticles, height = observer_height)) %>% 
  mutate(incl_dis = calculate_distance_inclino(angle = vert_angle, height = observer_height)) %>% 
  select(reticles, bino_dis, vert_angle, incl_dis)


gps_wps %>% 
  mutate(name = as.double(name)) %>% 
  select(name,geometry)


data %>%
  rowwise() %>%
  mutate(sighting_poi = list(calculate_sighting(
    location = geometry,
    bearing  = horizontal_bearing,
    distance = distance
  ))) %>%
  select(POI, distance,  sighting_poi)
