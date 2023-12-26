# ----------------- #
# OSM version #
# ----------------- #

library(osmdata)
library(sf)
library(tidyverse)
library(shadowtext)

# colors
main_col <- "white"
sec_col <-  "#256291"

# Load data ---------------------------------------------------------------

# function to get data from OSM
get_osm_cropped_data <- function(location, radius) {
  # get bbox around location
  # transform to sf
  # get centroid
  bb_point <- getbb(location) |>
    t() |>
    data.frame() |>
    st_as_sf(coords = c("x", "y")) |>
    st_bbox() |>
    st_as_sfc() |>
    st_centroid()

  st_crs(bb_point) <- 4326

  # get data around point
  sf_osm <-
    opq_around(
      st_coordinates(bb_point)[1],
      st_coordinates(bb_point)[2],
      radius = radius,
      key = "highway"
    ) |>
    osmdata_sf()

  # get lines
  sf_osm_lines <- sf_osm$osm_lines

  # square buffer
  sf_square_buffer <-
    buffeRs::buffer_rectangle(st_as_sf(bb_point), radius / 70000, radius / 160000) |>
    st_bbox()

  # crop
  sf_osm_lines_cropped <- st_crop(sf_osm_lines, sf_square_buffer)

  # sign of corner
  if (sf_square_buffer$xmin > 0) {
    x_sign <- 1
  } else{
    x_sign <- -1
  }
  if (sf_square_buffer$ymin > 0) {
    y_sign <- 1
  } else{
    y_sign <- -1
  }

  # bbox corner
  bb_corner_x <-
    sf_square_buffer$xmin + (radius * 0.0000003) * x_sign
  bb_corner_y <- sf_square_buffer$ymin + (radius * 0.000001) * y_sign

  # return
  list(
    "centroid" = st_coordinates(bb_point),
    "bbox_corner_x" = bb_corner_x,
    "bbox_corner_y" = bb_corner_y,
    "lines" = sf_osm_lines_cropped,
    "buffer" = sf_square_buffer
  )
}

# Convert decimal degrees to DMS ------------------------------------------
decimal_deg_to_dms <- function(dec_deg, type) {
  # dms
  degrees <- trunc(dec_deg, 0)
  minutes <- trunc(60 * abs(dec_deg - degrees), 0)
  seconds <- round(3600 * abs(dec_deg - degrees) - 60 * minutes, 0)

  # direction
  if (dec_deg < 0 & type == "x") {
    dir <- "W"
  } else if (dec_deg >= 0 & type == "x") {
    dir <- "E"
  } else if (dec_deg < 0 & type == "y") {
    dir <- "S"
  } else if (dec_deg >= 0 & type == "y") {
    dir <- "N"
  }

  # string
  dms <- glue::glue("{abs(degrees)}°{minutes}'{seconds}\"{dir}")

  dms

}

# Plot --------------------------------------------------------------------
create_map_with_coords <-
  function(sf_osm_list, export_path, filename) {
    dms_x <- decimal_deg_to_dms(sf_osm_list$centroid[1], "x")
    dms_y <- decimal_deg_to_dms(sf_osm_list$centroid[2], "y")

    coordinates_text <-
      glue::glue("{dms_y}\n{dms_x}")

    # plot
    p <- ggplot() +
      geom_sf(data = sf_osm_list$lines,
              color = sec_col,
              linewidth = .1) +
      annotate(
        geom = "shadowtext",
        x = sf_osm_list$bbox_corner_x,
        y = sf_osm_list$bbox_corner_y,
        label = coordinates_text,
        size = 10,
        hjust = 0,
        family = "Fira Sans",
        fontface = "bold",
        color = sec_col,
        bg.colour = main_col
      ) +
      theme_void() +
      theme(
        panel.background = element_rect(fill = main_col, color = main_col),
        plot.background = element_rect(fill = main_col)
      )

    # export
    ggsave(
      plot = p,
      filename = filename,
      path = export_path,
      device = "png",
      units = "mm",
      width = 148,
      height = 105
    )

  }

# Wrapper -----------------------------------------------------------------
wrap_coords_map <- function(location, radius, dir_export_path) {
  # get data
  sf_osm_list <- get_osm_cropped_data(location, radius)

  # create map
  create_map_with_coords(
    sf_osm_list,
    export_path = dir_export_path,
    filename = glue::glue("{location}.png")
  )
}

wrap_coords_map("chantilly", 5000, "outputs")
