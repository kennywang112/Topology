library(TDA)
library(tidyverse)

data <- read_csv("../Kaggle_Data/heart_failure_clinical_records_dataset.csv")
# Xiris <- iris%>%select(Sepal.Length, Petal.Length)
data%>%colnames()
data%>%summary()
data <- data %>%
  mutate(across(c(age, creatinine_phosphokinase, ejection_fraction, 
                  platelets, serum_creatinine, serum_sodium, time), scale))
Xdata <- data%>%select(serum_creatinine, serum_sodium)
ggplot(data) + geom_point(aes(serum_creatinine, serum_sodium, color = as.character(DEATH_EVENT)))
Xlim <- c(-1, 1)
Ylim <- c(-1, 1)
by <- 0.05
Xseq <- seq(Xlim[1], Xlim[2], by = by)
Yseq <- seq(Ylim[1], Ylim[2], by = by)
Grid <- expand.grid(Xseq, Yseq)
par(mfrow = c(1, 2), bg = "gray")
KDE <- kde(X = Xdata, Grid = Grid, h = 0.3)
kNN <- knnDE(X = Xdata, Grid = Grid, k = 60)
DTM <- dtm(X = Xdata, Grid = Grid, m0 = 0.1)
persp(Xseq, Yseq,
      matrix(KDE, ncol = length(Yseq), nrow = length(Xseq)), xlab = "",
      ylab = "", zlab = "", theta = 30, phi = 20, ltheta = 50,
      border = NA, main = "KDE", d = 0.5, scale = FALSE, box = TRUE, col = "brown",
      expand = 3, shade = 0.9)
persp(Xseq, Yseq,
      matrix(kNN, ncol = length(Yseq), nrow = length(Xseq)), xlab = "",
      ylab = "", zlab = "", theta = 30, phi = 20, ltheta = 50,
      border = NA, main = "kNN", d = 0.5, scale = FALSE, box = TRUE, col = "brown",
      expand = 3, shade = 0.9)
persp(Xseq, Yseq,
      matrix(DTM, ncol = length(Yseq), nrow = length(Xseq)), xlab = "",
      ylab = "", zlab = "", theta = 30, phi = 20, ltheta = 50,
      col = 2, border = NA, main = "DTM", d = 0.5, scale = FALSE,
      expand = 3, shade = 0.9)

band <- bootstrapBand(X = Xdata, FUN = kde, Grid = Grid, B = 100,
                     parallel = FALSE, alpha = 0.1, h = 0.3)
# rips diagram
DiagRips <- ripsDiag(
  X = Xdata, maxdimension = 1, maxscale = 0.5, library = c("GUDHI", "Dionysus"), location = TRUE, printProgress = TRUE)
# and from filtration
FltRips <- ripsFiltration(
  X = Xdata, maxdimension = 1, maxscale = 0.5, 
  dist = "euclidean", library = "GUDHI", printProgress = TRUE)
dtmValues <- dtm(X = Xdata, Grid = Xdata, m0 = 0.1)
FltFun <- funFiltration(FUNvalues = dtmValues, cmplx = FltRips[["cmplx"]])
DiagFltFun <- filtrationDiag(
  filtration = FltFun, maxdimension = 1, 
  library = "Dionysus", location = TRUE, printProgress = TRUE)

plot(DiagRips[["diagram"]], band = 2 * band[["width"]], main = "Rips Diagram")
plot(DiagFltFun[["diagram"]], diagLim = c(0, 1), main = "Rips Diagram from Filtration")

# alpha complex diagram and loop
DiagAlphaCmplx <- alphaComplexDiag(
  X = Xdata, library = c("GUDHI", "Dionysus"), location = TRUE, printProgress = TRUE)
plot(DiagAlphaCmplx[["diagram"]], band = 2 * band[["width"]], main = "Alpha Complex Diagram")
one <- which(DiagAlphaCmplx[["diagram"]][, 1] == 1)
one <- one[which.max(
  DiagAlphaCmplx[["diagram"]][one, 3] - DiagAlphaCmplx[["diagram"]][one, 2])]
plot(Xdata, col = 1, main = "Representative loop")
for (i in seq(along = one)) {
  
  for (j in seq_len(dim(DiagAlphaCmplx[["cycleLocation"]][[one[i]]])[1])) {
    
    lines(DiagAlphaCmplx[["cycleLocation"]][[one[i]]][j, , ], pch = 19,
          cex = 1, col = i + 1)
  }
}














