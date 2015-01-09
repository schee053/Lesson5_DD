# Names: Daniel Scheerooren & Jorn Dallinga
# Team: DD
# Date: 9-1-2015

# Downloading data
# done manually
getwd()
# load sp package
library(sp)
library(rgdal)
library(rgeos)

# Start of selecting industrial railways

list.files("data/netherlands-places-shape")
railways_listfiles <- list.files("data/netherlands-railways-shape/")

# reading shapefile for places
dsn <- file.path("data/netherlands-places-shape","places.shp")
ogrListLayers(dsn)
places <- readOGR(dsn, layer = ogrListLayers(dsn))
plot(places)

# reading shpaefile for railways
dsn1 <- file.path("data/netherlands-railways-shape", "railways.shp")
ogrListLayers(dsn1)
railways <- readOGR(dsn1, layer = ogrListLayers(dsn1))
plot(railways)

# Loading project systems

prj_string_RD <- CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.2369,50.0087,465.658,-0.406857330322398,0.350732676542563,-1.8703473836068,4.0812 +units=m +no_defs")

# transform railways and places from WGS to RDNew (Projected)

places_RD <- spTransform(places, prj_string_RD)
Railways_RD <- spTransform(railways, prj_string_RD)

# Extract 'industrial' railway type from shapefile

industrial_RW <- Railways_RD[Railways_RD$type == "industrial", ]
plot(industrial_RW)

# Apply a 1000 meter buffer to industrial railways
Buffer_IRW <- gBuffer(industrial_RW, byid=TRUE, id=NULL, width=1000.0, quadsegs=5, capStyle="ROUND",
        joinStyle="ROUND", mitreLimit=1.0)

# Apply an intersect on the buffer and places.shp
Intersect <- gIntersection(Buffer_IRW, places_RD, byid=FALSE, id=NULL, drop_lower_td=FALSE)

# Find name of intersecting place, in places shapefile.
intersect_place <- gIntersects(Buffer_IRW, places_RD, byid = TRUE)
places_RD@data[intersect_place]

# Plot buffer zone and Utrecht
plot(Buffer_IRW, col="gray80")
plot(Intersect, add=TRUE)

# City: Utrecht. Population: 100,000 inhabitants
box()