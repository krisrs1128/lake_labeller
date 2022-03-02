library(leaflet)
library(tidyverse)
library(shiny)
library(sf)

titiler_url = "http://127.0.0.1:8000/cog/tiles/{z}/{x}/{y}.png?scale=1&format=png&TileMatrixSetId=WebMercatorQuad&url=..%2Fdata%2Fderived_data%2Fcogs%2Flakes.vrt&resampling_method=nearest&return_mask=true"
lakes <- read_sf("../data/GL_3basins_2015.shp")

ui <- fluidPage(
  h3("lake labelling app"),
  selectInput("gl_id", "Glacier Lake ID", selected = lakes$GL_ID[1], choices = lakes$GL_ID),
  leafletOutput("map")
)

server <- function(input, output) {
  output$map <- renderLeaflet({
    lake <- lakes %>%
      filter(GL_ID == input$gl_id)
    
    leaflet() %>%
      addProviderTiles(providers$Stamen.TonerLite) %>%
      addTiles(url=titiler_url) %>%
      setView(lat=lake$Latitude, lng=lake$Longitude, zoom=12)
  })
  
  
}

shinyApp(ui, server)