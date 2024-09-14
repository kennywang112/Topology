library(tidyverse)
# library(TDA)
library(networkD3)
library(igraph)
library(ks)
setwd('./Mapper_from_scratch')
getwd()
source('MappingAlgo.R')

data("iris")
# scaled_columns <- scale(iris[, 2:5])
# iris <- cbind(iris[, 1, drop = FALSE], scaled_columns)

ggplot(iris)+geom_point(aes(x=Sepal.Length, y=Petal.Length, color = Species))
# iris <- iris %>% select(species, sepal.len, petal.len)
# filter.kde <- kde(iris[,1:4], H=diag(1, nrow = 4), eval.points=iris[,1:4], binned=FALSE)$estimate

time_taken <- system.time({
  Traffic.mapper <- mapper(
    dist_object = dist(iris[,1:4]),
    filter_values = iris[,1:4],
    num_intervals = c(4,4,4,4),
    percent_overlap = 50,
    num_bins_when_clustering = 20)
})
time_taken

Traffic.graph <- graph.adjacency(Traffic.mapper$adjacency, mode="undirected")
l = length(V(Traffic.graph))
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}
# Distribution of specific variable in each vertex Majority vote
var.maj.vertex <- c()
filter.vertex <- c()

for (i in 1:l){
  points.in.vertex <- Traffic.mapper$points_in_vertex[[i]]
  Mode.in.vertex <- Mode(iris$Species[points.in.vertex])
  var.maj.vertex <- c(var.maj.vertex,as.character(Mode.in.vertex))
  # filter.vertex <- c(filter.vertex,mean(filter.kde[points.in.vertex]))
}
# Size
vertex.size <- rep(0,l)
for (i in 1:l){
  points.in.vertex <- Traffic.mapper$points_in_vertex[[i]]
  vertex.size[i] <- length((Traffic.mapper$points_in_vertex[[i]]))
}
MapperNodes <- mapperVertices(Traffic.mapper, 1:nrow(iris))
MapperNodes$var.maj.vertex <- as.factor(var.maj.vertex)
# MapperNodes$filter.kde <- filter.vertex
MapperNodes$Nodesize <- vertex.size
MapperLinks <- mapperEdges(Traffic.mapper)
forceNetwork(Nodes = MapperNodes, Links = MapperLinks, Target = "Linktarget",
             Value = "Linkvalue", NodeID = "Nodename", Nodesize = "Nodesize",
             Group = "var.maj.vertex", opacity = 1, zoom = TRUE,
             linkDistance = 10, charge = -10, legend = TRUE)

