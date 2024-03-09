library(locfit)
library(ks)
library(vcd)

data(chemdiab)
summary(chemdiab)

normdiab <- chemdiab
normdiab[,1:5] <- scale(normdiab[,1:5], center = FALSE)
normdiab.dist <- dist(normdiab[,1:5])
# Gaussian Kernel Density Estimator
filter.kde <- kde(normdiab[,1:5], H = diag(1,nrow = 5), eval.points = normdiab[,1:5])$estimate
diab.mapper <- mapper(
  dist_object = normdiab.dist,
  filter_values = filter.kde,
  num_intervals = 4,
  percent_overlap = 50,
  num_bins_when_clustering = 20)
diab.graph <- graph.adjacency(diab.mapper$adjacency, mode = "undirected")
plot(diab.graph)

l = length(V(diab.graph))
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}
# Distribution of the cc variable in each vertex Majority vote
cc.maj.vertex <- c()
filter.kde.vertex <- c()
for (i in 1:l){
  points.in.vertex <- diab.mapper$points_in_vertex[[i]]
  Mode.in.vertex <- Mode(normdiab$cc[points.in.vertex])
  cc.maj.vertex <- c(cc.maj.vertex, as.character(Mode.in.vertex))
  filter.kde.vertex <- c(filter.kde.vertex, mean(filter.kde[points.in.vertex]))
}

vertex.size <- rep(0, l)
for (i in 1:l){
  points.in.vertex <- diab.mapper$points_in_vertex[[i]]
  vertex.size[i] <- length((diab.mapper$points_in_vertex[[i]]))
}

MapperNodes <- mapperVertices(diab.mapper, 1:nrow(normdiab) )
MapperNodes$cc.maj.vertex <- as.factor(cc.maj.vertex)
MapperNodes$filter.kde <- filter.kde.vertex
MapperNodes$Nodesize <- vertex.size

MapperLinks <- mapperEdges(diab.mapper)
forceNetwork(Nodes = MapperNodes, Links = MapperLinks, 
             Source = "Linksource", Target = "Linktarget",
             Value = "Linkvalue", NodeID = "Nodename",
             Group = "cc.maj.vertex", opacity = 1, 
             linkDistance = 10, charge = -400,legend = TRUE,
             Nodesize = "Nodesize")  
# we concatenate the values of cc and vertex.label for the points of all the vertices
# (one point can be in to different vertices)
vertex.label <- c()
cc.mapper <- c()
for (ver in 1:l){
  points.in.vertex <- diab.mapper$points_in_vertex[[ver]]
  vertex.label <- c(vertex.label,rep(ver,length(points.in.vertex)))
  cc.mapper <- c(cc.mapper,chemdiab$cc[points.in.vertex])
}

vertex.label <- as.factor(vertex.label)
cc.mapper <- as.factor(cc.mapper)

levels(cc.mapper) <- c("Chem","Norm","Overt")
table(vertex.label,cc.mapper)
mosaic(table(vertex.label,cc.mapper),shade = TRUE)
