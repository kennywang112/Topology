## Density Estimators over a Grid of Points

### k Nearest Neighbor density estimator
This function `knnDE(X, Grid, k)` input a n by d matrix point cloud(X), m by d matrix of Grid, and smoothing parameter k, computes the function.

$p_X (x) = k / (n * v_d * r_k^d(x)), x∈R^d$

> $v_d$ : The volume of the Euclidean d dimensional unit ball, $r_k^d(x)$ :  Euclidean distance from point x to its k'th closest neighbor.

### Distance to Measure Function
 using the uniform empirical measure on a set of points X. Given a probability measure P, defined by 

$d_{m0}(y) = (1/m0 int_0^{m0} (G_y^{-1}(u))^{r} du)^{1/r}, y∈R^d$

where $G_y(t) = P(||X-y|| ≤ t)$, and params $m0∈(0,1)$ represent smooth, and $r∈[1,∞)$ affects less but also changes the function, this function can be seen as a **smoothed version of distance function** where $X={x_1, …, x_n}$, the empirical version of the distance to measure is

$\hat d_{m0}(y) = (1/k ∑_{x_i in N_k(y)} ||x_i-y||^r)^{1/r},$

where $k= \lceil m0 * n \rceil$ and $N_k(y)$ is the set containing the k nearest neighbors of y among $x_1, …, x_n$.