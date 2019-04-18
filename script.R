library(tidyverse)
library(tidycensus)
library(mapview)
library(sf)
library(leaflet)
library(tigris)
api_key <- "ad6d908d59b8fd6b7cd711901f628f9060feb972"
census_api_key(api_key)
palm_beach <- read_csv("http://justicetechlab.org/wp-content/uploads/2019/04/palmbeachcounty_fl.csv")

fl <- counties(state = "FL", class = "sf")
fl <-  fl[fl$NAME == "Palm Beach",]


fl %>% ggplot() + geom_sf()