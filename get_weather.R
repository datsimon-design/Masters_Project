library(httr)
library(jsonlite)

lon <- -5.33334
lat <- 36.15


url <- "https://api.open-meteo.com/v1/forecast?latitude=36.1447&longitude=-5.3526&hourly=temperature_2m,relative_humidity_2m,precipitation,rain,weather_code,visibility,pressure_msl,surface_pressure,cloud_cover,wind_speed_10m,wind_direction_10m,wind_gusts_10m&models=ukmo_seamless&timezone=auto&past_days=3&forecast_days=3"

red <- GET(url)

weather_data <- fromJSON(content(red, "text", encoding = "UTF-8"))

print(weather_data$hourly)

summary(weather_data)
