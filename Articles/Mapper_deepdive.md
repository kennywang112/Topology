# 深入討論拓樸資料分析中的Mapper algorithm
Mapper作為在拓樸資料分析中最著名的方法之一，很常被應用在探索空間資料中的隱藏結構，其中Gunnar Carlsson所創立的Ayasdi在推動拓樸資料分析的方法尤為關鍵，在許多領域上都有重要的貢獻。上一篇討論到了幾個使用該法研究的論文以及Mapper的簡單步驟，今天我想要討論的是Mapper的核心概念，會從頭開始說起。
首先我想複習一下上次所提到的內容，也就是Mapper的四個步驟:
1. Identify a lower-dimensional mapping function for mapping.
2. Determine the intervals and overlaps.
3. Map back to identify which data points correspond to the intervals and overlaps.
4. Cluster the data points for data compression.

我們都知道這些步驟的意義，但是他又和拓樸本身有甚麼關係?為了解釋它，我想提到兩個概念:Nerve Theorem以及Simplicial complex

> 我需要先說明我並非拓樸學家，只是因為興趣所以自學拓樸資料分析的人，所以在拓樸嚴格的定義空間概念我不會去討論，而是以怎麼將它應用在資料上，找出拓樸的價值。

## Simplicial complex
Simplicial complex是一種資料點之間的連接的集合，若兩個資料點連接到對方，會視為一種1維度的simplices，三筆資料的連接會形成一個三角形，或是說一個孔，是一個2維度的simplices，而simplicial complex就是一個collection，包含了該空間內所有的simplices。其中資料點連接到對方的方式可以分為好幾種，例如Vietoris-Rips，Cech，Alpha，以及為了提升計算效能而在後來被提出的Delaunay-Rips，都是通過各個資料點半徑的逐漸增加或選定半徑來連接，弱勢多尺度問題則可以繼續探索persistent homology，但我想把它單獨介紹。若是要從公式表示simplices，可視為一個Ball: $\mathbb{B}_\mathbb{X} := \{ y \in \mathbb{X}: d(x,y)<r \}$，而根據上述幾個不同的Simplicial complex可以知道它的定義會因此有些微差距，但核心概念是一致的。

![alt text](/Images/medium/complexes.png)
此圖取自論文(2)

## Nerve Theorem
nerve是形容一個simplicial complex C(u)摘要的方法，其中u為cover，定義為:
$u = (U_i)_{i\in I}$
代表了資料集之間的覆蓋，也會是壓縮資料的頂點。舉下列例子，當一筆圓形的資料集有三個cover，它的nerve會是一個三角形，因為三個cover壓縮成了頂點，而overlap的部分變為edges，而Nerve將表示為$N(u) = \{\{U_1,...,U_k\}\subset u : \cap^k_{j=1}U_j \neq \varnothing\}$

![alt text](/Images/medium/image.png)
此圖取自論文(1)

有沒有發現這樣的結構就是一個Mapper的基礎，其架構為一個Nerve Theorem，且它的輸出為一種simplicial complex!


(1) Chazal, F., & Michel, B. (2021). An introduction to topological data analysis: fundamental and practical aspects for data scientists. Frontiers in artificial intelligence, 4, 667963.
(2) Mishra, A., & Motta, F. C. (2023). Stability and machine learning applications of persistent homology using the Delaunay-Rips complex. Frontiers in Applied Mathematics and Statistics, 9, 1179301.

## 總結
本篇的內容也算是很少，主要是我臨時有空就會想稍微補充或更新一下前幾篇的不足，其實還有很多想跟大家分享，例如persistent家族，hausdorff對資料離群的穩健等等，其中最近開始學地理資訊系統(GIS)後理解一些和拓樸之間的關聯，例如Voronoi/Theissen圖形的方法等。總體而言拓樸雖然很抽象，但是我反而覺得它也因此有很大的發揮空間，畢竟拓樸資料分析相關的論文還是較少的。我目前在研究的是Mapper algorithm和線性、非線性降維，以及和clustering方法的比較，雖然我很想在這裡分享，但我還是想要讓結果被研討會確認過後再分享。最後，如果本篇有任何錯誤的點，歡迎糾正我，大四生的理解能力可能較為有限:)