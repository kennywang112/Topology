# Cover
cover_points <- function(lsfi, filter_min, interval_width, percent_overlap, filter_values, num_intervals) {
  # level set flat index (lsfi), which is a number, has a corresponding
  # level set multi index (lsmi), which is a vector
  lsmi <- lsmi_from_lsfi(lsfi, num_intervals)
  # set the range of the interval
  lsfmin <- filter_min + (lsmi - 1) * interval_width - 0.5 * interval_width * percent_overlap / 100
  lsfmax <- lsfmin + interval_width + interval_width * percent_overlap/100
  # compute whether each point is in the range
  in_range <- apply(filter_values, 1, function(x) all(lsfmin <= x & x <= lsfmax))
  # return the indices of the points that are in the range
  return(which(in_range))
}

# Clustering
perform_clustering <- function(points_in_this_level, filter_values, num_bins_when_clustering) {
  num_points_in_this_level <- length(points_in_this_level)
  
  if (num_points_in_this_level == 0) {
    return(list(num_vertices = 0, external_indices = NULL, internal_indices = NULL))
  }
  
  if (num_points_in_this_level == 1) {
    return(list(num_vertices = 1, external_indices = points_in_this_level, internal_indices = c(1)))
  }
  
  level_dist_object <- as.dist(as.matrix(dist(filter_values))[points_in_this_level, points_in_this_level])
  level_max_dist <- max(level_dist_object)
  level_hclust <- hclust(level_dist_object, method = "single")
  level_heights <- level_hclust$height
  level_cutoff <- cluster_cutoff_at_first_empty_bin(level_heights, level_max_dist, num_bins_when_clustering)
  level_external_indices <- points_in_this_level[level_hclust$order]
  level_internal_indices <- as.vector(cutree(list(
    merge = level_hclust$merge,
    height = level_hclust$height,
    labels = level_external_indices), h = level_cutoff))
  num_vertices_in_this_level <- max(level_internal_indices)
  
  return(list(
    num_vertices = num_vertices_in_this_level,
    external_indices = level_external_indices,
    internal_indices = level_internal_indices
  ))
}

mapper <- function(
    filter_values, # dist_df[,1:col]
    intervals, # rep(2, col)
    percent_overlap, # 50
    num_bins_when_clustering # 10
) {

  filter_values <- data.frame(filter_values)
  num_intervals <- rep(intervals, ncol(filter_values)) # rep(2,4) = (2,2,2,2)
  
  num_points <- dim(filter_values)[1] # row
  filter_output_dim <- dim(filter_values)[2] # columns
  num_levelsets <- prod(num_intervals) 
  
  # define some vectors of length k = number of columns
  filter_min <- as.vector(sapply(filter_values, min))
  filter_max <- as.vector(sapply(filter_values, max))
  interval_width <- (filter_max - filter_min) / num_intervals
  
  # initialize variables    
  vertex_index <- 0
  level_of_vertex <- c()
  points_in_vertex <- list()
  points_in_level_set <- vector("list", num_levelsets) 
  # store the data points owned by each individual interval
  vertices_in_level_set <- vector("list", num_levelsets)

  # begin loop through all level sets
  for (lsfi in 1:num_levelsets) {
    print(paste(lsfi, "/", num_levelsets))
    
    # Cover step
    points_in_level_set[[lsfi]] <- cover_points(
      lsfi, filter_min, interval_width, percent_overlap, filter_values, num_intervals
      )
    # Clustering step
    clustering_result <- perform_clustering(
      points_in_level_set[[lsfi]], filter_values, num_bins_when_clustering
      )
    
    num_vertices_in_this_level <- clustering_result$num_vertices
    level_external_indices <- clustering_result$external_indices
    level_internal_indices <- clustering_result$internal_indices
    
    # Begin vertex construction
    if (num_vertices_in_this_level > 0) { # check admissibility condition
      # add the number of vertices in the current level set to the vertex index
      vertices_in_level_set[[lsfi]] <- vertex_index + (1:num_vertices_in_this_level)
      for (j in 1:num_vertices_in_this_level) {
        vertex_index <- vertex_index + 1
        level_of_vertex[vertex_index] <- lsfi # put the current loop count into the corresponding index vertex
        # let all points that satisfy the condition "the number of internal clusters of the current lsfi == 
        # the maximum value of the current vertices" be put into points_in_vertex
        points_in_vertex[[vertex_index]] <- level_external_indices[level_internal_indices == j]
      }
    }
    # note : 計算單個interval內的cluster各個點的數量，然後用迴圈包interval的數量
  } # end vertex construction
  
  # Begin simplicial complex
  adja <- mat.or.vec(vertex_index, vertex_index) # create empty adjacency matrix
  # loop through all level sets
  for (lsfi in 1:num_levelsets) {
    # get the level set multi-index from the level set flat index
    lsmi <- lsmi_from_lsfi(lsfi, num_intervals)
    # Find adjacent level sets +1 of each entry in lsmi
    # (within bounds of num_intervals, of course).
    # Need the inverse function lsfi_from_lsmi to do this easily.
    for (k in 1:filter_output_dim) {
      # check admissibility condition is met
      if (lsmi[k] < num_intervals[k]) {
        lsmi_adjacent <- lsmi + diag(filter_output_dim)[,k]
        lsfi_adjacent <- lsfi_from_lsmi(lsmi_adjacent, num_intervals)
      } else { next }
      # check admissibility condition is met
      if (length(vertices_in_level_set[[lsfi]]) < 1 |
          length(vertices_in_level_set[[lsfi_adjacent]]) < 1) { next }
      # construct adjacency matrix
      for (v1 in vertices_in_level_set[[lsfi]]) {
        for (v2 in vertices_in_level_set[[lsfi_adjacent]]) {
          
          adja[v1, v2] <- (length(intersect(
            points_in_vertex[[v1]],
            points_in_vertex[[v2]])) > 0)
          
          adja[v2, v1] <- adja[v1,v2]
        }
      }
    }
  }
  # End simplicial complex
  
  mapperoutput <- list(adjacency = adja,
                       num_vertices = vertex_index,
                       level_of_vertex = level_of_vertex,
                       points_in_vertex = points_in_vertex,
                       points_in_level_set = points_in_level_set,
                       vertices_in_level_set = vertices_in_level_set)
  
  class(mapperoutput) <- "TDAmapper"
  return(mapperoutput)
}

# Function from the level set flat index (lsfi) to the level set multi-index (lsmi)
lsmi_from_lsfi <- function(lsfi, num_intervals) {
  # level set flat index (lsfi)
  j <- c(1, num_intervals) # put 1 in front to make indexing easier in the product prod(j[1:k])
  f <- c()
  for (k in 1:length(num_intervals)) {
    # use lsfi-1 to shift from 1-based indexing to 0-based indexing
    f[k] <- floor((lsfi-1) / prod(j[1:k])) %% num_intervals[k]
  }
  # lsmi = f+1 = level set multi index
  return(f+1) # shift from 0-based indexing back to 1-based indexing
}

lsfi_from_lsmi <- function(lsmi, num_intervals) {
  # level set multi index (lsmi)
  lsfi <- lsmi[1]
  if (length(num_intervals) > 1) {
    for (i in 2:length(num_intervals)) {
      lsfi <- lsfi + prod(num_intervals[1:(i-1)]) * (lsmi[i]-1)
    }
  }
  return(lsfi)
}

# lsmi_from_lsfi(4, c(4,4,4,4))
# lsfi_from_lsmi(c(1,1,1,2), c(4,4,4,4))

# Dcides where to cut the hierarchical clustering tree to define clusters within a level set.
cluster_cutoff_at_first_empty_bin <- function(heights, diam, num_bins_when_clustering) {
  # if there are only two points (one height value), then we have a single cluster
  if (length(heights) == 1) {
    if (heights == diam) {
      cutoff <- Inf
    }
  }
  bin_breaks <- seq(from=min(heights), to=diam, by=(diam - min(heights))/num_bins_when_clustering)
  
  if (length(bin_breaks) == 1) { bin_breaks <- 1 }
  
  myhist <- hist(c(heights,diam), breaks=bin_breaks, plot=FALSE)
  z <- (myhist$counts == 0)
  if (sum(z) == 0) {
    cutoff <- Inf
  } else {
    #  which returns the indices of the logical vector (z == TRUE), min gives the smallest index
    cutoff <- myhist$mids[ min(which(z == TRUE)) ]
  }
  return(cutoff)
}
