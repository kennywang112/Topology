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
