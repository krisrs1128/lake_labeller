library(leaflet)
library(tidyverse)
library(leaflet.extras)
library(shiny)
library(geojsonsf)
library(sf)
library(glue)
library(leafpm)
library(mapedit)
library(mapview)
library(rmapshaper)

titiler_url <- "http://127.0.0.1:8000/cog/tiles/{{z}}/{{x}}/{{y}}.png?scale=1&format=png&TileMatrixSetId=WebMercatorQuad&url=..%2Fdata%2Fderived_data%2Fcogs%2Flakes.vrt&&bidx={input$ch1}%2C{input$ch2}%2C{input$ch3}&resampling_method=nearest&return_mask=true"
lakes <- read_sf("../data/GL_3basins_2015.shp") %>%
  as("Spatial") %>%
  ms_simplify(keep=0.05) %>%
  st_as_sf()

ui <- fluidPage(
  h3("lake labelling app"),
  selectInput("gl_id", "Glacier ID", lakes$GL_ID, lakes$GL_ID[1]),
  selectInput("basin", "Sub-Basin", selected = lakes$Sub_Basin[1], choices = unique(lakes$Sub_Basin)),
  selectInput("ch1", "channel 1", selected = "B1", choices = paste0("B", 1:3)),
  selectInput("ch2", "channel 2", selected = "B2", choices = paste0("B", 1:3)),
  selectInput("ch3", "channel 3", selected = "B3", choices = paste0("B", 1:3)),
  leafletOutput("map")
)

server <- function(input, output) {
  current_map <- reactive({
    lake <- lakes %>%
      filter(GL_ID == input$gl_id)
    
    leaflet() %>%
      addBingTiles(api = "AiQHbzGt0thQclG_ntiQedHzUZJhxtA2I2g-QAx_OPpsqpBTSUmrJuyeO-oGJGLo") %>%
      addTiles(url=glue(titiler_url)) %>%
      addPolygons(data = filter(lakes, Sub_Basin == input$basin), group = "edits") %>%
      setView(lat=lake$Latitude[1], lng=lake$Longitude[1], zoom=12)
  })
  
  output$map <- renderLeaflet({
    m <- current_map()
    m$dependencies <- c(m$dependencies, leafpm::pmDependencies())
    m %>%
      addPmToolbar(targetGroup = "edits")
  })
  
  observeEvent(input$basin, {
    cur_ids <- lakes %>%
      filter(Sub_Basin %in% input$basin) %>%
      pull(GL_ID)
    updateSelectInput("gl_id", choices = cur_ids)
  })
}

shinyApp(ui, server)