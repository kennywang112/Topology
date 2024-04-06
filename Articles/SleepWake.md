## How to practically apply topology in prediction.

In the previous article, I discussed the use of Topological Data Analysis (TDA) in analyzing time series data, and I summarized a real-world application of this method in vehicle flow. In this article, I will introduce how TDA functions in analyzing both **vehicle flow** and **heart rate** data to enhance our understanding of predictive modeling using topological machine learning. This article references three papers, and I will include the links below.

## Papers
We know that at the heart of Topological Data Analysis (TDA) is persistent homology, which identifies persistent features by observing holes. The previous article discussed how we can detect these holes in time series data using **Time-delay (Taken's) embedding**. But have you ever considered what comes after this initial workflow? Next, I'm going to introduce some practical **processes** derived from academic papers, instead of conclusions.

> Basic TDA Workflow: point cloud → nested complexes → persistence module → barcode or diagram

### Sleep-Wake
The first paper focuses on Sleep-Wake Classification and follows the same procedures as previously described. This paper reconstructs the data using time-delay embedding, computes the Vietoris-Rips complex, extracts persistence statistics, and then applies models such as **Random Forest, k-means, and neural networks**. It undergoes training on the CGMH dataset, followed by validation and testing on the DREAMS and UCDSADB datasets. Subsequently, it calculates True Positives (TP), False Positives (FP), True Negatives (TN), False Negatives (FN), sensitivity (se), specificity (sp), accuracy (acc), precision (pr), F1 score (f1), AUC score (auc), and kappa coefficient (kappa). Although this process shares similarities with the aforementioned paper, it enriches the discussion by providing a useful chart that depicts the relationships among TDA tools, including **barcode, persistence images, landscapes, curves, and codebooks** .etc.

> Method: Time-delay embedding → Persistent diagram → persistence statistics → Random Forest, k-means, and neural networks

### Instantaneous Heart Rate
The second paper focuses on classifying the sleep stages of a participant using observed instantaneous heart rate (IHR). This study primarily revolves around the **Delaunay-Rips Complex**, which optimizes the Vietoris-Rips and Alpha Complexes filtration by speeding up the computation without impacting the model's accuracy. After subsequent vectorizations using **persistence statistics**, the model is trained and validated using **SVM**. Subsequently, the performance is evaluated by computing sensitivity (se), specificity (sp), accuracy (acc), precision (pr), F1 score (f1), AUC-score (auc), average precision score (aps), and kappa coefficient (kappa).

> Method: Time-delay embedding → Persistent diagram → persistence statistics → SVM

### Traffic flow
The third paper contrasts traffic flow across different weeks, where one can easily discern peaks and normal moments, akin to a wave pattern. By combine these into an image resembling a wave and then applying Time-delay embedding, we transition into another dimensional space. However, in real-world data, the cycle won't be regular. Therefore, a denoising step is employed using the **ParfreeDeclutter Algorithm**. After denoising, the time-delay embedding dimension is set to 5 to capture more complex dynamics, with a 250-minute delay time. Subsequently, **Principal components analysis(PCA)** is used to map the data into a 2-dimensional space.

After data preprocessing, the author carried out the TDA workflow described above and obtained **Vietoris-Rips persistence diagrams** across different weeks. Then, **hierarchical clustering and K-means clustering** was performed based on the **Bottleneck distance and Wasserstein distance** respectively.

> Method: Time-delay embedding → Denoising → PCA → Persistent diagram → compute Distance → Clustering

## Note
It is evident that when data involves time series, Takens' embedding is necessary, as real-world data often requires preprocessing to reveal any underlying structures. Subsequently, the use of persistent diagrams becomes crucial for identifying these structures. However, these structures can be computed in various ways. The first paper extends certain tools to provide insights during analysis, while the second paper proposes filtration methods that optimize Vietoris-Rips (VR) and Alpha complexes, offering valuable perspectives for analysis. These two papers employ similar methodologies for obtaining their results, with the second citing the first for reference. The third paper, however, diverges by introducing an algorithm to denoise the data. Instead of directly mapping the data to a two-dimensional space from the embedding, it employs Principal Component Analysis (PCA) and utilizes unsupervised learning (clustering) to analyze the processed data.

## Conclusion
This article aims to provide a glimpse into how research papers analyze time series data using topological data analysis. At the core of persistent homology is the concept of identifying 'holes' by expanding radii, a process that is fundamentally not as complex as it might seem. I recommend gaining an understanding of how complexes operate, particularly how the Delaunay-Rips Complex distinguishes itself from others, and grasping the mathematical basis of distances. My hope is that this article will inspire you to analyze data by integrating various methods. It's always thrilling to review papers that employ diverse analytical approaches. I believe that creativity can render your analysis more vivid and engaging.