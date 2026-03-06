
# different numbers for licenced premises
lic_prem <- read.csv("data/LicensedPremises.csv")
library(readr)
lic_prem <- read_csv("data/LicensedPremises.csv")
library(dplyr)

lic_prem <- lic_prem %>%
  filter(!if_all(everything(), is.na))

lic_prem <- lic_prem %>%
  filter(ALCOHOLSUPPLY == TRUE)

# what to do with missing values

# we came across this in week 2, we have missing coords in stop search
library(sf)
stopsearch <- read.csv("data/2019-06-greater-manchester-stop-and-search.csv")

stopsearch_sf <- st_as_sf(stopsearch,
                          coords = c('Longitude', 'Latitude'),
                          crs = 4326,
                          na.fail = FALSE) # without this it will fail because there are missing coords!

# so you can choose to exclude or to include but not map
# in either case these data are missing, NA means we have no idea where these are

# However not always the case. Think about this week.
# We have

alt_ss_per_lsoa <- st_read("data/alt_ss_per_lsoa.geojson")

ggplot() +
  geom_sf(data = alt_ss_per_lsoa, aes(fill = n))

# Not does missing really mean missing? Think about it!
library(tidyr)

alt_ss_per_lsoa <- alt_ss_per_lsoa %>% mutate(n = replace_na(n, 0))

ggplot() +
  geom_sf(data = alt_ss_per_lsoa, aes(fill = n))


st_crs(alt_ss_per_lsoa) == st_crs(stopsearch_sf)





st_crs(ss_sf) == st_crs(greater_manchester)

gm_intersects <- st_intersects(greater_manchester, ss_sf)
gm_intersects <- ss_sf[unlist(gm_intersects),]








