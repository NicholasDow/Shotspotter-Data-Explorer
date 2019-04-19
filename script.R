library(tidyverse)
library(tidycensus)
library(mapview)
library(sf)
library(leaflet)
library(tigris)
api_key <- "ad6d908d59b8fd6b7cd711901f628f9060feb972"
census_api_key(api_key)
Goldsboro <- read_csv("http://justicetechlab.org/wp-content/uploads/2019/04/goldsboro_nc.csv")

raw_shapes <- urban_areas(class = "sf")

shapes <- raw_shapes %>% 
  filter(NAME10 == "Goldsboro, NC")

# do this manipulation in the app
Goldsboro_locations <- st_as_sf(Goldsboro, 
                                coords = c("longitude", "latitude"), 
                                crs = 4326)

write_rds(Goldsboro, "Shotspotter/Goldsboro.rds")
write_rds(shapes, "Shotspotter/shapes.rds") 



shapes %>% ggplot() + geom_sf() + geom_sf(data = Goldsboro_locations) 

