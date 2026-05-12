
## Functions


# Pull weather data from open meteo API for land
get_weather <- function(past_days = 1, forecast_days = 0) {
  
  library(httr)
  library(jsonlite)
  
    url <- paste0("https://api.open-meteo.com/v1/forecast?latitude=36.1447&longitude=-5.3526&hourly=temperature_2m,relative_humidity_2m,precipitation,rain,weather_code,visibility,pressure_msl,surface_pressure,cloud_cover,wind_speed_10m,wind_direction_10m,wind_gusts_10m&models=ukmo_seamless&timezone=auto&past_days=",past_days,
    "&forecast_days=", forecast_days)
  
    red <- GET(url)
    
    df <- fromJSON(content(red, "text", encoding = "UTF-8"))
    
    weather_data <<- as.data.frame(df)
    
    summary(weather_data)
    
  
    
  

}

# Pull weather data from open meteo API for marine
get_marine <- function(past_days = 1, forecast_days = 0) {
  
  library(httr)
  library(jsonlite)
  
    url_marine <- paste0("https://marine-api.open-meteo.com/v1/marine?latitude=36.1447&longitude=-5.3526&hourly=wave_height,sea_surface_temperature,sea_level_height_msl,ocean_current_velocity,ocean_current_direction,wave_direction,wave_period,wave_peak_period,wind_wave_height,wind_wave_direction&models=best_match&past_days=", past_days,
  "&forecast_days=", forecast_days)
  
    red_m <- GET(url_marine)
    
    df_ma <- fromJSON(content(red_m, "text", encoding = "UTF-8"))
    
    marine_data <<- as.data.frame(df_ma)
    
    summary(marine_data)
    
  
  
}


# Pull full dataframe and add time and date column
get_full <- function(past_days = 1, forecast_days = 0) {
  library(tidyverse)
  
  # Pull weather data
  url_land <- paste0("https://api.open-meteo.com/v1/forecast?latitude=36.1447&longitude=-5.3526&hourly=temperature_2m,relative_humidity_2m,precipitation,rain,weather_code,visibility,pressure_msl,surface_pressure,cloud_cover,wind_speed_10m,wind_direction_10m,wind_gusts_10m&models=ukmo_seamless&timezone=auto&past_days=",past_days,
                "&forecast_days=", forecast_days)
  
  red <- httr::GET(url_land)
  
  df <- jsonlite::fromJSON(httr::content(red, "text", encoding = "UTF-8"))
  
  weather_data <<- as.data.frame(df)
  
  # Same for marine
  url_marine <- paste0("https://marine-api.open-meteo.com/v1/marine?latitude=36.1447&longitude=-5.3526&hourly=wave_height,sea_surface_temperature,sea_level_height_msl,ocean_current_velocity,ocean_current_direction,wave_direction,wave_period,wave_peak_period,wind_wave_height,wind_wave_direction&models=best_match&past_days=", past_days,
                       "&forecast_days=", forecast_days)
  
  red_m <- httr::GET(url_marine)
  
  df_ma <- jsonlite::fromJSON(httr::content(red_m, "text", encoding = "UTF-8"))
  
  marine_data <<- as.data.frame(df_ma)
  
  
  
  # Join and add date and time
  full_data <<- full_join(marine_data, weather_data, by = "hourly.time") |>
    mutate(
      datetime = lubridate::ymd_hm(hourly.time),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M") 
    )
  
  summary(full_data)

}


# Calculate Distance from inclinometer angle and observer height
calculate_distance_inclino <- function(angle, height) {
  di <- round(height/tan(angle* pi / 180), 2)
  return(di)
}

# Calculate Distance from reticles and observer height; factor needs to be adjusted for each binocular
calculate_distance_bino <- function(reticles, height, factor = 0.05) {
  R <- 6371000  # Earth radius in meters
  
  theta_ret <- reticles * factor
  theta_horizon <- sqrt(2 * height / R)
  
  theta_total <- theta_ret + theta_horizon
  
  db <- round(height / tan(theta_total), 2)
  return(db)
}



## Export gpx for Garmin use

export_transects_gpx <- function(transects, path, name_prefix = NULL) {
  # 1. Pull samplers (sf LINESTRING) and reproject to WGS84.
  #    GPX requires lat/lon in decimal degrees — this is the step
  #    that dssd's write.transects() skips.
  samp <- st_transform(transects@samplers, 4326)
  
  # 2. Collapse legs within each stratum into a MULTILINESTRING.
  #    st_combine (not st_union) keeps legs as separate components,
  #    which GDAL then writes as distinct <trkseg> elements — so the
  #    Garmin won't connect the end of one leg to the start of the next.
  strata_tracks <- samp |>
    group_by(strata) |>
    summarise(geometry = st_combine(geometry), .groups = "drop")
  
  # 3. GPX tracks layer uses the `name` field for the track label
  #    shown on the device. Prefix (e.g. date or seed) is optional.
  strata_tracks$name <- if (is.null(name_prefix)) {
    as.character(strata_tracks$strata)
  } else {
    paste(name_prefix, strata_tracks$strata, sep = "_")
  }
  strata_tracks <- strata_tracks[, "name"]  # drop other fields
  
  # 4. Write. Overwrite if the file already exists.
  if (file.exists(path)) file.remove(path)
  st_write(strata_tracks,
           dsn    = path,
           layer  = "tracks",
           driver = "GPX",
           quiet  = TRUE)
  
  invisible(path)
}

# With a date/seed prefix for daily runs:
# export_transects_gpx(transects_c,
#                      path        = "transects_2026-04-21.gpx",
#                      name_prefix = "2026-04-21")