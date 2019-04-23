#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(tidyverse)
library(rgdal)
library(leaflet)
library(lubridate)


Goldsboro <- read_csv("http://justicetechlab.org/wp-content/uploads/2019/04/goldsboro_nc.csv") %>% 
  mutate(type = str_replace(string = type,pattern = "_", replacement = " ")) %>% 
  mutate(written_month = month.abb[month])

type_shot <- Goldsboro %>% distinct(type)
years <- Goldsboro %>% distinct(year)
months <- Goldsboro %>% distinct(month)

ui <- dashboardPage(
  skin = "red",
  dashboardHeader(title = "Goldsboro North Carolina Shootings 2016-2019", titleWidth = 470),
  dashboardSidebar(
    sliderInput(
      inputId = "year_shot",
      label = "Year of Shooting",
      min = min(years$year),
      max = max(years$year),
      value = c(min(years$year), max(years$year)-2),
      sep = "",
      step = 1,
      animate = animationOptions(interval = 1200, loop = TRUE)),
    
    sliderInput(
      inputId = "month_shot",
      label = "Month of Shooting",
      min = min(months$month),
      max = max(months$month),
      value = c(min(months$month), min(months$month)+3),
      sep = "",
      step = 1,
      animate = animationOptions(interval = 1500, loop = TRUE),

    
    ),
    
    checkboxGroupInput(inputId = "type", 
                 label = "Type of Shot", 
                 choices = type_shot$type, 
                 selected = type_shot$type[1]
    )
  ),
  dashboardBody(
    leafletOutput("maps", height = 500),
    h3("Source: Justice Tech Lab"),
    p("We would not have been able to complete this app without the use of data from the Justice Tech Lab, which was kind enough to share data on the locations of shootings that they had detected using the Shotspotter network"),
    p(" You can find their data here: "),
    a("http://justicetechlab.org/shotspotter-data/")
    
  )
)
server <- function(input, output, session){
  data <- reactive({
    if (length(input$type) == 0) {
      x <- Goldsboro %>%
        filter(year >= input$year_shot[1]) %>% 
        filter(year <= input$year_shot[2]) %>% 
        filter(month >= input$month_shot[1]) %>% 
        filter(month <= input$month_shot[2])
    } else {
      x <- Goldsboro %>%
        filter(year >= input$year_shot[1]) %>% 
        filter(year <= input$year_shot[2]) %>% 
        filter(month >= input$month_shot[1]) %>% 
        filter(month <= input$month_shot[2]) %>% 
        filter(type == input$type)
    }
  })
  output$maps <- renderLeaflet({
    Goldsboro <- data()
    map_of_G <- leaflet(data = Goldsboro) %>% 
      addTiles() %>% 
      setView(lat = 35.384710, lng = -77.992573, zoom = 13) %>% 
      addMarkers(lng = ~longitude,
                 lat = ~latitude,
                 popup = paste("Type of Crime: ", Goldsboro$type, "<br>",
                               "Year:", Goldsboro$year, "<br>", 
                               "Month:", Goldsboro$written_month, "<br>",
                               "Address:", Goldsboro$address))
    map_of_G
  })
  
}



# Run the application 
shinyApp(ui = ui, server = server)

