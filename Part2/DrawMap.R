#' Draw quake map
#' @param theta bandsidth rotation angle
#' @param rx ellipse rx radius
#' @param ry ellipse ry radius 
#' 
DrawMap <- function(theta, rx, ry, nLevels) {
      
      # Initiate map
      ll <- leaflet(data=quakes, 
                    options=leafletOptions(maxZoom=13, minZoom=3)) %>%
            addTiles() %>%      
            setView(175.46, -25, 5)  
      
      # bandsidth matrix
      BandWidth <- MatrixH(theta, rx, ry)
      
      
      k <- 100              # number of grid devisions
      H <- BandWidth$H      # bandwidth matrix
      
      # calculate kernal density weited by magnitude or not
      fhat <- ks::kde(quakes[,1:2], 
                      H = H,
                      w = quakes$weights,
                      bgridsize=c(k,k))
      
      # evaluation points
      DF <- data.frame(x=fhat$eval.points[[1]], y=fhat$eval.points[[2]])
      # density contours
      CL <- contourLines( DF$x, DF$y, fhat$estimate, nlevels=nLevels )
      
      # calculate colors ramp for lavels      
      maxLevel <- max(sapply(CL, function(x) {x$level}))
      cRamp <- colorRamp(rev( brewer.pal(4, "RdYlBu" )))
      
      # add density level contours
      for(i in 1:length(CL)) {
            lev <- CL[[i]]$level
            if (lev > 0) {
                  ll <- addPolygons(ll, 
                                    lng=~y, lat=~x, data=CL[[i]], 
                                    color=rgb(cRamp(lev/maxLevel)/255), 
                                    weight=1)
            }
      }           
      
      # draw circles
      addCircles(ll,lng=~long, lat=~lat,
                 radius = ~10^(mag-1.5),
                 weight = 1, color = "green") 
} 