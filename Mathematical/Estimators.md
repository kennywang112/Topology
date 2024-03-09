## Density Estimators over a Grid of Points

### Distance to Measure Function
 using the uniform empirical measure on a set of points `X`. Given a probability measure P, defined by 

$d_{m0}(y) = (1/m0 int_0^{m0} (G_y^{-1}(u))^{r} du)^{1/r}, y∈R^d$

where $G_y(t) = P(||X-y|| ≤ t)$, this function can be seen as a **smoothed version of distance function** where $X={x_1, …, x_n}$, the empirical version of the distance to measure is

$\hat d_{m0}(y) = (1/k ∑_{x_i in N_k(y)} ||x_i-y||^r)^{1/r}$

where $k= \lceil m0 * n \rceil$ and $N_k(y)$ is the set containing the k nearest neighbors of y among $x_1, …, x_n$.

`dtm(X, Grid, m0, r = 2, weight = 1)`
- X : n(number) by d(dimension) matrix
- Grid : m by d matrix, m is the number of points in the grid
- $m0$ : $m0∈(0,1)$ represent smooth
- $r$ : $r∈[1,∞)$ affects less but also changes the function

### k Nearest Neighbor density estimator

$p_X (x) = k / (n * v_d * r_k^d(x)), x∈R^d$

- $v_d$ : The volume of the Euclidean d dimensional unit ball
- $r_k^d(x)$ :  Euclidean distance from point x to its k'th closest neighbor.

`knnDE(X, Grid, k)`
- $k$ : smoothing param

### Kernel Density Estimator over a Grid of Points

Given a point cloud `X` (n points), the function `kde` computes the Kernel Density Estimator over a grid of points. The kernel is a Gaussian Kernel with smoothing parameter `h`. For each x in $R^d$, the Kernel Density estimator is defined as

$p_X (x) = 1/(n (√(2π) h)^d) ∑_{i=1}^n exp( -(||x-X_i||^2)/(2h^2) )$

`kde(X, Grid, h, kertype = "Gaussian", weight = 1, printProgress = FALSE)`:
- h : the smoothing params of Gayssuab Kernal
- kertype : Gaussian(default), Epanechnikov
- weight : either a number, or a vector of length n. If it is a number, then same weight is applied to each points of `X`. If it is a vector, `weight` represents weights of each points of `X`. The default value is `1`
- printProgress : default `FALSE`

### Kernel distance over a Grid of Points

Given a point cloud X, the function kernelDist computes the kernel distance over a grid of points. The kernel is a Gaussian Kernel with smoothing parameter h:

$K_h (x,y) = exp( -(||x-y||^2)/(2h^2) )$

For each x in $R^d$, the Kernel distance is defined by

$κ_X (x) = √( 1/(n^2) ∑_{i=1}^n∑_{j=1}^n K_h(X_i, X_j) + K_h(x,x) - 2/n ∑_{i=1}^n K_h(x,X_i) )$

`kernelDist(X, Grid, h, weight = 1, printProgress = FALSE)`