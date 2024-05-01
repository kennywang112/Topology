# Processing the Economics data and TDA
library(plotly)
library(TDA)
library(tseriesChaos)
# Applying mapper function and visualization
library(TDAmapper)
library(networkD3)

data <- economics%>%as.data.frame()%>%filter(date < "2009-01-01" & date > "1975-01-01")
data$unemploy <- data$unemploy%>%sqrt()
data%>%ggplot()+geom_line(aes(date, unemploy))

embedded_data <- embedd(data$unemploy, m = 3, d = 24)%>%as.data.frame()

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
data_rotated_final <- embedded_data

data_rotated_final%>%ggplot()+geom_point(aes(`V2`, `V3`))

Economics.dist = dist(data_rotated_final)
Economics.mapper <- mapper(
  dist_object = Economics.dist,
  filter_values = list(data_rotated_final[,1], data_rotated_final[,2],data_rotated_final[,3]),
  num_intervals = c(8,8,8),
  percent_overlap = 50,
  num_bins_when_clustering = 5)

MapperNodes <- mapperVertices(Economics.mapper, 1:length(data_rotated_final[,1]) )
MapperLinks <- mapperEdges(Economics.mapper)
forceNetwork(Nodes = MapperNodes, Links = MapperLinks, 
             Value = "Linkvalue", NodeID = "Nodename",
             Group = "Nodegroup", opacity = 1, 
             linkDistance = 10, charge = -10, zoom = TRUE, 
             Nodesize = "Nodesize",radiusCalculation = JS(" Math.sqrt(d.nodesize)+6"))

