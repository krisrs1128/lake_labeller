library(leaflet)
library(tidyverse)
library(shiny)
library(sf)
library(glue)
library(mapedit)
library(mapview)

titiler_url <- "http://127.0.0.1:8000/cog/tiles/{{z}}/{{x}}/{{y}}.png?scale=1&format=png&TileMatrixSetId=WebMercatorQuad&url=..%2Fdata%2Fderived_data%2Fcogs%2Flakes.vrt&&bidx={input$ch1}%2C{input$ch2}%2C{input$ch3}&resampling_method=nearest&return_mask=true"
lakes <- read_sf("../data/GL_3basins_2015.shp")[1:10, ]

ui <- fluidPage(
  h3("lake labelling app"),
  selectInput("gl_id", "Glacier Lake ID", selected = "GL081218E30060N", choices = lakes$GL_ID),
  selectInput("ch1", "channel 1", selected = "B1", choices = paste0("B", 1:3)),
  selectInput("ch2", "channel 2", selected = "B2", choices = paste0("B", 1:3)),
  selectInput("ch3", "channel 3", selected = "B3", choices = paste0("B", 1:3)),
  editModUI("mapeditor"),
  leafletOutput("map")
)

server <- function(input, output) {
  current_map <- reactive({
    lake <- lakes %>%
      filter(GL_ID == input$gl_id)
    
    leaflet() %>%
      addProviderTiles(providers$Stamen.TonerLite) %>%
      addTiles(url=glue(titiler_url)) %>%
      addPolygons(data = lakes, group = "edits") %>%
      setView(lat=lake$Latitude[1], lng=lake$Longitude[1], zoom=12)
  })
  
  edits <- reactive({
    callModule(
      editMod,
      "mapeditor",
      leafmap = current_map(),
      editor = "leaflet.extras",
      targetLayerId = "edits"
    )
  })
    
  output$map <- renderLeaflet({
    edits()()$all
  })
}

shinyApp(ui, server)