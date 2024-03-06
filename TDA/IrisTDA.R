library(TDA)
library(tidyverse)

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
kNN <- knnDE(X = Xiris, Grid = Grid, k = 60)
# iris_dist <- distFct(X = Xiris, Grid = Grid)
persp(Xseq, Yseq,
      matrix(KDE, ncol = length(Yseq), nrow = length(Xseq)), xlab = "",
      ylab = "", zlab = "", theta = 30, phi = 20, ltheta = 50,
      border = NA, main = "KDE", d = 0.5, scale = FALSE, box = TRUE, col = "brown",
      expand = 3, shade = 0.9)
persp(Xseq, Yseq,
      matrix(kNN, ncol = length(Yseq), nrow = length(Xseq)), xlab = "",
      ylab = "", zlab = "", theta = 30, phi = 20, ltheta = 50,
      border = NA, main = "kNN", d = 0.5, scale = FALSE, box = TRUE, col = "brown",
      expand = 3, shade = 0.9)
plot(Xiris, col = iris$Species, pch = 19, cex = 1.5)

band <- bootstrapBand(X = Xiris, FUN = kde, Grid = Grid, B = 100,
                      parallel = FALSE, alpha = 0.1, h = 0.3)
DiagGrid <- gridDiag(
  X = Xiris, FUN = kde, h = 0.3, lim = cbind(Xlim, Ylim), by = by,
  sublevel = FALSE, library = "Dionysus", location = TRUE,
  printProgress = FALSE)
plot(Xiris, col = 2, pch = 19, cex = 1.5)
plot(DiagGrid[["diagram"]], band = 2 * band[["width"]],
     main = "KDE Diagram")
# plot(DiagGrid[["diagram"]], barcode = TRUE, main = "Barcode")




