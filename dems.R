library(raster)
library(rhdf5)
library(rgdal)

# load digital terrain model
dtm <- raster('../NEONdata/D17-California/TEAK/2013/lidar/TEAK_lidarDTM.tif')
dtm[dtm == 0] <- NA
plot(dtm, main = 'canopy height')
hist(dtm, xlab = 'canopy height (m)')

# shading
sv <- normalvector(50, 270)
normal_vecs <- cgrad(dtm)
hsh <- normal_vecs[, , 1] * sv[1] +
        normal_vecs[, , 2] * sv[2] +
        normal_vecs[, , 3] * sv[3]
hsh <- (hsh + abs(hsh)) / 2
hsh <- raster(hsh,crs = projection(dtm))
extent(hsh) <- extent(dtm)
plot(hsh, col = grey(1:100/100), legend = FALSE)

aspect <- raster('../NEONdata/D17-California/TEAK/2013/lidar/TEAK_lidarAspect.tif')
plot(aspect, axes = FALSE)

# classify N and S facing slopes
classifications <- c(0, 45, 1,
                     45, 135, NA,
                     135, 225, 2,
                     225, 315, NA,
                     315, 360, 1)
classmat <- matrix(classifications, nrow = 5, byrow = T)
northsouth <- reclassify(aspect, classmat)
plot(northsouth)

# mask data
ndvi <- raster('../NEONdata/D17-California/TEAK/2013/spectrometer/veg_index/TEAK_NDVI.tif')
plot(ndvi)

# only consider ndvi in north or south facing slopes
ns_ndvi <- mask(ndvi, northsouth)
plot(ns_ndvi)
