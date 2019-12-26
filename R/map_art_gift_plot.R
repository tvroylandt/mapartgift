#' Plot the map
#'
#' @param region The name of the directory where you can find the shp
#' @param name_place The name of the place to plot
#' @param size_caption The size of the caption
#' @param width_out Output width in mm
#' @param height_out Output height in mm
#' @param place_shape The shp of the place, default in GlobalEnv
#' @param roads The shp of the roads, default in GlobalEnv
#' @param water The shp of the water, default in GlobalEnv
#' @param railways The shp of the railways, default in GlobalEnv
#' @param forest The shp of the forest, default in GlobalEnv
#' @param building The shp of the building, default in GlobalEnv
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
                              place_shape = place_shape,
                              roads = roads_cleaned,
                              water = water_cropped,
                              railways = railways_cropped,
                              forest = forest,
                              building = building_cropped) {
  # plot the map
  ggplot() +
    geom_sf(
      data = forest,
      fill = "#228b22",
      size = 0.01,
      alpha = 0.4
    ) +
    geom_sf(data = water,
            fill = "#9cd0d4",
            size = 0.01) +
    geom_sf(data = building,
            fill = "grey60",
            size = 0.1) +
    geom_sf(data = railways, col = "grey60", size = 0.2) +
    geom_sf(
      data = roads %>% filter(.data$newclass == "other"),
      color = "grey50",
      size = 0.15
    ) +
    geom_sf(
      data = roads %>% filter(.data$newclass != "other"),
      color = "grey40",
      size = 0.25
    ) +
    geom_sf(
      data = place_shape,
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
