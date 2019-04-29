#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# We add shiny to make this into a webpage

library(shiny)

# We add shinydashboards to get a nice layout

library(shinydashboard)

# We add tidyverse for obvious data manipulation

library(tidyverse)

# We add leaflet for mapping

library(leaflet)

# We add lubridate to manage dates

library(lubridate)

# We are reading in the data from Shotspotter

Goldsboro <- read_csv("http://justicetechlab.org/wp-content/uploads/2019/04/goldsboro_nc.csv") %>% 
  
  # We get rid of all _ in type names
  
  mutate(type = str_replace_all(string = type, pattern = "_", replacement = " ")) %>% 
  
  # We get text versions of months for labels
  
  mutate(written_month = month.abb[month])

# We make a list for Inputs, Types here

type_shot <- Goldsboro %>% distinct(type)

# Years here

years <- Goldsboro %>% distinct(year)

# Months here

months <- Goldsboro %>% distinct(month)

# Making the user interface here

ui <- dashboardPage(
  
  # Making the dashboard redish
  
  skin = "red",
  
  # Adding a title and making it wide
  
  dashboardHeader(title = "Goldsboro NC Shootings by Nicholas Dow and Will Smiles", titleWidth = 600),
  
  # Adding a sidebar
  
  dashboardSidebar(
    
    # We are adding a sidebar input for year
    
    sliderInput(
      
      # Name of input var
      
      inputId = "year_shot",
      
      # label for input
      
      label = "Year of Shooting",
      
      # min and max values based on year data
      
      min = min(years$year),
      max = max(years$year),
      
      # We are making the slider data a range here
      
      value = c(min(years$year), max(years$year)-2),
      
      # "" make it look good
      
      sep = "",
      
      # One year at a time
      
      step = 1,
      
      # We are adding the animation here
      
      animate = animationOptions(interval = 1200, loop = TRUE)),
    
    # Slider input for month
    
    sliderInput(
      
      # Adding input var month
      
      inputId = "month_shot",
      
      # Giving a label for user use
      
      label = "Month of Shooting",
      
      # Min max values from created list
      
      min = min(months$month),
      max = max(months$month),
      
      # Making this a range by setting values to vector
      
      value = c(min(months$month), min(months$month)+3),
      
      # "" sep makes it look nice
      
      sep = "",
      
      # We obviously want the steps to be by 1
      
      step = 1,
      
      # We animate our map here
      
      animate = animationOptions(interval = 1500, loop = TRUE)

    ),
    
    # We wan to give the option to selec the type of shot
    
    checkboxGroupInput(
      
      # We have var set at type here
      
      inputId = "type", 
      
      # We label the input for user
      
      label = "Type of Shot", 
      
      # Set choices to everything in DF type
      
      choices = type_shot$type, 
      
      # Set selected to the first value list
      
      selected = type_shot$type[1]
    )
    
  ),
  
  # We create a dashboard body for the graph and text
  
  dashboardBody(
    
    # We output our map here, and set height to avoid scroll
    
    leafletOutput("maps", height = 490),
    
    # We write source, git, and thank you here
    
    h3("Source: Justice Tech Lab"),
    p("We would not have been able to complete this app without the use of data from the Justice Tech Lab, which was kind enough to publically share data on the locations of shootings that they had detected using the Shotspotter network."),
    p(" You can find their data here: ", a("http://justicetechlab.org/shotspotter-data/")),
    p("Github: ", a("https://github.com/NicholasDow/Shotspotter-Data-Explorer/tree/master"))
    
  )
)

# We make our server heer

server <- function(input, output, session){
  
  # We are making a reactive var here called data
  
  data <- reactive({
    
    # This will do two different things depending on if the input
    # of the ui for type is empty
    
    if (length(input$type) == 0) {
      
      # If it is empty we will return the data filted by inputs 
      # but without filtring by type
      
      x <- Goldsboro %>%
        
        # filtering by min(1st) and max(2nd) in input year
        
        filter(year >= input$year_shot[1]) %>% 
        filter(year <= input$year_shot[2]) %>% 
        
        # filtering by min(1st) and max(2nd) in input month
        
        filter(month >= input$month_shot[1]) %>% 
        filter(month <= input$month_shot[2])
      
      # Otherwise use type to filter data
    } else {
      x <- Goldsboro %>%
        
        # Filtering by min(1st) and max(2nd) in input year
        
        filter(year >= input$year_shot[1]) %>% 
        filter(year <= input$year_shot[2]) %>% 
        
        # Filtering by min(1st) and max(2nd) in input month
        
        filter(month >= input$month_shot[1]) %>% 
        filter(month <= input$month_shot[2]) %>% 
      
        # Filter by type
      
        filter(type %in% input$type)
    }
    
  })
  
  # Here we are rendering our leaflet map
  
  output$maps <- renderLeaflet({
    
    # We are assigning the reactive to goldboro var here
    
    Goldsboro <- data()
    
    # We are making a leaflet map here
    
    map_of_G <- leaflet(data = Goldsboro) %>% 
      
      # We use basic tile set, its honestly fine
      
      addTiles() %>% 
      
      # We set the view to be the same and centered around goldsboro
      
      setView(lat = 35.384710, lng = -77.992573, zoom = 13) %>% 
      
      # We add markers with locations set to the vars in goldsboro dt
      
      addMarkers(lng = ~longitude,
                 lat = ~latitude,
                 
                 # We put information about the specific event here
                 # Type, year, Month, and Address.
                 
                 popup = paste("Type of Crime: ", Goldsboro$type, "<br>",
                               "Year:", Goldsboro$year, "<br>", 
                               "Month:", Goldsboro$written_month, "<br>",
                               "Address:", Goldsboro$address))
    
    # We actually call the map below
    
    map_of_G
  })
  
}



# Run the application 
shinyApp(ui = ui, server = server)

