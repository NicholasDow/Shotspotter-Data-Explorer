#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
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


type_shot <- Goldsboro %>% distinct(type)

# Define UI for application that draws a histogram
ui <- fluidPage(
   # Application title
   titlePanel("Mapping type of shot in Goldsboro 2018<- I dont know if that is right"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        checkboxGroupInput(inputId = "type_gun", 
                    choices = type_shot$type,
                    label = "Type of Shot Spotted", 
                    selected = type_shot$type[[1]]),
        checkboxGroupInput(inputId = "year",
                    label = "years", 
                    choices = c(2016,2017,2018,2019),
                    selected = 2016)),
      mainPanel(
         plotOutput("distPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$distPlot <- renderPlot({ 
     show <- Goldsboro %>% 
       filter(type == input$type_gun) %>% 
       filter(year == input$year)
     
     Goldsboro_locations <- st_as_sf(show, 
                                     coords = c("longitude", "latitude"), 
                                     crs = 4326)
     shapes %>% 
       ggplot() + 
       geom_sf()+ 
       geom_sf(data = Goldsboro_locations, mapping = aes(color = type)) +
       ggtitle("Type of shot in the year", input$year)
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

