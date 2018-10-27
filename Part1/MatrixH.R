# ================================================
#' @description Generates bandwidth matrix, scale and rotation matrex
#' @param tet angle of probe ellipse rotation
#' @param rx ellipse radius along x
#' @param ry ellipse radius along y
#' @return list(H, M, R) 
MatrixH <- function(tet=0, rx=1, ry=1) {
      # rotation matrix. to implement probe ellipse rotation
      R <- matrix(c(cos(tet), -sin(tet), sin(tet), cos(tet)), nrow = 2, byrow=TRUE)
      # scale matrix
      M <- matrix(c(rx,0,0,ry), nrow=2, byrow=TRUE)
      
      # make H matrix, with scaling and rotation
      # since in kde function H matrix will be inverted, 
      # here we construct H as inverted of inverted scale matrix with rotation matrix.
      ret <-  list(H = solve( R %*% solve(M) %*% t(R) ))
      ret$M <- M        # scale matrix to draw ellipse
      ret$R <- R        # rotation matrix to draw ellipse
      ret
}