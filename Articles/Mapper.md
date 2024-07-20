# What is Mapper
這篇主要針對拓樸資料分析中的Mapper Algo進行討論，理解Mapper的設計原理以及優勢，並介紹該方法的幾個範例。預設讀者對拓樸資料分析有初步認識，但還是會簡單帶過概念。

## 拓樸資料分析在做甚麼

## 原理
通常在使用PCA的時候會想要再降低維度的同時保留重要的訊息，並且通過找出主成分來做進一步地作圖、分類或是聚類等等的分析，但是這樣的做法有幾個缺點:
1. 視覺化是使用PC的前幾個最大變異來作圖，雖然好的成分可以分割出不同的區塊，那麼壞的要怎麼解釋
2. 線性降維的結果可能損失重要資訊，小的變異可能也有有價值的結果

那有一個方法可以減緩這樣的結果，那就是Mapper Algorithm

## 範例

An Introduction to Topological Data Analysis: Fundamental and Practical Aspects for Data Scientists
https://www.frontiersin.org/journals/artificial-intelligence/articles/10.3389/frai.2021.667963/full
Identification of type 2 diabetes subgroups through topological analysis of patient similarity
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4780757/
Topological data analysis in biomedicine: A review
https://www.sciencedirect.com/science/article/pii/S1532046422000983?ref=pdf_download&fr=RR-2&rr=87c89b378a4d8f1f
Deciphering Active Wildfires in the Southwestern USA Using Topological Data Analysis
https://www.mdpi.com/2225-1154/7/12/135
Towards a new approach to reveal dynamical organization of the brain using topological data analysis
https://www.nature.com/articles/s41467-018-03664-4.pdf