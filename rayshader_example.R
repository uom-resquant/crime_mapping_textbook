# install.packages("rayshader", dependencies = T)
library(readr)
library(sf)
library(dplyr)
library(ggplot2)
library(rayshader)

mcr_asb <- read_csv("data/manchester_asb.csv")
sf_mcr_asb<- st_as_sf(mcr_asb, coords = c("Longitude", "Latitude"),
                      crs = 4326, agr = "constant", remove = FALSE) %>%
  rename(lng = Longitude,
         lat = Latitude)

asb_map <- ggplot(sf_mcr_asb, aes(lng, lat)) +                        #define data and variables for x and y axes
  stat_binhex() +                                                         #add binhex layer (hexbin)
  scale_fill_gradientn(colours = c("white","red"), name = "Frequency")    #add shading based on number of ASB incidents


plot_gg(asb_map, shadow_intensity = 0.5)

