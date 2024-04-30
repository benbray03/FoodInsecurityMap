rm(list = ls())

library(ggplot2)
library(sp)
library(sf)
library(ggmap)

register_google(key = "AIzaSyCgnM6ltD_ZmNGoaMttIKZz7xixwpZnDyw")


# Generating more spread out data points
set.seed(12345)
data <- data.frame(
  lon = runif(1000, min = -124, max = -114),
  lat = runif(1000, min = 32, max = 42)
)


#check to make sure that all data is within range 
summary(data)


# Get the basemap using Google API, zoom of 14 is too close, zoom 8 too far
basemap <- get_map(location = c(lon = mean(data$lon), lat = mean(data$lat)), zoom = 6)

# Plot basemap with points
heatmap <- ggmap(basemap) +
  geom_point(data = data, aes(x = lon, y = lat), color = "red", alpha = 0.5) +
  labs(title = "GIS Heatmap", x = "Longitude", y = "Latitude")

#printing map with just points
print(heatmap)

# Create heatmap layer based on points
heatmap <- ggmap(basemap) +
  stat_density_2d(data = data, aes(x = lon, y = lat, fill = ..level.., alpha = ..level..), geom = "polygon") +
  scale_fill_gradient(low = "pink", high = "darkred") +
  scale_alpha(range = c(0, 0.5)) +
  labs(title = "GIS Heatmap", x = "Longitude", y = "Latitude")

print(heatmap)

