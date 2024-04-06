## Vietoris-Rips 
Let $X\subset\mathbb{R}^D$ be a point cloud and $\epsilon ≥ 0$ :

$VR_\epsilon(X) =\{\sigma\subseteq X | d(x,x^{\prime}) ≤ 2\epsilon, \forall x,x^{\prime}\inσ\}$

This formula means if the point satisfy $d(x, x^{\prime}) ≤ 2\epsilon$ and all $x,x^{\prime}\in X$, it adds to the p-simplex $\sigma = [x_0x_1...x_k]$

## General position
A set of point in a d-dim Euclidiean space is in gerneral position if no d+2 of them lie on a common (d-1)-sphere, this means for a set of points in general position in $\mathbb{R}^2$, no 4 of them can be co-cirular. And this ensures the unique of Delaunay triangulation

Let $X\subset\mathbb{R}^D$ be a finite point cloud and $x \in X$ :

$V_x: =\{p\in\mathbb{R}^D | d(p,x)≤d(p,x^{\prime}) \forall x^{\prime} \in X\}$

The $V_X$ is called a Vornonoi cell of $X$, and it capture all points which are not closer to any other point in $X$ than $x$

Delaunay triangulation define as:

$Del(X) :=\{\sigma\subset X | \bigcap_{x \in \sigma}V_x \neq\emptyset\}$

$Del(X)$ itself is a simplical complex, and a n-simplex $\sigma\in Del(X)$ will be refered to a Delaunay simplex

## Alpha Complexes
For all point clouds  $X\subset\mathbb{R}^D$, Let $\epsilon≥0$ and $S_x(\epsilon):V_x \bigcap B_x(\epsilon)$ where $B_x(\epsilon)$ is the d-dim ball of radius $\epsilon$ centered on $x\in X$ :

$Alpha_\epsilon(X) =\{\sigma\subseteq X | \bigcap_{x \in \sigma} S_x(\epsilon) \neq\emptyset\}$

Find the the intersection of the set $V_x$ and $B_x(\epsilon)$ first, then find the total intersection among all the $S_x(\epsilon)$
## Delaunay-Rips Complex

$DR_\epsilon(X) =\{\sigma\subseteq Del(X) | d(x, x^{\prime}) ≤ 2 \epsilon, \forall x,x^{\prime}\in\sigma\}$ for $\epsilon≥0$