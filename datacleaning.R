library(tidyverse)
library(readxl)
library(lubridate)

source("./utils.R")


detection <- read_excel(path = "./data/datasheet_complete.xlsx", sheet = "detection_log")

effort_log <- read_excel(path = "./data/datasheet_complete.xlsx", sheet = "effort_log")

# QC
stopifnot(
  "❗ Missing start time" = !any(is.na(detection$start_time)),
  "❗ Missing date" = !any(is.na(detection$date)),
  "❗ Missing transect ID" = !any(is.na(detection$transect_id))
)

cat("✅ Quality control checked!")


data <- detection %>% 
  # Join dataframes
  left_join(effort_log, by = "transect_id") %>% 
  
  # Convert times to HH:MM
   mutate(across(c(start_time, end_time, time_off_effort, time_on_effort, departure, arrival),
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
    )
  )
 

data %>% 
  mutate(bino_dis = calculate_distance_bino(reticles = reticles, height = observer_height)) %>% 
  mutate(incl_dis = calculate_distance_inclino(angle = vert_angle, height = observer_height)) %>% 
  select(reticles, bino_dis, vert_angle, incl_dis)





