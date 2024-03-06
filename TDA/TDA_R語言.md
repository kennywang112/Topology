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
<img src="../Images/kde_diag.png" alt="描述" width="300" height="300"></img>

### 條碼圖(Barcode)
這張圖注意到X軸為time，也就是當掃描不同尺度(scale)的分析中拓樸特徵隨時間的產生以及消失，每個水平線都代表了一個特徵，左端為"出生"，右端為"死亡"，分別為它在過濾過程中首次出現的比例以及特徵不再存在的比例。
從我們的主題Persistent Homology中可知道這個圖主要想表達的是資料的持久性，希望找到的是真正存在的資料而非噪音。其中短紅色表示該特徵存在較少的時間，最底部的黑色則是我們尋找的**持久**，這張圖的資料和上面的KDE diagram是一樣的，紅色線也對應到上方的三角形
```r
plot(DiagGrid[["diagram"]], barcode = TRUE, main = "Barcode")
```

<img src="../Images/barcode.png" alt="描述" width="300" height="300"></img>