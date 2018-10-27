#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(ggplot2)
library(data.table)
library(shiny)
library(leaflet)
library(ks)
library(RColorBrewer)

source('MatrixH.R')
source('DrawBandWidth.R')

# There are two clear planes of seismic activity. 
# One is a major plate junction; the other is the Tonga trench off 
# New Zealand. These data constitute a subsample from a larger dataset 
# of containing 5000 observations.
# https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/quakes.html

data(quakes)  # data set

# Format
# A data frame with 1000 observations on 5 variables.
# 
# [,1]	lat	numeric	Latitude of event
# [,2]	long	numeric	Longitude
# [,3]	depth	numeric	Depth (km)
# [,4]	mag	numeric	Richter Magnitude
# [,5]	stations	numeric	Number of stations reporting

quakes <- as.data.table(quakes)  # convert to data.table
v <- 10^(quakes$mag-4)
quakes[, weights := v / mean(v) ] # weights by magnitude

# ================================================
# Define server logic
shinyServer(function(input, output) {

      output$quakesMap <- leaflet::renderLeaflet({
            # Initiate map
            leaflet(data=quakes, 
                    options=leafletOptions(maxZoom=13, minZoom=3)) %>%
            addTiles() %>%      
            setView(175.46, -25, 5)  
                  
      })
  
      # redraw map
      observe({
      
        BandWidth <- MatrixH(input$teta/90 * pi/2, 10^input$rx, 10^input$ry)
        k <- 100              # number of grid devisions
        H <- BandWidth$H      # bandwidth matrix
        
        # calculate kernal density weited by magnitude or not
        if(input$isWeighted) {
              fhat <- ks::kde(quakes[,1:2], 
                          H = H,
                          w = quakes$weights,
                          bgridsize=c(k,k))
        }  else {
              fhat <- ks::kde(quakes[,1:2], 
                          H = H,
                          bgridsize=c(k,k))
        }
        
        # evaluation points
        DF <- data.frame(x=fhat$eval.points[[1]], y=fhat$eval.points[[2]])
        # density contours
        CL <- contourLines( DF$x, DF$y, fhat$estimate, nlevels=input$nLevels )
        
        # calculate colors ramp for lavels      
        maxLevel <- max(sapply(CL, function(x) {x$level}))
        cRamp <- colorRamp(rev( brewer.pal(4, "RdYlBu" )))
        
        # make leaflet proxy
        llp <- leaflet::leafletProxy("quakesMap", data=quakes) %>%
                  clearShapes()

        # add density level contourse
        for(i in 1:length(CL)) {
              lev <- CL[[i]]$level
              if (lev > 0) {
                    llp <- addPolygons(llp, 
                              lng=~y, lat=~x, data=CL[[i]], 
                              color=rgb(cRamp(lev/maxLevel)/255), 
                              weight=1)
              }
        }           
        
        # draw circles
        addCircles(llp,lng=~long, lat=~lat,
                 radius = ~10^(mag-1.5),
                 weight = 1, color = "green") 
      
        # draw demo probe ellipse
        output$ellipse <- renderPlot({
              DrawBandWidth(BandWidth)
        })
        
        output$hmatrix <- renderPrint({
              print(BandWidth$H)
        })

      })
  
})


