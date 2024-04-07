library(plotly)
library(TDA)
library(tseriesChaos)

data <- economics%>%as.data.frame()%>%filter(date < "2009-01-01" & date > "1975-01-01")
data$unemploy <- data$unemploy%>%sqrt()
data%>%ggplot()+geom_line(aes(date, unemploy))
plot(data$date, data$unemploy)

embedded_data <- embedd(data$unemploy, m = 3, d = 24)%>%as.data.frame()

fig <- plot_ly(embedded_data, x = ~`V1/0`, y = ~`V1/24`, z = ~`V1/48`, size = 1)
fig <- fig %>% add_markers()
fig <- fig %>% layout(scene = list(xaxis = list(title = 'x1'),
                                   yaxis = list(title = 'x2'),
                                   zaxis = list(title = 'x3')),
                      title = 'Point Cloud')
fig

theta_y <- 45 * (pi / 180)
theta_x <- 45 * (pi / 180)

rotate_y <- matrix(c(cos(theta_y), 0, sin(theta_y),
                     0, 1, 0,
                     -sin(theta_y), 0, cos(theta_y)), nrow = 3, byrow = TRUE)
rotate_x <- matrix(c(1, 0, 0,
                     0, cos(theta_x), -sin(theta_x),
                     0, sin(theta_x), cos(theta_x)), nrow = 3, byrow = TRUE)


data_rotated_y <- as.matrix(embedded_data) %*% t(rotate_y)
data_rotated_final <- data_rotated_y %*% t(rotate_x)%>%as.data.frame()

fig <- plot_ly(data_rotated_final, x = ~`V1`, y = ~`V2`, z = ~`V3`, size = 1)
fig <- fig %>% add_markers()
fig <- fig %>% layout(scene = list(xaxis = list(title = 'x1'),
                                   yaxis = list(title = 'x2'),
                                   zaxis = list(title = 'x3')),
                      title = 'Point Cloud')
fig

data_rotated_final%>%ggplot()+geom_point(aes(`V2`, `V3`))


DiagRips <- embedded_data%>%ripsDiag(
  maxdimension = 1, maxscale = 15,
  library = c("GUDHI", "Dionysus"), location = TRUE, printProgress = TRUE)
plot(DiagRips[["diagram"]], main = "Rips Diagram")


one <- which(DiagRips[["diagram"]][, 1] == 1)
one <- one[which.max(
  DiagRips[["diagram"]][one, 3] - DiagRips[["diagram"]][one, 2])]
plot(embedded_data[,2], embedded_data[,3], col = 1)
for (i in seq(along = one)) {
  for (j in seq_len(dim(DiagRips[["cycleLocation"]][[one[i]]])[1])) {
    lines(DiagRips[["cycleLocation"]][[one[i]]][j, , ], col = i + 1)
    }
}
par(mfrow = c(1, 2))

library(TDAmapper)
library(networkD3)
plot(data_rotated_final[,2], data_rotated_final[,3])
Economics.dist = dist(data_rotated_final)
Economics.mapper <- mapper(
  dist_object = Economics.dist,
  filter_values = list(data_rotated_final[,2],data_rotated_final[,3]),
  num_intervals = c(8,8),
  percent_overlap = 50,
  num_bins_when_clustering = 10)

MapperNodes <- mapperVertices(Economics.mapper, 1:length(data_rotated_final[,1]) )
MapperLinks <- mapperEdges(Economics.mapper)
forceNetwork(Nodes = MapperNodes, Links = MapperLinks, 
             Source = "Linksource", Target = "Linktarget",
             Value = "Linkvalue", NodeID = "Nodename",
             Group = "Nodegroup", opacity = 1, 
             linkDistance = 10, charge = -10)


