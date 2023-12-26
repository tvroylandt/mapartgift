# --------------- #
# Christmas version #
# --------------- #

library(mapartgift)
library(magick)
library(tidyverse)

source("R/christmas_version_deps.R")

# Get data ----------------------------------------------------------------

# url <- "http://download.geofabrik.de/europe/france/picardie-latest-free.shp.zip"
# curl::curl_download(url, destfile = "picardie.shp.zip")
# unzip("picardie.shp.zip", exdir = "inst/shapefiles/picardie")

# Load/Plot ---------------------------------------------------------------

# Chantilly
map_art_gift_load(
  region = "picardie",
  name_place = "Chantilly",
  crs = 2154,
  dist_shape = 3,
  building = TRUE
)

map_art_gift_plot(
  region = "picardie",
  name_place = "Chantilly",
  building = TRUE,
  building_shp = building_cropped
)

# Lille
map_art_gift_load(
  region = "nord-pas-de-calais",
  name_place = "Lille",
  crs = 2154,
  dist_shape = 4
)

map_art_gift_plot(region = "nord-pas-de-calais", name_place = "Lille")

# Evanston
map_art_gift_load(
  region = "illinois",
  name_place = "Evanston",
  crs = 3528,
  dist_shape = 5
)

map_art_gift_plot(region = "illinois", name_place = "Evanston")

# Bruxelles
map_art_gift_load(
  region = "belgium",
  name_place = "Bruxelles",
  crs = 3812,
  dist_shape = 5
)

map_art_gift_plot(region = "belgium", name_place = "Bruxelles")

# Assemble ----------------------------------------------------------------

map_chantilly <-
  image_read("maps/output/picardie_Chantilly_297_420.png")
map_lille <-
  image_read("maps/output/nord-pas-de-calais_Lille_297_420.png")
map_evanston <-
  image_read("maps/output/illinois_Evanston_297_420.png")
map_bruxelles <-
  image_read("maps/output/belgium_Bruxelles_297_420.png")

map_assemble1 <-
  image_append(image = c(map_evanston, map_chantilly))
map_assemble2 <- image_append(image = c(map_bruxelles, map_lille))

map_assemble_maman <-
  image_append(image = c(map_assemble1, map_assemble2),
               stack = TRUE)
