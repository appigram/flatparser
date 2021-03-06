
## con <- url("http://www.filefactory.com/file/2ir1obxgapwh/n/RUS_adm0_RData")
## #cont <- url("http://www.filefactory.com/file/4h1hb5c1cw7r/n/RUS_adm1_RData")
## #cont <- url("http://www.filefactory.com/file/2fhky60dukb3/n/RUS_adm2_RData")
## #cont <- url("http://www.filefactory.com/file/1wlahf4eyuet/n/RUS_adm3_RData")
## con <- url("http://gadm.org/data/rda/RUS_adm2.RData")
## print(load(con))
## close(con)

## library(maptools)
## msk <- readShapeLines("moskva/moskva_natural.shp")
## lines(msk)


## df <- data.frame(lat=c(1, 3, 2, 4, 15, 18, 13, 14), lon=c(2, 1, 4, 4, 16, 19, 11, 13), price=c(65000, 67000, 130000, 125000, 70000, 75000, 55000, 60000))


## library(googleVis)
## loc <- paste(dat0$lat, dat0$lon, sep=":")
## geo <- cbind(dat["price"], loc)
## G <- gvisGeoChart(geo, locationvar = "loc", colorvar = "price",
##                   options = list(displayMode = "Markers",
##                     colorAxis = "{colors:['purple', 'red', 'orange', 'grey']}",
##                     backgroundColor="lightblue",
##                     resolution="provinces",
##                     region="BY"),
##                   chartid="Offices")
## plot(G)



initial <- read.csv("../dataset.csv")
dat <- initial
dat <- dat[dat[2] == "офис", ]
dat <- dat[, !apply(is.na(dat), 2, all)]  # remove all columns with NAs only
dat <- dat[!is.na(dat["price"]), ]        # remove data without price
dat <- dat[c("price", "size_t", "dist_to_subway", "dist_to_kp", "state",
             "floor", "floors", "year_built", "walls")]

naToMean <- function(v) {
  # m <- colMeans(v, na.rm = TRUE)
  m <- mean(v, na.rm = TRUE)
  v[is.na(v)] <- m
  v
}

naToMode <- function(v) {
  tbl <- table(v)
  md <- tbl[which.max(tbl)]
  v[is.na(v)] <- attr(md, "names")
  v  
}

dat$size_t <- naToMean(dat$size_t)
dat$dist_to_subway <- naToMean(dat$dist_to_subway)
dat$dist_to_kp <- naToMean(dat$dist_to_kp)
dat$floor <- naToMean(dat$floor)
dat$floors <- naToMean(dat$floors)
dat$year_built <- naToMean(dat$year_built)

dat$state <- naToMode(dat$state)
dat$walls <- naToMode(dat$walls)

library(dummies)
myDummy <- function(name, df) {
  d <- dummy(name, data = df)
  l <- dim(d)[2]
  d[, -c(l)]
}


# reconstruct data frame

dat.num <- dat[-c(4, 5, 9)]  # - (dist_to_kp, state, walls)
dummy.state <- dummy("state", dat)
dummy.walls <- dummy("walls", dat)
final <- cbind(dat.num, dummy.state[, -1], dummy.walls[, -1])
names(final) <- c("price", "size.t", "dist.to.subway", "floor",         
                  "floors", "year.built", "state.normal", "walls.brick",   
                  "walls.monolit", "walls.panel")


# building model

# model <- lm(price ~ ., data = final)
# model <- lm(price ~ size.t + offset(2 * dist.to.subway) + floor + floors +
#              year.built + state.normal + walls.brick + walls.monolit +
#              walls.panel, final)
model <- lm(price ~ dist.to.subway + year.built + state.normal +
            walls.brick + walls.monolit + walls.panel,
            final)

price <- final$price
cost <- predict(model, final)
rank <- sort(price / cost)
urls <- initial[names(rank), "url"]

# visualisation

plot(density(price))


plot(cost, price)
l <- lm(price ~ cost)
abline(l)


lats <- c(53.9084306, 53.9056244, 53.9153569, 53.9388635, 53.9279837, 53.8936547, 53.9344835, 53.8623126, 53.8690346, 53.94535219999999, 53.9018129, 53.9091227, 53.9064619, 53.9241648, 53.9065756, 53.9054617, 53.8896343, 53.9095682, 53.8864055, 53.8768861, 53.9073688, 53.8926937, 53.9211795, 53.889564)

lons <- c(27.4793762 27.5378537 27.5828397 27.6670396 27.6278204 27.5701582 27.6513112 27.674346 27.6474166 27.687875 27.5607115 27.5747555 27.5213796 27.6133633 27.4545872 27.5544432 27.5856077 27.4985433 27.53721 27.6268709 27.4351037 27.5477886 27.5977689 27.6156753)

lt14.names <- rownames(final[final$price <= 14, 1:2])
lt14.urls <- initial[lt14.names, "url"]
