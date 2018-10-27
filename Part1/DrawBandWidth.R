# ================================================
# Here are some data describing some circle for elipce draw
r <-  1
fi <- seq(0, 2*pi, by=2*pi/100)
circleData <- data.frame(x = r*sin(fi), y=r*cos(fi))

# ================================================
#' @description  Draw probe demo ellipse of rotated bandwidth matrix
#' @param bandWidth value of list(H, M, R) from MatrixH()
#'
DrawBandWidth <- function(bandWidth) {
      # demo ellipse scaling and rotation
      data <- as.data.frame(as.matrix(circleData) %*% bandWidth$M %*% t(bandWidth$R))
      ggplot(data, aes(V2, V1)) + 
            geom_polygon(aes(alpha=.6)) + 
            coord_fixed(xlim = c(-10,10), ylim = c(-10,10)) +
            theme_minimal()+
            theme(axis.title.x=element_blank(),
                  axis.text.x=element_blank(),
                  axis.ticks.x=element_blank(),
                  axis.title.y=element_blank(),
                  axis.text.y=element_blank(),
                  axis.ticks.y=element_blank(),
                  legend.position="none"
            )      
}