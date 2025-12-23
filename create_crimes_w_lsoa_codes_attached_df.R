library(dplyr)
library(sf)
library(ggplot2)

crimes <- read.csv("data/2019-06-greater-manchester-street.csv")
# transform to a sf object, but keep the longitude and latitude columns
crimes_sf <- st_as_sf(crimes, coords = c("Longitude", "Latitude"), crs = 4326, remove = FALSE)
all_lsoa <- st_read("data/BoundaryData/gm_lsoa_2021.shp")

ggplot() +
  geom_sf(data = all_lsoa) +
  geom_sf(data = crimes_sf) +
  geom_sf(data = crimes_w_lsoa %>% filter(is.na(lsoa21cd)), col = "red")


# Reproject crimes_sf to BNG
crimes_sf <- st_transform(crimes_sf, st_crs(all_lsoa))

# Now join to each point in crimes_sf df the code of the LSOA (from column "lsoa21cd") in which it falls
crimes_w_lsoa <- st_join(crimes_sf, all_lsoa[, c("lsoa21cd", "lsoa21nm")], join = st_within)
# There are 15 cases where the points are not within any LSOA. For these ones, join to the nearest LSOA
crimes_w_lsoa_na <- crimes_w_lsoa %>% filter(is.na(lsoa21cd)) %>% select(!c(lsoa21cd, lsoa21nm))
crimes_w_lsoa_na <- st_join(crimes_w_lsoa_na, all_lsoa[, c("lsoa21cd", "lsoa21nm")], join = st_nearest_feature)
# replace the NA values in the crimes_w_lsoa with these
crimes_w_lsoa <- crimes_w_lsoa %>% filter(!is.na(lsoa21cd)) %>% bind_rows(crimes_w_lsoa_na) %>%
  # remove old lsoa columns
  select(!c(LSOA.code, LSOA.name))

# View(crimes_w_lsoa)
# crimes_w_lsoa %>% filter(lsoa21cd != LSOA.code) %>% View()
#
# sum(is.na(crimes_w_lsoa$lsoa21cd))

write.csv(st_drop_geometry(crimes_w_lsoa), "data/crimes_w_lsoa_codes_attached.csv", row.names = FALSE)


# DO the same for the stop and search data
stopsearch_w_lsoa <- read.csv("data/2019-06-greater-manchester-stop-and-search.csv")
stopsearch_sf <- st_as_sf(stopsearch_w_lsoa, coords = c("Longitude", "Latitude"), crs = 4326, remove = FALSE, na.fail = FALSE)
stopsearch_sf <- st_transform(stopsearch_sf, st_crs(all_lsoa))
stopsearch_w_lsoa <- st_join(stopsearch_sf, all_lsoa[, c("lsoa21cd", "lsoa21nm")], join = st_within)
stopsearch_w_lsoa_na <- stopsearch_w_lsoa %>% filter(is.na(lsoa21cd)) %>% select(!c(lsoa21cd, lsoa21nm))
stopsearch_w_lsoa_na <- st_join(stopsearch_w_lsoa_na, all_lsoa[, c("lsoa21cd", "lsoa21nm")], join = st_nearest_feature)
stopsearch_w_lsoa <- stopsearch_w_lsoa %>% filter(!is.na(lsoa21cd)) %>% bind_rows(stopsearch_w_lsoa_na)
write.csv(st_drop_geometry(stopsearch_w_lsoa), "data/ss_with_lsoa.csv", row.names = FALSE)

