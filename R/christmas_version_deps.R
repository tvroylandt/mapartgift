#' Load the data
#'
#' @param region The name of the directory where you can find the shp
#' @param name_place The name of the place to plot
#' @param crs The EPSG CRS, default to Mercator (3785)
#' @param dist_shape The distance to plot around the plot
#' @param shape The shape, circle or square, default to circle
#' @param building Include the building layer
#' @param castle Include the castles
#'
#' @return The loaded shp in the GlobalEnv
#'
#' @import sf
#' @import dplyr
#' @import stringr
#' @import units
#' @import forcats
#' @importFrom magrittr %>%
#'
#' @export
#'

map_art_gift_load <-
  function(region,
           name_place,
           crs = 3785,
           dist_shape = 3,
           shape = "circle",
           building = FALSE,
           castle = FALSE) {
    # OSM layer import
    places_import <-
      read_sf(paste0("maps/shapefiles/", region, "/gis_osm_places_free_1.shp")) %>%
      st_transform(crs = crs)

    roads_import <-
      read_sf(paste0("maps/shapefiles/", region, "/gis_osm_roads_free_1.shp")) %>%
      st_transform(crs = crs)

    water_import <-
      read_sf(paste0("maps/shapefiles/", region, "/gis_osm_water_a_free_1.shp")) %>%
      st_transform(crs = crs)

    waterways_import <-
      read_sf(paste0(
        "maps/shapefiles/",
        region,
        "/gis_osm_waterways_free_1.shp"
      )) %>%
      st_transform(crs = crs)

    railways_import <-
      read_sf(paste0("maps/shapefiles/", region, "/gis_osm_railways_free_1.shp")) %>%
      st_transform(crs = crs)

    landuse_import <-
      read_sf(paste0(
        "maps/shapefiles/",
        region,
        "/gis_osm_landuse_a_free_1.shp"
      )) %>%
      st_transform(crs = crs)

    if (building == TRUE) {
      building_import <-
        read_sf(paste0(
          "maps/shapefiles/",
          region,
          "/gis_osm_buildings_a_free_1.shp"
        )) %>%
        st_transform(crs = crs)
    }

    if (castle == TRUE) {
      castle_import <-
        read_sf(paste0("maps/shapefiles/",
                       region,
                       "/gis_osm_pois_a_free_1.shp")) %>%
        filter(fclass == "castle") %>%
        st_transform(crs = crs)
    }

    # Setting the place
    place_right <- places_import %>%
      filter(.data$name == name_place)

    # Setting the shape with a distance
    if (shape == "square") {
      place_shape <- place_right %>%
        st_buffer(dist = units::set_units(dist_shape, "km")) %>%
        st_bbox() %>%
        st_as_sfc()
    } else if (shape == "circle") {
      place_shape <- place_right %>%
        st_buffer(dist = units::set_units(dist_shape, "km"))
    }

    # Export place_shape
    place_shape <<- place_shape

    # Crop the layers
    roads_cropped <- st_intersection(roads_import, place_shape)
    water_cropped <<- st_intersection(water_import, place_shape)
    waterways_cropped <<-
      st_intersection(waterways_import, place_shape)
    railways_cropped <<-
      st_intersection(railways_import, place_shape)
    landuse_cropped <- st_intersection(landuse_import, place_shape)

    if (building == TRUE) {
      building_cropped <<-
        st_intersection(building_import, place_shape)
    }

    if (castle == TRUE) {
      castle_cropped <<-
        st_intersection(castle_import, place_shape)
    }

    # Clean roads
    roads_cleaned <<- roads_cropped %>%
      filter(!.data$fclass %in% c("steps", "footway", "living_street")) %>%
      mutate(
        newclass = str_remove(.data$fclass, "_link"),
        newclass = fct_other(
          .data$newclass,
          keep = c("trunk", "primary", "secondary", "tertiary"),
          other_level = "other"
        ),
        newclass = fct_relevel(
          .data$newclass,
          "trunk",
          "primary",
          "secondary",
          "tertiary",
          "other"
        )
      )

    # Filter forest
    forest <<- landuse_cropped %>%
      filter(.data$fclass == "forest")
  }

#' Plot the map
#'
#' @param region The name of the directory where you can find the shp
#' @param name_place The name of the place to plot
#' @param size_caption The size of the caption
#' @param width_out Output width in mm
#' @param height_out Output height in mm
#' @param place_shape_shp The shp of the place, default in GlobalEnv
#' @param roads_shp The shp of the roads, default in GlobalEnv
#' @param water_shp The shp of the water, default in GlobalEnv
#' @param waterways_shp The shp of the waterways, default in GlobalEnv
#' @param railways_shp The shp of the railways, default in GlobalEnv
#' @param forest_shp The shp of the forest, default in GlobalEnv
#' @param building_shp The shp of the building, no default
#' @param building Include the building layer
#' @param castle_shp The shp of the castles, no default
#' @param castle Include the castles
#'
#' @return A saved plot in maps/output
#'
#' @import sf
#' @import dplyr
#' @import ggplot2
#' @importFrom magrittr %>%
#'
#' @export
#'
map_art_gift_plot <- function(region,
                              name_place,
                              size_caption = 120,
                              width_out = 297,
                              height_out = 420,
                              place_shape_shp = place_shape,
                              roads_shp = roads_cleaned,
                              water_shp = water_cropped,
                              waterways_shp = waterways_cropped,
                              railways_shp = railways_cropped,
                              forest_shp = forest,
                              building = FALSE,
                              building_shp,
                              castle = FALSE,
                              castle_shp) {
  # plot the map
  map1 <- ggplot() +
    geom_sf(
      data = forest_shp,
      fill = "#228b22",
      size = 0.01,
      alpha = 0.4
    ) +
    geom_sf(
      data = water_shp,
      fill = "#9cd0d4",
      color = "#9cd0d4",
      size = 0.01
    ) +
    geom_sf(data = waterways_shp,
            color = "#9cd0d4",
            size = 0.5)

  # building or not
  if (building == TRUE) {
    map2 <- map1 +
      geom_sf(data = building_shp,
              fill = "grey60",
              size = 0.1)
  } else {
    map2 <- map1
  }

  if (castle == TRUE) {
    map3 <- map2 +
      geom_sf(data = castle_shp,
              fill = "grey80",
              size = 0.2)
  } else {
    map3 <- map2
  }

  map3 +
    geom_sf(data = railways_shp,
            col = "grey60",
            size = 0.2) +
    geom_sf(
      data = roads_shp %>% filter(.data$newclass == "other"),
      color = "grey50",
      size = 0.15
    ) +
    geom_sf(
      data = roads_shp %>% filter(.data$newclass != "other"),
      color = "grey40",
      size = 0.25
    ) +
    geom_sf(
      data = place_shape_shp,
      alpha = 0,
      color = "grey60",
      size = 1.5
    ) +
    labs(caption = name_place) +
    theme(
      legend.position = "none",
      plot.caption = element_text(
        color = "grey20",
        size = size_caption,
        hjust = .5,
        face = "plain",
        family = "Didot"
      ),
      panel.background = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank()
    )

  # save the map
  ggsave(
    paste0(
      "maps/output/",
      region,
      "_",
      name_place,
      "_",
      width_out,
      "_",
      height_out,
      ".png"
    ),
    width = width_out,
    height = height_out,
    units = "mm",
    dpi = "retina"
  )
}
