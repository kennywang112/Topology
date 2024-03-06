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
par(mfrow = c(1, 1))
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
      col = 2, border = NA, main = "kNN", d = 0.5, scale = FALSE,
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
# Rips Diagrams
par(mfrow = c(1, 2))
plot(DiagGrid[["diagram"]], rotated = TRUE, band = band[["width"]],
       main = "Rotated Diagram")
plot(DiagGrid[["diagram"]], barcode = TRUE, main = "Barcode")

Circle1 <- circleUnif(60)
Circle2 <- circleUnif(60, r = 2) + 3
Circles <- rbind(Circle1, Circle2)
maxscale <- 1
maxdimension <- 1
DiagRips <- ripsDiag(X = Circles, maxdimension, maxscale,
                     library = c("GUDHI", "Dionysus"), location = TRUE, printProgress = FALSE)

plot(Circles, col = 2, pch = 19, cex = 1.5)
lines(DiagRips$deathLocation)
plot(DiagRips[["diagram"]], main = "Rips Diagram")

# Alpha Complex Persistence Diagram
X <- circleUnif(n = 20)
DiagAlphaCmplx <- alphaComplexDiag(
  X = X, library = c("GUDHI", "Dionysus"), location = TRUE,
  printProgress = TRUE)
par(mfrow = c(1, 2))
plot(DiagAlphaCmplx[["diagram"]], main = "Alpha complex persistence diagram")
one <- which(DiagAlphaCmplx[["diagram"]][, 1] == 1)
one <- one[which.max(
  DiagAlphaCmplx[["diagram"]][one, 3] - DiagAlphaCmplx[["diagram"]][one, 2])]

plot(X, col = 1, main = "Representative loop")

for (i in seq(along = one)) {
  
  for (j in seq_len(dim(DiagAlphaCmplx[["cycleLocation"]][[one[i]]])[1])) {
    
    lines(DiagAlphaCmplx[["cycleLocation"]][[one[i]]][j, , ], pch = 19,
          cex = 1, col = i + 1)
  }
}
par(mfrow = c(1, 1))

# Persistence Diagram of Alpha Shape
n <- 30
X <- cbind(circleUnif(n = n), runif(n = n, min = -0.1, max = 0.1))
DiagAlphaShape <- alphaShapeDiag(
  X = X, maxdimension = 1, library = c("GUDHI", "Dionysus"), location = TRUE,
  printProgress = TRUE)
plot(DiagAlphaShape[["diagram"]], main = "Alpha Shape persistence diagram")

# Persistence Diagrams from Filtration
X <- circleUnif(n = 100)
maxscale <- 0.4 # limit of the filtration
maxdimension <- 1 # components and loops
FltRips <- ripsFiltration(X = X, maxdimension = maxdimension,
                          maxscale = maxscale, dist = "euclidean", library = "GUDHI",
                          printProgress = TRUE)
par(mfrow = c(1, 2))
plot(DiagAlphaShape[["diagram"]])
plot(X[, 1:2], col = 2, main = "Representative loop of alpha shape filtration")
one <- which(DiagAlphaShape[["diagram"]][, 1] == 1)
one <- one[which.max(
  DiagAlphaShape[["diagram"]][one, 3] - DiagAlphaShape[["diagram"]][one, 2])]
for (i in seq(along = one)) {
  for (j in seq_len(dim(DiagAlphaShape[["cycleLocation"]][[one[i]]])[1])) {
    lines(
      DiagAlphaShape[["cycleLocation"]][[one[i]]][j, , 1:2], pch = 19,
      cex = 1, col = i)
    }
  }
par(mfrow = c(1, 1))

m0 <- 0.1
dtmValues <- dtm(X = X, Grid = X, m0 = m0)
FltFun <- funFiltration(FUNvalues = dtmValues, cmplx = FltRips[["cmplx"]])
DiagFltFun <- filtrationDiag(filtration = FltFun, maxdimension = maxdimension,
                             library = "Dionysus", location = TRUE, printProgress = TRUE)
par(mfrow = c(1, 2))
plot(X, pch = 16, xlab = "",ylab = "")
plot(DiagFltFun[["diagram"]], diagLim = c(0, 1))


# Bottleneck and Wasserstein Distances
Diag1 <- ripsDiag(Circle1, maxdimension = 1, maxscale = 5)
Diag2 <- ripsDiag(Circle2, maxdimension = 1, maxscale = 5)
print(bottleneck(Diag1[["diagram"]], Diag2[["diagram"]], dimension = 1))
print(wasserstein(Diag1[["diagram"]], Diag2[["diagram"]], p = 2, dimension = 1))
maxscale <- 5
tseq <- seq(0, maxscale, length = 1000) #domain
Land <- landscape(DiagRips[["diagram"]], dimension = 1, KK = 1, tseq)
Sil <- silhouette(DiagRips[["diagram"]], p = 1, dimension = 1, tseq)
plot(tseq, Land, type = "l", xlab = "t", ylab = "Landscape")
plot(tseq, Sil, type = "l", xlab = "t", ylab = "Silhouette")
N <- 4000
XX1 <- circleUnif(N / 2)
XX2 <- circleUnif(N / 2, r = 2) + 3
X <- rbind(XX1, XX2)

