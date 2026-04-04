
## Functions

get_weather <- function(past_days = 1, forecast_days = 0) {
  
  library(httr)
  library(jsonlite)
  
    url <- paste0("https://api.open-meteo.com/v1/forecast?latitude=36.1447&longitude=-5.3526&hourly=temperature_2m,relative_humidity_2m,precipitation,rain,weather_code,visibility,pressure_msl,surface_pressure,cloud_cover,wind_speed_10m,wind_direction_10m,wind_gusts_10m&models=ukmo_seamless&timezone=auto&past_days=3&forecast_days=0")
  
    red <- GET(url)
    
    df <- fromJSON(content(red, "text", encoding = "UTF-8"))
    
    weather_data <- as.data.frame(df)
    
    summary(weather_data)
    
  

}


