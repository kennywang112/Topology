library(TDA)
library(tidyverse)

X <- circleUnif(400)
as.data.frame(X)%>%ggplot(aes(x1, x2))+geom_point()
Xlim <- c(-1.6, 1.6)
Ylim <- c(-1.7, 1.7)
by <- 0.065
Xseq <- seq(Xlim[1], Xlim[2], by = by)
Yseq <- seq(Ylim[1], Ylim[2], by = by)
Grid <- expand.grid(Xseq, Yseq)
par(mfrow = c(1, 2))
plot(X, col = 2, pch = 19, cex = 1.5)
plot(Grid, col = 2, pch = 19, cex = 1.5)

m0 <- 0.1
# distance to measure
DTM <- dtm(X = X, Grid = Grid, m0 = m0)
persp(Xseq, Yseq,
      matrix(DTM, ncol = length(Yseq), nrow = length(Xseq)), xlab = "",
      ylab = "", zlab = "", theta = -20, phi = 35, ltheta = 50,
      col = 2, border = NA, main = "DTM", d = 0.5, scale = FALSE,
      expand = 3, shade = 0.9)
k <- 60
# k Nearest Neighbor density estimator
kNN <- knnDE(X = X, Grid = Grid, k = k)
persp(Xseq, Yseq,
      matrix(kNN, ncol = length(Yseq), nrow = length(Xseq)), xlab = "",
      ylab = "", zlab = "", theta = -20, phi = 35, ltheta = 50,
      col = 2, border = NA, main = "KDE", d = 0.5, scale = FALSE,
      expand = 3, shade = 0.9)
h <- 0.3
# Gaussian Kernel Density Estimator
KDE <- kde(X = X, Grid = Grid, h = h)
persp(Xseq, Yseq,
      matrix(KDE, ncol = length(Yseq), nrow = length(Xseq)), xlab = "",
      ylab = "", zlab = "", theta = -20, phi = 35, ltheta = 50,
      col = 2, border = NA, main = "KDE", d = 0.5, scale = FALSE,
      expand = 3, shade = 0.9)

Kdist <- kernelDist(X = X, Grid = Grid, h = h)
persp(Xseq, Yseq,
      matrix(Kdist, ncol = length(Yseq), nrow = length(Xseq)), xlab = "",
      ylab = "", zlab = "", theta = -20, phi = 35, ltheta = 50,
      col = 2, border = NA, main = "Kdist", d = 0.5, scale = FALSE,
      expand = 3, shade = 0.9)
# Persistent Homology
# 計算該平面的信賴區間
band <- bootstrapBand(X = X, FUN = kde, Grid = Grid, B = 100,
                      parallel = FALSE, alpha = 0.1, h = h)
# 構造下層集或上層集的過濾
DiagGrid <- gridDiag(
  X = X, FUN = kde, h = 0.3, lim = cbind(Xlim, Ylim), by = by,
  sublevel = FALSE, library = "Dionysus", location = TRUE,
  printProgress = FALSE)
plot(DiagGrid[["diagram"]], band = 2 * band[["width"]],
    main = "KDE Diagram")



data(iris)
iris%>%ggplot()+geom_point(aes(Sepal.Length, Petal.Length, color = Species))
Xiris <- iris%>%select(Sepal.Length, Petal.Length)
Xiris$Sepal.Length%>%summary()
Xiris$Petal.Length%>%summary()
Xlim <- c(1, 8)
Ylim <- c(1, 8)
by <- 0.05
Xseq <- seq(Xlim[1], Xlim[2], by = by)
Yseq <- seq(Ylim[1], Ylim[2], by = by)
Grid <- expand.grid(Xseq, Yseq)
# Grid%>%ggplot()+geom_point(aes(Var1, Var2))
par(mfrow = c(1, 2), bg = "gray")
KDE <- kde(X = Xiris, Grid = Grid, h = 0.3)
# iris_dist <- distFct(X = Xiris, Grid = Grid)
persp(Xseq, Yseq,
      matrix(KDE, ncol = length(Yseq), nrow = length(Xseq)), xlab = "",
      ylab = "", zlab = "", theta = 30, phi = 20, ltheta = 50,
      border = NA, main = "distance", d = 0.5, scale = FALSE, box = TRUE, col = "brown",
      expand = 3, shade = 0.9)
plot(Xiris, col = iris$Species, pch = 19, cex = 1.5)

