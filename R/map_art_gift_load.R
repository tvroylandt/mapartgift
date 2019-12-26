#' Load the data
#'
#' @param region The name of the directory where you can find the shp
#' @param name_place The name of the place to plot
#' @param crs The EPSG CRS, default to Mercator (3785)
#' @param dist_shape The distance to plot around the plot
#' @param shape The shape, circle or square, default to circle
#' @param building Include the building layer
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
           building = FALSE) {
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
    railways_cropped <<-
      st_intersection(railways_import, place_shape)
    landuse_cropped <- st_intersection(landuse_import, place_shape)

    if (building == TRUE) {
      building_cropped <<-
        st_intersection(building_import, place_shape)
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
