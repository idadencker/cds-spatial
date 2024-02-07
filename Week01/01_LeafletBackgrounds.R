###   GETTING STARTED WITH LEAFLET


## Choose favorite backgrounds in:
# https://leaflet-extras.github.io/leaflet-providers/preview/
## beware that some need extra options specified

# Packages
install.packages("leaflet")
install.packages("htmltools") 
install.packages("googlesheets4")

# Example with Markers
library(leaflet)
library(tidyverse)

popup = c("Robin", "Jakub", "Jannes")


leaflet() %>%
  addProviderTiles("Esri.WorldPhysical") %>% 
 #addProviderTiles("Esri.WorldImagery") %>% #This is another type of map we could use, different from WorldPhysical
  addAwesomeMarkers(lng = c(-3, 23, 11), #lng = longitude
                    lat = c(52, 53, 49), #lat= latitude
                    popup = popup)


## Sydney with setView
leaflet() %>%
  addTiles() %>%
  addProviderTiles("Esri.WorldImagery", 
                   options = providerTileOptions(opacity=0.5)) %>% 
  setView(lng = 151.005006, lat = -33.971, zoom = 10)


# Europe with Layers
leaflet() %>% 
  addTiles() %>% 
  setView( lng = 2.34, lat = 48.85, zoom = 5 ) %>% 
  addProviderTiles("Esri.WorldPhysical", group = "Physical") %>% 
  addProviderTiles("Esri.WorldImagery", group = "Aerial") %>% 
  addProviderTiles("MtbMap", group = "Geo") %>% 

addLayersControl(
  baseGroups = c("Geo","Aerial", "Physical"),
  options = layersControlOptions(collapsed = T))

# note that you can feed plain Lat Long columns into Leaflet
# without having to convert into spatial objects (sf), or projecting


########################## SYDNEY HARBOUR DISPLAY WITH LAYERS

# Set the location and zoom level
leaflet() %>% 
  setView(151.2339084, -33.85089, zoom = 13) %>%
  addTiles()  # checking I am in the right area


# Bring in a choice of esri background layers  

l_aus <- leaflet() %>%   # assign the base location to an object
  setView(151.2339084, -33.85089, zoom = 13)

#Prepare the pop up box where we can choose for all the providers 
esri <- grep("^Esri", providers, value = TRUE)

for (provider in esri) {
  l_aus <- l_aus %>% addProviderTiles(provider, group = provider)
} 

#Now display the map
AUSmap <- l_aus %>%
  addLayersControl(baseGroups = names(esri), #Makes the pop up where we can choose what kind of map we want
                   options = layersControlOptions(collapsed = FALSE)) %>%
  addMiniMap(tiles = esri[[1]], toggleDisplay = TRUE, #Adds the little minimap in the bottomright, can comment it out
             position = "bottomright") %>%
  addMeasure(
    position = "bottomleft",
    primaryLengthUnit = "meters",
    primaryAreaUnit = "sqmeters",
    activeColor = "#3D535D",
    completedColor = "#7D4479") %>% 
  htmlwidgets::onRender("
                        function(el, x) {
                        var myMap = this;
                        myMap.on('baselayerchange',
                        function (e) {
                        myMap.minimap.changeLayer(L.tileLayer.provider(e.name));
                        })
                        }") %>% 
addControl("", position = "topright")

AUSmap
################################## SAVE FINAL PRODUCT

# Save map as a html document (optional, replacement of pushing the export button)
# only works in root
pacman::p_load(htmlwidgets) # from htmltools

#saves in the working directory
saveWidget(AUSmap, "AUSmap.html", selfcontained = TRUE)

#########################################################
#
# Task 1: Create a Danish equivalent with esri layers, call it DKmap

DKmap <- leaflet() %>%
  addTiles() %>%
  addProviderTiles("Esri.WorldImagery", 
                   options = providerTileOptions(opacity=0.5)) %>% 
  setView(lng = 10.19, lat = 56.14, zoom = 10)
DKmap
saveWidget(DKmap, "DKmap.html", selfcontained = TRUE)

#
# Task 2: Start collecting spatial data into a spreadsheet: https://docs.google.com/spreadsheets/d/1PlxsPElZML8LZKyXbqdAYeQCDIvDps2McZx1cTVWSzI/edit#gid=1817942479
#
#
################################## ADD DATA TO LEAFLET
# Libraries
pacman::p_load(tidyverse,googlesheets4,leaflet)

# gs4_deauth() # if the authentication is not working for you

gs4_deauth()

places <- read_sheet("https://docs.google.com/spreadsheets/d/1PlxsPElZML8LZKyXbqdAYeQCDIvDps2McZx1cTVWSzI/edit#gid=1817942479",
                     range = "SA2024",
                     col_types = "cccnncnc")
glimpse(places)

leaflet() %>% 
  addTiles() %>% 
  addMarkers(lng = places$Longitude, 
             lat = places$Latitude,
             popup = places$Description)

#########################################################
#
# Task 3: Read in the googlesheet data you and your colleagues populated with data and display it over your DKmap . 
# The googlesheet is at https://docs.google.com/spreadsheets/d/1PlxsPElZML8LZKyXbqdAYeQCDIvDps2McZx1cTVWSzI/edit#gid=1817942479

DKmap%>%
  addMarkers(lng = places$Longitude, 
             lat = places$Latitude,
             popup = places$Description)

#########################################################

#Task 4: load in data about Chicago

crime_data <- read_csv('/Users/idahelenedencker/Desktop/CognitiveScience/6. semester/Spatial analytics/git/cds-spatial/Week01/data/ChicagoCrimes2017.csv')

leaflet() %>% 
  addTiles() %>% 
  addMarkers(lng = crime_data$Longitude, 
             lat = crime_data$Latitude,
             popup = crime_data$`Primary Type`,
             clusterOptions = 1 )
