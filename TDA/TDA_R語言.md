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

<img src="../Images/TDA_images/tda1.png" alt="描述" width="500" height="300"></img>

對於三維作圖提供了幾個距離/密度的算法
1. distance to measure (DTM)
2. k Nearest Neighbor density estimator
3. Gaussian Kernel Density Estimator
4. Kernel distance estimator

##  Persistent Homology
拓樸數據分析(TDA)的目的是分析點雲的結構，而同調在其中的意義就是為了解決找出拓樸空間的**持久特徵**，或是說當我們在分析資料的時候都專注於他們的型態，當我們的資料面對多種不同尺度的時候，他們能否保有原有的特徵，讓他們在去掉雜音之後還能保持。
### 網格上的持久同源性
這張KDE圖中，軸跟別是出生和死亡，代表該特徵的生死尺度，當使用**Vietoris-Rips complex**進行分析時，**ε**代表著我們觀察數據時所用的**尺度**或者**篩選值**，當ε被逐漸增加，就開始將越來越多的數據點組合在一起形成Vietoris-Rips complex的高維形狀，假設有一堆散落在平面上的點，這些點開始時是分開的(即它們**各自是一個連通分量**)。當你增加ε，這些點會開始連接成更大的形狀。一旦兩個點之間的距離小於或等於ε，它們就會被視為相連。這樣，當我們觀察這些點組成的形狀時，新的連通分量(或者環)就會**出生**。隨著ε繼續增加，這些形狀可能會合併成更大的形狀，而原本的特征就會**死亡**。

中間的粉色區域代表了信賴區間的部分，在程式碼方面是使用`bootstrapBand`來寫的，而在紅色區域外的，有紅色的點代表該資料有**環(loops)或洞(holes)**。這張圖表明大部分特徵都有類似的生死尺度範圍，紅色三角形離對角線最遠，顯示環的特征在較大的尺度範圍內存在，這表明它是一個可能重要的特征。
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
<img src="../Images/TDA_images/kde_diag.png" alt="描述" width="300" height="300"></img>

### 條碼圖(Barcode)
這張圖注意到X軸為time，也就是當掃描不同尺度(scale)的分析中拓樸特徵隨時間的產生以及消失，每個水平線都代表了一個特徵，左端為"出生"，右端為"死亡"，分別為它在過濾過程中首次出現的比例以及特徵不再存在的比例。
從我們的主題Persistent Homology中可知道這個圖主要想表達的是資料的持久性，希望找到的是真正存在的資料而非噪音。這張圖的資料和上面的KDE diagram是一樣的，紅色線也對應到上方的三角形，也可以從數據去做對應，比如紅色是從0到0.18左右，對應到上方的"出生"到"死亡"的座標。
```r
plot(DiagGrid[["diagram"]], barcode = TRUE, main = "Barcode")
```

<img src="../Images/TDA_images/barcode.png" alt="描述" width="300" height="300"></img>

### Rips diagram
**Vietoris-Rips complex**是由頂點位於X且直徑最多ε的**單純形(simplicial complex)**所組成，或是說如果單純形σ中的每個頂點間距離都不超過ε，那麼這個σ就會被包含在該complex中，透過逐漸增加半徑ε，獲得Rips complex序列創建一個**過濾**

```r
Circle1 <- circleUnif(60)
Circle2 <- circleUnif(60, r = 2) + 3
Circles <- rbind(Circle1, Circle2)
maxscale <- 1
maxdimension <- 1
DiagRips <- ripsDiag(X = Circles, maxdimension, maxscale,
                     library = c("GUDHI", "Dionysus"), location = TRUE, printProgress = FALSE)
plot(Circles, col = 2, pch = 19, cex = 1.5)
```

<img src="../Images/TDA_images/rips.png" alt="描述" width="500" height="300"></img>


### Alpha Complex Persistence Diagram
也是從點雲數據建構拓樸，且都是計算persistence homology從而獲取diagram，主要差異為如何構建**複合體(simplicial complexes)**進而反映特徵。
首先Rips是通過考慮點之間的配對距離來構建的，而Alpha complex則是**Delaunay Triangulation**的子集，依賴點於**Voronoi cell**的交互作用，一個單純形屬於Alpha complex，如果對應的Delaunay單純形的外接圓的半徑小於或等於給定的參數 √s，所以考慮點的相對位置以及鄰域大小。

```r
X <- circleUnif(n = 20)
DiagAlphaCmplx <- alphaComplexDiag(
  X = X, library = c("GUDHI", "Dionysus"), location = TRUE,
  printProgress = TRUE)
par(mfrow = c(1, 2))
plot(DiagAlphaCmplx[["diagram"]], main = "Alpha complex persistence diagram")
one <- which(DiagAlphaCmplx[["diagram"]][, 1] == 1)
one <- one[which.max(
  DiagAlphaCmplx[["diagram"]][one, 3] - DiagAlphaCmplx[["diagram"]][one, 2])]
plot(X, col = 1, main = "Representative loop")
for (i in seq(along = one)) {
  
  for (j in seq_len(dim(DiagAlphaCmplx[["cycleLocation"]][[one[i]]])[1])) {
    
    lines(DiagAlphaCmplx[["cycleLocation"]][[one[i]]][j, , ], pch = 19,
          cex = 1, col = i + 1)
  }
}
```

<img src="../Images/TDA_images/alpha_complex.png" alt="描述" width="500" height="300"></img>

### Persistence Diagram of Alpha Shape
該方法的建構先觀察不同半徑α的球體如何與點雲交互來確定那些單純形應該包括在內，當球體半徑小到不能圍繞任何子集的時候停止。
```r
n <- 30
X <- cbind(circleUnif(n = n), runif(n = n, min = -0.1, max = 0.1))
DiagAlphaShape <- alphaShapeDiag(
  X = X, maxdimension = 1, library = c("GUDHI", "Dionysus"), location = TRUE,
  printProgress = TRUE)
plot(DiagAlphaShape[["diagram"]], main = "Alpha Shape persistence diagram")
one <- which(DiagAlphaShape[["diagram"]][, 1] == 1)
one <- one[which.max(
  DiagAlphaShape[["diagram"]][one, 3] - DiagAlphaShape[["diagram"]][one, 2])]
plot(X[, 1:2], col = 2, main = "Representative loop of alpha shape filtration")
for (i in seq(along = one)) {
  for (j in seq_len(dim(DiagAlphaShape[["cycleLocation"]][[one[i]]])[1])) {
    lines(
      DiagAlphaShape[["cycleLocation"]][[one[i]]][j, , 1:2], pch = 19,
      cex = 1, col = i)
  }
}
```

<img src="../Images/TDA_images/alpha_shape.png" alt="描述" width="500" height="300"></img>

### Persistence Diagrams from Filtration
除了**ripsDiag、alphaComplexDiag和alphaShapeDia**計算持久特徵圖之外，也可以先計算過濾，而過濾可使用**ripsFiltration、alphaComplexFiltration和alphaShapeFiltration**

```r
X <- circleUnif(n = 100)
maxscale <- 0.4 # limit of the filtration
maxdimension <- 1 # components and loops
FltRips <- ripsFiltration(X = X, maxdimension = maxdimension,
                          maxscale = maxscale, dist = "euclidean", library = "GUDHI",
                          printProgress = TRUE)
par(mfrow = c(1, 2))
plot(DiagAlphaShape[["diagram"]])
plot(X[, 1:2], col = 2, main = "Representative loop of alpha shape filtration")
one <- which(DiagAlphaShape[["diagram"]][, 1] == 1)
one <- one[which.max(
  DiagAlphaShape[["diagram"]][one, 3] - DiagAlphaShape[["diagram"]][one, 2])]
for (i in seq(along = one)) {
  for (j in seq_len(dim(DiagAlphaShape[["cycleLocation"]][[one[i]]])[1])) {
    lines(
      DiagAlphaShape[["cycleLocation"]][[one[i]]][j, , 1:2], pch = 19,
      cex = 1, col = i)
    }
  }
```

<img src="../Images/TDA_images/alpha_shape_filtration.png" alt="描述" width="500" height="300"></img>

### Bottleneck and Wasserstein Distances
描述如何使用瓶頸距離(Bottleneck Distance)和Wasserstein距離比較持久性圖之間的相似或差異
1. **Bottleneck**
- 尋找一種將一個圖的特徵映射到另一個圖的特徵的最佳配對，使得配對中的最大匹配距離最小，專注於兩個持久性圖中最顯著的差異，忽略小的細節差異，所以處理噪聲特別有用。
2. **Wasserstein**
- 考慮兩持久性圖所有匹配點對之間的距離，計算了所有配對的成本，並試圖最小化這些成本和整體和。總題而言提供了更全面的相似性度量，因為考慮了持久性圖中所有特徵差異。
```r
# Bottleneck and Wasserstein Distances
Diag1 <- ripsDiag(Circle1, maxdimension = 1, maxscale = 5)
Diag2 <- ripsDiag(Circle2, maxdimension = 1, maxscale = 5)
print(bottleneck(Diag1[["diagram"]], Diag2[["diagram"]], dimension = 1))
print(wasserstein(Diag1[["diagram"]], Diag2[["diagram"]], p = 2, dimension = 1))
```

### Landscapes and Silhouettes
都是從持久性圖中總結信息的實值函數，透過將複雜的圖轉換為可進行統計分析的形式

1. **持久性地形(Persistence Landscapes)**
- 定義: 一系列連續、分段線性函數集合進行總結作圖，構建一個x軸為(birth+death)/2、y軸為(death-birth)/2的帳篷形狀函數，透過疊加後獲取一個分段線性曲線。

2. **輪廓(Silhouettes)**
- 根據持久性圖中的點構造的加權版本函數，全重是由持久性(d-b)的p次幂給出的。通過調整p，輪廓可以強調最持久特徵和均等對待所有特徵間進行權衡。當p較小，低持久特徵對輪廓貢獻更大；當p較大，輪廓更多被最持久的特徵值主導。

```r
maxscale <- 5
tseq <- seq(0, maxscale, length = 1000) #domain
Land <- landscape(DiagRips[["diagram"]], dimension = 1, KK = 1, tseq)
Sil <- silhouette(DiagRips[["diagram"]], p = 1, dimension = 1, tseq)
plot(tseq, Land, type = "l", xlab = "t", ylab = "Landscape")
plot(tseq, Sil, type = "l", xlab = "t", ylab = "Silhouette")
```

<img src="../Images/TDA_images/landscape_silhouettes.png" alt="描述" width="500" height="300"></img>

### Confidence Bands for Landscapes and Silhouettes
這段主要介紹如何使用boostrap算法來**為Landscapes和Silhouettes構建信賴區間(Confidence Bands)**，適合用在處理大型的資料，因為當計算整個數據的持久性圖時成本可能過高，所以通過**子樣本**的方式估計整體持久性特徵。

```r
N <- 4000
XX1 <- circleUnif(N / 2)
XX2 <- circleUnif(N / 2, r = 2) + 3
X <- rbind(XX1, XX2)
m <- 80 # subsample size
n <- 10 # we will compute n landscapes using subsamples of size m
tseq <- seq(0, maxscale, length = 500) #domain of landscapes
Diags <- list() # here we store n Rips diags
Lands <- matrix(0, nrow = n, ncol = length(tseq)) # here we store n landscapes
for (i in seq_len(n)) {
  subX <- X[sample(seq_len(N), m), ]
  Diags[[i]] <- ripsDiag(subX, maxdimension = 1, maxscale = 5)
  Lands[i, ] <- landscape(Diags[[i]][["diagram"]], dimension = 1,
                            KK = 1, tseq)
  }
bootLand <- multipBootstrap(Lands, B = 100, alpha = 0.05, parallel = FALSE)
plot(tseq, bootLand[["mean"]], main = "Mean Landscape with 95% band")
polygon(c(tseq, rev(tseq)),
        c(bootLand[["band"]][, 1], rev(bootLand[["band"]][, 2])),
        col = "pink")
lines(tseq, bootLand[["mean"]], lwd = 2, col = 2)
plot(X, col = 2, pch = 19, cex = 1.5)
```

<img src="../Images/TDA_images/conf_land_sil.png" alt="描述" width="500" height="300"></img>

### Selection of Smoothing Parameters
討論在拓樸推斷中**選擇平滑參數**(如KDE的h和DTM中的m0)的方法。通過比較不同平滑程度(h的值)下的持久性圖來找到最能反映數據重要拓樸特徵的平滑參數，方法依賴兩個度量:
1. **顯著特徵數(N(h))**
2. **總顯著持久性(S(h))**

當兩個度量隨h變化的特性反映一種拓樸偏差-方差權衡:當h很小，由於信賴帶寬度大，度量較小；當h很大，由於KDE的特徵被平滑化，這些度量同樣較小。因此選擇h的目標是最大化N(h)或S(h)

```r
XX1 <- circleUnif(600)
XX2 <- circleUnif(1000, r = 1.5) + 2.5
noise <- cbind(runif(80, -2, 5), runif(80, -2, 5))
X <- rbind(XX1, XX2, noise)
Xlim <- c(-2, 5)
Ylim <- c(-2, 5)
by <- 0.2
parametersKDE <- seq(0.1, 0.6, by = 0.05)
B <- 50 # number of bootstrap iterations. Should be large.
alpha <- 0.1 # level of the confidence bands
maxKDE <- maxPersistence(kde, parametersKDE, X,
                         lim = cbind(Xlim, Ylim), by = by, sublevel = FALSE,
                         B = B, alpha = alpha, parallel = TRUE,
                         printProgress = TRUE, bandFUN = "bootstrapBand")
print(summary(maxKDE))
plot(X, pch = 16, cex = 0.5, main = "Two Circles")
plot(maxKDE, main = "Max Persistence - KDE")
```

<img src="../Images/TDA_images/smoothing.png" alt="描述" width="500" height="300"></img>

## Density Clustering
介紹如何使用clusterTree函數實現基於**密度聚類的樹形結構**。這是一種根據樣本點在數據空間中的密度分布來進行聚類的方法，通過定義一個閾值λ，可以確定超級水平集和高密度區域，從而識別促具的高密度聚類。
1. 高密度區域: 對於給定閾值λ，超級水平集`Lf(λ)`定義為所有密度大於λ的點的集合，其d為子集稱為高密度區域。
2. 高密度聚類: 是`Lf(λ)`中最大的聯通子集。
3. 聚類密度樹: 通過同時考慮所有水平集(從λ = 0到λ = ∞)，可以記錄P的高密度聚類的演化和層次結構，形成聚類密度數`T := {Lf(λ), λ ≥ 0}`，具有樹的屬性，即任意兩個集合A和B在T中，要麻A ⊂ B，要麻B ⊂ A，要麻A∩B = ∅。

```r
X1 <- cbind(rnorm(300, 1, .8), rnorm(300, 5, 0.8))
X2 <- cbind(rnorm(300, 3.5, .8), rnorm(300, 5, 0.8))
X3 <- cbind(rnorm(300, 6, 1), rnorm(300, 1, 1))
XX <- rbind(X1, X2, X3)
Tree <- clusterTree(XX, k = 100, density = "knn",
                    printProgress = FALSE)
TreeKDE <- clusterTree(XX, k = 100, h = 0.3, density = "kde",
                       printProgress = FALSE)
par(mfrow = c(2, 2))
plot(Tree, type = "lambda", main = "lambda Tree (knn)")
plot(Tree, type = "kappa", main = "kappa Tree (knn)")
plot(TreeKDE, type = "lambda", main = "lambda Tree (kde)")
plot(TreeKDE, type = "kappa", main = "kappa Tree (kde)")
```

<img src="../Images/TDA_images/density_clustering.png" alt="描述" width="500" height="300"></img>
