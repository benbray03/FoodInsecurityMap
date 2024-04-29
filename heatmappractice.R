rm(list = ls()) 

library(ggplot2)
library(ggmap)
library(sp)
register_google(key = "AIzaSyCPgtYcJIjy7HtskPUNKYze3hckZ7LKq08", write = TRUE)

data <- data.frame(
  lon = c(-119.6388,
          -119.7824,
          -119.3567,
          -119.1239,
          -119.3974,
          -119.2056,
          -119.3455,
          -119.6053,
          -119.2241,
          -119.0102),
  lat = c(34.4301,
          34.5005,
          34.6728,
          34.4389,
          34.7263,
          34.6197,
          34.4652,
          34.5568,
          34.6434,
          34.3786)
)

basemap <- get_map(location = c(lon = mean(data$lon), lat = mean(data$lat)), zoom = 8)

# Plot basemap with points
map <- ggmap(basemap) +
  geom_point(data = data, aes(x = lon, y = lat), color = "red", alpha = 0.5) +
  labs(title = "GIS Heatmap", x = "Longitude", y = "Latitude")

print(map)


# Get the basemap, zoom of 14 is too close, zoom 8 too far
basemap <- get_map(location = c(lon = mean(data$lon), lat = mean(data$lat)), zoom = 10)

# Plot basemap with points
heatmap <- ggmap(basemap) +
  geom_point(data = data, aes(x = lon, y = lat), color = "red", alpha = 0.5) +
  labs(title = "GIS Heatmap", x = "Longitude", y = "Latitude")

# Create heatmap layer
heatmap <- ggmap(basemap) +
  stat_density_2d(data = data, aes(x = lon, y = lat, fill = ..level.., alpha = ..level..), geom = "polygon") +
  scale_fill_gradient(low = "pink", high = "darkred") +
  scale_alpha(range = c(0, 0.5)) +
  labs(title = "GIS Heatmap", x = "Longitude", y = "Latitude")


print(heatmap)

#check to make sure that all data is within range 
summary(data)

print(heatmap)
