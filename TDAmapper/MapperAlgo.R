# http://bertrand.michel.perso.math.cnrs.fr/Enseignements/TDA/Mapper.html

library(devtools)
devtools::install_github("paultpearson/TDAmapper")
devtools::install_github("christophergandrud/networkD3")
library(TDAmapper)
library(ggplot2)
library(tidyverse)
library(networkD3)
library(igraph)

data(iris)
iris%>%ggplot()+geom_point(aes(Sepal.Length, Petal.Length, color = Species))
Ex_data <- iris%>%select(Sepal.Length, Petal.Length)

euclidean_dist <- dist(Ex_data)
mapper_filter <- mapper(dist_object = euclidean_dist,
                       filter_values = Ex_data$Sepal.Length,
                       num_intervals = 6,
                       percent_overlap = 50,
                       num_bins_when_clustering = 10)

mapper_graph <- graph.adjacency(mapper_filter$adjacency, mode = "undirected")
plot(mapper_graph, layout = layout.auto(mapper_graph) )

y.mean.vertex <- rep(0, mapper_filter$num_vertices)
for (i in 1:mapper_filter$num_vertices){
  points.in.vertex <- mapper_filter$points_in_vertex[[i]]
  y.mean.vertex[i] <-mean((Ex_data$Sepal.Length[points.in.vertex]))
}
vertex.size <- rep(0, mapper_filter$num_vertices)
for (i in 1:mapper_filter$num_vertices){
  points.in.vertex <- mapper_filter$points_in_vertex[[i]]
  vertex.size[i] <- length((mapper_filter$points_in_vertex[[i]]))
}
y.mean.vertex.grey <- grey(1 - (y.mean.vertex - min(y.mean.vertex))/(max(y.mean.vertex) - min(y.mean.vertex) ))
V(mapper_graph)$color <- y.mean.vertex.grey
V(mapper_graph)$size <- vertex.size
plot(mapper_graph,main = "Mapper Graph")
# Interactive plot
MapperNodes <- mapperVertices(mapper_filter, 1:100 )
MapperLinks <- mapperEdges(mapper_filter)
forceNetwork(Nodes = MapperNodes, Links = MapperLinks, 
             Source = "Linksource", Target = "Linktarget",
             Value = "Linkvalue", NodeID = "Nodename",
             Group = "Nodegroup", opacity = 1, 
             linkDistance = 10, charge = -400)  
