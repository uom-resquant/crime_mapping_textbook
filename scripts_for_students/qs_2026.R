library(sf)
library(ggplot2)
library(dplyr)

crimes <- read.csv("data/2019-06-greater-manchester-street.csv")
crimes_sf <- st_as_sf(crimes,
                      coords = c("Longitude", "Latitude"),
                      crs = 4326
                      )
ggplot() +
  geom_sf(data = crimes_sf, shape = 8) +
  theme_void()

boundary <- st_read(file.choose())
st_write(boundary, "data/mcr_boundary.geojson")


mcr_lsoa <- st_read("data/cc_lsoas.geojson")

mcr_lsoa_w_area_size <- mcr_lsoa %>%
  mutate(lsoa_area = st_area(.))



crimes_per_prem_snapped <- crimes_per_prem_snapped %>%
  mutate(radius_m = pmax(n * 3, 30))  # 30 m minimum, scale factor = 5

leaflet(crimes_per_prem_snapped %>%  st_cast("POINT")) %>%
  addTiles() %>%
  addCircles(radius = crimes_per_prem_snapped$radius_m,
             fillColor = ~pal(n), fillOpacity = 0.8,
             weight = 1, opacity = 1, color = "black",
             label = ~as.character(nearest_prem)) %>%
  addLegend(pal = pal, values = ~n, opacity = 0.7,
            title = 'Violent crimes', position = "bottomleft")


# now recreate the above map but with hexagon shape instead of circles
make_hexagon <- function(lon, lat, radius_m) {
  angles <- seq(30, 360 + 30, by = 60) * pi / 180
  # Convert radius from meters to degrees (approximate)
  radius_deg_lat <- radius_m / 111320
  radius_deg_lon <- radius_m / (111320 * cos(lat * pi / 180))

  hex_coords <- matrix(
    c(lon + radius_deg_lon * cos(angles),
      lat + radius_deg_lat * sin(angles)),
    ncol = 2
  )
  st_polygon(list(hex_coords))
}

points_df <- crimes_per_prem_snapped %>% st_cast("POINT")
coords <- st_coordinates(points_df)

hexagons <- mapply(
  make_hexagon,
  lon    = coords[, "X"],
  lat    = coords[, "Y"],
  radius = points_df$radius_m,
  SIMPLIFY = FALSE
)

hex_sf <- st_sf(
  points_df %>% st_drop_geometry(),
  geometry = st_sfc(hexagons, crs = 4326)
)

leaflet(hex_sf) %>%
  addTiles() %>%
  addPolygons(
    fillColor  = ~pal(n), fillOpacity = 0.8,
    weight     = 1, opacity = 1, color = "black",
    label      = ~as.character(nearest_prem)
  ) %>%
  addLegend(pal = pal, values = ~n, opacity = 0.7,
            title = 'Violent crimes', position = "bottomleft")


