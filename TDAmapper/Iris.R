data(iris)
data <- iris

iris[,2:5] <- scale(iris[,2:5], center = FALSE)
normiris.dist <- dist(iris[,2:5])
filter.kde <- kde(iris[,2:5], H = diag(1, nrow = 4), eval.points = iris[,2:5])$estimate
iris.mapper <- mapper(
  dist_object = normiris.dist,
  filter_values = filter.kde,
  num_intervals = 4,
  percent_overlap = 50,
  num_bins_when_clustering = 20)
iris.graph <- graph.adjacency(iris.mapper$adjacency, mode = "undirected")
plot(iris.graph)

l <- length(V(iris.graph))
Mode <- function(x) {
  ux <- x%>%unique()
  ux[which.max(tabulate(match(x, ux)))] # which.max return index
}
# Distribution of the species variable in each vertex Majority vote
species.maj.vertex <- c()
filter.kde.vertex <- c()
vertex.size <- rep(0, l)
# Most frequent species in each vertex
for (i in 1:l){
  points.in.vertex <- iris.mapper$points_in_vertex[[i]]
  Mode.in.vertex <- iris$species[points.in.vertex]%>%Mode()
  species.maj.vertex <- c(species.maj.vertex, as.character(Mode.in.vertex))
  filter.kde.vertex <- c(filter.kde.vertex, mean(filter.kde[points.in.vertex]))
  
  vertex.size[i] <- iris.mapper$points_in_vertex[[i]]%>%length()
}

MapperNodes <- mapperVertices(iris.mapper, 1:nrow(iris) )
MapperNodes$species.maj.vertex <- as.factor(species.maj.vertex)
MapperNodes$filter.kde <- filter.kde.vertex
MapperNodes$Nodesize <- vertex.size

MapperLinks <- mapperEdges(iris.mapper)
forceNetwork(Nodes = MapperNodes, Links = MapperLinks, 
             Source = "Linksource", Target = "Linktarget",
             Value = "Linkvalue", NodeID = "Nodename",
             Group = "species.maj.vertex", opacity = 1, 
             linkDistance = 10, charge = -400,legend = TRUE,
             Nodesize = "Nodesize")  

# we concatenate the values of cc and vertex.label for the points of all the vertices
# (one point can be in to different vertices)
vertex.label <- c()
species.mapper <- c()
for (ver in 1:l){
  points.in.vertex <- iris.mapper$points_in_vertex[[ver]]
  vertex.label <- c(vertex.label, rep(ver, length(points.in.vertex)))
  species.mapper <- c(species.mapper, data$species[points.in.vertex])
}

vertex.label <- as.factor(vertex.label)
species.mapper <- as.factor(species.mapper)
# Blue indicate more observations than expected under independence
# Red indicate fewer observations than expected 
levels(species.mapper) <- c("versicolor", "virginica")
table(vertex.label, species.mapper)
mosaic(table(vertex.label, species.mapper), shade = TRUE)
