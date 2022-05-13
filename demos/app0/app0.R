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
  ms_simplify() %>%
  st_as_sf()

lakes_ <- lakes[1:10, ] %>%
  filter()

ui <- fluidPage(
  h3("lake labelling app"),
  selectInput("gl_id", "Glacier Lake ID", selected = lakes$GL_ID[1], choices = lakes$GL_ID),
  selectInput("ch1", "channel 1", selected = "B1", choices = paste0("B", 1:3)),
  selectInput("ch2", "channel 2", selected = "B2", choices = paste0("B", 1:3)),
  selectInput("ch3", "channel 3", selected = "B3", choices = paste0("B", 1:3)),
  leafletOutput("map")
)

server <- function(input, output) {
  current_map <- reactive({
    lake <- lakes_ %>%
      filter(GL_ID == input$gl_id)
    
    leaflet() %>%
      addBingTiles(api = "AiQHbzGt0thQclG_ntiQedHzUZJhxtA2I2g-QAx_OPpsqpBTSUmrJuyeO-oGJGLo") %>%
      addTiles(url=glue(titiler_url)) %>%
      addPolygons(data = lakes_, group = "edits") %>%
      setView(lat=lake$Latitude[1], lng=lake$Longitude[1], zoom=12)
  })
  
  output$map <- renderLeaflet({
    m <- current_map()
    m$dependencies <- c(m$dependencies, leafpm::pmDependencies())
    m %>%
      addPmToolbar(targetGroup = "edits")
  })
  
  observe({
    if (!is.null(input[["map_bounds"]])) {
      lakes_ <- lakes %>%
        filter(
          Latitude > input[["map_bounds"]]$south, 
          Latitude < input[["map_bounds"]]$north,
          Longitude > input[["map_bounds"]]$west,
          Longitude < input[["map_bounds"]]$east
        )
    } else {
      lakes_ <- lakes[1:10, ]
    }
    
    if (!is.null(input[["map_draw_edited_features"]])) {
      print(input$map_draw_edited_features)
      st_polygon(input$map_draw_edited_features$geometry$coordinates[[1]])
      new_poly <- st_polygon(input$map_draw_edited_features$geometry$coordinates[[1]])
      print(new_poly)
    }
    
    leafletProxy("map") %>%
      clearShapes() %>%
      addPolygons(data = lakes_, group = "edits")
  })
}

shinyApp(ui, server)