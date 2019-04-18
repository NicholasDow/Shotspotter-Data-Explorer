library(tidyverse)
library(tidycensus)
library(mapview)
library(sf)
library(leaflet)
api_key <- "ad6d908d59b8fd6b7cd711901f628f9060feb972"
census_api_key(api_key)
palm_beach <- read_csv("http://justicetechlab.org/wp-content/uploads/2019/04/palmbeachcounty_fl.csv")
shapes <- urban_areas(class = "sf")



