Torus <- read.table(
  file = "http://bertrand.michel.perso.math.cnrs.fr/Enseignements/TDA/Data/ElongatedTorus.txt",
  sep = "", header = FALSE)

library(scatterplot3d)
scatterplot3d(Torus[,1], Torus[,2], Torus[,3])

library(FactoMineR)
# PCA does not see the hole in the center of the data
Torus.pca <- PCA(Torus,graph = FALSE)
Torus.PCA1 <- Torus.pca$ind$coord[,1]
qplot(Torus.pca$ind$coord[,1],Torus.pca$ind$coord[,2])
# Mapper with a filter equal to the first coordinate
Torus.dist <- dist(Torus)
torus.mapper <- mapper(
  dist_object  = Torus.dist,
  filter_values = Torus[,1],
  num_intervals = 10,
  percent_overlap = 50,
  num_bins_when_clustering = 10)
torus.graph <- graph.adjacency(torus.mapper$adjacency, mode = "undirected")
plot(torus.graph , layout = layout.auto(torus.graph),main ="Raw visualisation of \n the Mapper Graph \nfor the Torus dataset" )
# Mapper with a convenient bi-dimensional filter
torus.mapper <- mapper(
  dist_object = Torus.dist,
  filter_values = list(Torus[,1],Torus[,2]),
  num_intervals = c(8,8),
  percent_overlap = 50,
  num_bins_when_clustering = 10)
torus.graph <- graph.adjacency(torus.mapper$adjacency, mode = "undirected")
plot(torus.graph,
     layout = layout.auto(torus.graph),
     main = "Raw visualisation of \n the Mapper Graph \nfor the Torus dataset \n filter bidim" )

MapperNodes <- mapperVertices(torus.mapper, 1:length(Torus[,1]) )
MapperLinks <- mapperEdges(torus.mapper)
forceNetwork(Nodes = MapperNodes, Links = MapperLinks, 
             Source = "Linksource", Target = "Linktarget",
             Value = "Linkvalue", NodeID = "Nodename",
             Group = "Nodegroup", opacity = 1, 
             linkDistance = 10, charge = -10)  

# trefoil data
Trefoil = read.table(
  file = "http://bertrand.michel.perso.math.cnrs.fr/Enseignements/TDA/Data/NoisyTrefoil180.txt",
  sep = "", header = FALSE)
summary(Trefoil)
Trefoil.dist <- dist(Trefoil)
scatterplot3d(Trefoil[,1], Trefoil[,2], Trefoil[,3])
Trefoil.mapper <- mapper(
  dist_object  = Trefoil.dist,
  filter_values = Trefoil[,1],
  num_intervals = 10,
  percent_overlap = 30,
  num_bins_when_clustering = 10)
Trefoil.graph <- graph.adjacency(Trefoil.mapper$adjacency, mode="undirected")
plot(Trefoil.graph , layout = layout.auto(Trefoil.graph), main = paste("Raw visualisation of the Mapper Graph \n for the Trefoil Dataset \n " ))

num_int_seq <- seq(6,16,2)
percent_overlap_seq <- seq(20,80,20)
num_bins_when_clustering_seq <- seq(5,15,2)
for (num in num_int_seq){
  for (perc in percent_overlap_seq){
    for (num_bins in num_bins_when_clustering_seq){
      
      Trefoil.mapper <- mapper(
        dist_object = Trefoil.dist,
        filter_values = Trefoil[,1],
        num_intervals = num,
        percent_overlap = perc,
        num_bins_when_clustering = num_bins)
      
      Trefoil.graph <- graph.adjacency(Trefoil.mapper$adjacency, mode="undirected")
      mytitle = paste("num_interv", as.character(num), " perc=", as.character(perc), "num_bins",
                      as.character(num_bins) )
      plot(Trefoil.graph, layout = layout.auto(Trefoil.graph),main = mytitle)
    }}}



