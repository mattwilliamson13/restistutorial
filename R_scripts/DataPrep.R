library(raster)
library(sp)
library(sf)
library(rgeos)
library(rgdal)
library(tidyverse)
hm.us <- raster("/Users/mattwilliamson/Analyses/ConservationResistance/Data/OriginalData/hm_fsum3_270/")


gap.status.WY <- st_read("~/Google Drive/My Drive/Data/Original Data/PAD_US2_1_GDB/PADUS_21_CombFeeDes.shp") %>% 
  filter(State_Nm=="WY" & GAP_Sts == "1" & GIS_Acres >50000) %>% 
  st_make_valid() 

st_crs(gap.status.WY) <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"

gap.status.WY <- gap.status.WY %>% st_transform(., st_crs(hm.us))
st_write(gap.status.WY, "Data/wy_gap1.shp", append=FALSE)

hm.crop <- crop(hm.us, gap.status.WY)
writeRaster(hm.crop, "Data/human_mod.tif")

elev <- getData('alt', country = "USA")


elev <- crop(elev[[1]], extent(-120, -102, 38, 50))
elev.p <- projectRaster(elev, crs = "+proj=aea +lat_0=37.5 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs", res= 270)

elev.crop <- crop(elev.p, hm.crop)
elev.p <- projectRaster(elev.crop, hm.crop)

writeRaster(elev.p, "Data/elevation_agg.tif", overwrite = TRUE)

