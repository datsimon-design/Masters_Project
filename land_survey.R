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
coast_spots <- c("WestSide", "PrinceGeorge")


# Convert to sf
effort_log <- st_as_sf(effort_log, coords = c("lon", "lat"), crs = 4326)


data <- detection %>% 
  # Join dataframes
  left_join(effort_log, by = "survey_id") %>% 
  
  # Convert times to HH:MM
  mutate(across(c(start_time, observation_start, observation_end),
                ~ hms::as_hms(.))) %>% 
  
  
  # Convert dates to dates instead of chr
  mutate(across(c(date.x, date.y),
                ~ dmy(.)))  %>% 
  
  # Convert NA species to unidentified
  mutate(species = replace_na(species, "unidentified")) %>% 
  
  
  # Convert to boolean
  mutate(across(c(on_effort, bird_presence, fish_presence),
                ~ as.logical(.))) %>% 
  
  # Create Clean spot name
  mutate(
    spot_clean = case_when(
      spot_name == "Europa" ~ "Europa Point",
      spot_name == "SandyBay" ~ "Sandy Bay",
      spot_name == "PrinceGeorge" ~ "Prince George",
      TRUE ~ spot_name
      
    )
  ) %>% 
  
  
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




