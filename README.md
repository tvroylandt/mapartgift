
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Create map as a gift

The goal of mapartgift is to help create beautiful maps from
OpenStreetMaps layers for your colleagues and family.

It is deeply inspired (almost forked) from
<https://taraskaduk.com/2019/12/20/print-maps/> and
<https://erdavis.com/2019/07/27/the-beautiful-hidden-logic-of-cities/>

## Installation

You can install the package with

``` r
devtools::install_github("tvroylandt/mapartgift")
```

## Package

The package contains two functions :

  - one to load the data ;
  - one to plot the map.

The fist step is to download the shapefiles into
maps/shapefiles/region\_name which can be done with the following chunk
:

``` r
# url <- "http://download.geofabrik.de/europe/france/picardie-latest-free.shp.zip"
# curl::curl_download(url, destfile = "picardie.shp.zip")
# unzip("picardie.shp.zip", exdir = "inst/shapefiles/picardie")
```

After that you can make some maps. Just be careful with the CRS.

``` r
library(mapartgift)
library(tidyverse)
#> ── Attaching packages ───────────────────────────────────────────────────────────────────────────── tidyverse 1.2.1 ──
#> ✓ ggplot2 3.2.1     ✓ purrr   0.3.3
#> ✓ tibble  2.1.3     ✓ dplyr   0.8.3
#> ✓ tidyr   1.0.0     ✓ stringr 1.4.0
#> ✓ readr   1.3.1     ✓ forcats 0.4.0
#> ── Conflicts ──────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()

# map_art_gift_load(region = "picardie", name_place = "Chantilly", crs = 2154)
# map_art_gift_plot(region = "picardie", name_place = "Chantilly")
```
