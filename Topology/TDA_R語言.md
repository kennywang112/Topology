# 拓樸學資料分析
這篇是針對[R package](https://cran.r-project.org/web/packages/TDA/vignettes/article.pdf)有的函數內容進行TDA的講解。

## Distance Functions and Density Estimators
```r
X <- circleUnif(400)
as.data.frame(X)%>%ggplot(aes(x1, x2))+geom_point()
Xlim <- c(-1.6, 1.6)
Ylim <- c(-1.7, 1.7)
by <- 0.065
Xseq <- seq(Xlim[1], Xlim[2], by = by)
Yseq <- seq(Ylim[1], Ylim[2], by = by)
Grid <- expand.grid(Xseq, Yseq)
```
提供的程式碼`X`生成了兩個欄位分別是xy軸，並且並且`Xlim`和`Ylim`設定範圍並依照每步`by`來生成`seq`，最後`Grid`生成均勻分布的正方體，為之後的三維作圖鋪陳。

<img src="../Images/tda1.png" alt="描述" width="300" height="300"></img>

對於三維作圖提供了幾個距離/密度的算法
1. distance to measure (DTM)
2. k Nearest Neighbor density estimator
3. Gaussian Kernel Density Estimator
4. Kernel distance estimator

##  Persistent Homology
拓樸數據分析(TDA)的目的是分析點雲的結構，而同調在其中的意義就是為了解決找出拓樸空間的**持久特徵**，或是說當我們在分析資料的時候都專注於他們的型態，當我們的資料面對多種不同尺度的時候，他們能否保有原有的特徵，讓他們在去掉雜音之後還能保持。
### 網格上的持久同源性
這是使用死亡對上出生的KDE圖，中間的粉色區域代表了信賴區間的部分，在程式碼方面是使用`bootstrapBand`來寫的，而在紅色區域外的，或是說有紅色三角型的區域中，有黑色點的代表他是離群值
```r
band <- bootstrapBand(X = X, FUN = kde, Grid = Grid, B = 100,
                      parallel = FALSE, alpha = 0.1, h = h)
DiagGrid <- gridDiag(
  X = X, FUN = kde, h = 0.3, lim = cbind(Xlim, Ylim), by = by,
  sublevel = FALSE, library = "Dionysus", location = TRUE,
  printProgress = FALSE)
plot(DiagGrid[["diagram"]], band = 2 * band[["width"]],
    main = "KDE Diagram")
```
<img src="../Images/kde_diag.png" alt="描述" width="300" height="300"></img>

### 撕裂圖(Rips Diagram)