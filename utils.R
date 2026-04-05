
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
  "&forecast_days=", forecast_days, "&minutely_15=ocean_current_velocity,ocean_current_direction,sea_level_height_msl")
  
    red_m <- GET(url_marine)
    
    df_ma <- fromJSON(content(red_m, "text", encoding = "UTF-8"))
    
    marine_data <<- as.data.frame(df_ma)
    
    summary(marine_data)
    
  
  
}

