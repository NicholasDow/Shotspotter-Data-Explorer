library(tidyverse)
library(tidycensus)
library(mapview)
library(sf)
library(leaflet)
api_key <- "ad6d908d59b8fd6b7cd711901f628f9060feb972"

palm_beach <- read_csv("http://justicetechlab.org/wp-content/uploads/2019/04/palmbeachcounty_fl.csv",
                       cols_types = cols(
                         address = col_character(),
                         city = col_character(),
                         state = col_character(),
                         datetime = col_character(),
                         numrounds = col_double(),
                         shotspotterflexid = col_double(),
                         lat = col_double(),
                         long = col_double()
                       ))

