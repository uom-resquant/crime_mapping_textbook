# W1 intro to place and crime & how crime concentrates
# W2 more theory behind spatial elements of criminology and about neighbourhoods
# W3 counts v rates and finding the right denominator
# W4 generators/attractors/concentration law
# W5 issues in geography of crime (population variation, MAUP)

# creating neighbourhoods
# think about definitions
# the technical bits:

library(sf)
library(dplyr)
library(ggplot2)

mcr_lsoas <- st_read("data/BoundaryData/manchester_crime_lsoa.shp")
mcr_wards <- st_read("data/BoundaryData/england_wd_2022.shp")

ggplot() +
  geom_sf(data = mcr_lsoas, col = "grey") +
  geom_sf(data = mcr_wards, col = "green") +
  geom_sf(data = city_centre, col = "red") +
  theme_void()


# select only the city centre ones
city_centre <- mcr_wards %>% filter( wd22nm %in% c("Piccadilly", "Deansgate"))

# use st_intersect to create new object that contains only the lsoas ffrom mcr_lsoas that fall in the city_centre wards
city_centre_lsoas <- st_intersection(mcr_lsoas, city_centre)

ggplot() +
  geom_sf(data = city_centre_lsoas, col = "black") +
  geom_sf(data = city_centre, col = "red") +
  theme_void()
