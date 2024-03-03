library(tidyverse)
# topology1
ggplot(data.frame(x = c(-1, 1)), aes(x = x)) +
  stat_function(fun = function(x) x^2 + 0.1, color = "red", size = 1.5) +
  stat_function(fun = function(x) 0.5*x^2 - 0.7, color = "blue", size = 1.5) +
  stat_function(fun = function(x) 0, color = "green", size = 1) +
  coord_cartesian(xlim = c(-1, 1), ylim = c(-1, 1))
# topology2
ggplot(data.frame(x = c(-1, 1)), aes(x = x)) +
  stat_function(fun = function(x) 1000*x^2 - 0.9, color = "red", size = 1.5) +
  stat_function(fun = function(x) 300*x^2 - 1, color = "blue", size = 1.5) +
  coord_cartesian(xlim = c(-1, 1), ylim = c(-1, 1))
# topology3
ggplot(data.frame(x = c(-1, 1)), aes(x = x)) +
  stat_function(fun = function(x) 0.5, color = "red", size = 1.5) +
  stat_function(fun = function(x) - 0.5, color = "blue", size = 1.5) +
  coord_cartesian(xlim = c(-1, 1), ylim = c(-1, 1))
# topology4
data_inner <- data.frame(x = cos(seq(0, 2 * pi, length.out = 100)) * 1/3, y = sin(seq(0, 2 * pi, length.out = 100)) * 1/3)
data_outer <- data.frame(x = cos(seq(0, 2 * pi, length.out = 100)) * 2/3, y = sin(seq(0, 2 * pi, length.out = 100)) * 2/3)
ggplot() +
  geom_path(data = data_inner, aes(x, y), color = "red", size = 30) +
  geom_path(data = data_outer, aes(x, y), color = "blue", size = 30) +
  geom_point(aes(0, 0), color = "black") +  # 中心点
  xlim(-1, 1) + ylim(-1, 1) +
  theme_minimal()

install.packages("plot3D")
library(plot3D)
data1 <- data.frame(
  x = rnorm(100, mean = -0.5),
  y = rnorm(100, mean = -0.5),
  z = rnorm(100, mean = -0.5)
)
data2 <- data.frame(
  x = rnorm(50, mean = 0.5),
  y = rnorm(50, mean = 0.5),
  z = rnorm(50, mean = 0.5)
)
scatter3D(x = data1$x, y = data1$y, z = data1$z, col = "blue", pch = 16)
scatter3D(x = data2$x, y = data2$y, z = data2$z, col = "red", pch = 16, add = TRUE)

legend("topleft", legend = c("Class 1", "Class 2"), col = c("blue", "red"), pch = 16)


