library(sva)

TCGA_GENERIC_BatchCorrection <-function(GEN_Data,BatchData) {
  
  # select only samples with batch, others get deleted
  WithBatchSamples=is.element(colnames(GEN_Data),BatchData[,1])
  if (length(which(WithBatchSamples==FALSE))>0) GEN_Data=GEN_Data[,-which(WithBatchSamples==FALSE)]
  
  # select only the batch data that is present in the current data set, remove others (remember, the batch data is for all of TCGA)
  PresentSamples=is.element(BatchData[,1],colnames(GEN_Data))
  BatchDataSelected=BatchData
  if (sum(PresentSamples) != length(colnames(GEN_Data))) BatchDataSelected=BatchData[-which(PresentSamples==FALSE),]
  BatchDataSelected$Batch <- factor(BatchDataSelected$Batch)
  BatchDataSelected$ArrayName <- factor(BatchDataSelected$ArrayName)
  
  # reordening samples (not really necessary as Combat does this too)
  order <- match(colnames(GEN_Data),BatchDataSelected[,1])
  BatchDataSelected=BatchDataSelected[order,]
  BatchDataSelected$Batch <- factor(BatchDataSelected$Batch)
  
  # running combat
  GEN_Data_Corrected=ComBat(GEN_Data,BatchDataSelected[,3])
  class(GEN_Data_Corrected) <- "numeric"
  return(GEN_Data_Corrected)
}


TCGA_GENERIC_CheckBatchEffect <-function(GEN_Data,BatchData) {
  
  # select only samples with batch, others get deleted
  WithBatchSamples=is.element(colnames(GEN_Data),BatchData[,1])
  if (length(which(WithBatchSamples==FALSE))>0) GEN_Data=GEN_Data[,-which(WithBatchSamples==FALSE)]
  
  # select only the batch data that is present in the current data set, remove others (remember, the batch data is for all of TCGA)
  PresentSamples=is.element(BatchData[,1],colnames(GEN_Data))
  BatchDataSelected=BatchData
  if (sum(PresentSamples) != length(colnames(GEN_Data))) BatchDataSelected=BatchData[-which(PresentSamples==FALSE),]
  BatchDataSelected$Batch <- factor(BatchDataSelected$Batch)
  BatchDataSelected$ArrayName <- factor(BatchDataSelected$ArrayName)
  
  # reordening samples (not really necessary as Combat does this too)
  order <- match(colnames(GEN_Data),BatchDataSelected[,1])
  BatchDataSelected=BatchDataSelected[order,]
  BatchDataSelected$Batch <- factor(BatchDataSelected$Batch)
  
  # PCA analysis
  # alternatively use fast.prcomp from package gmodels, but tests do not show this is faster
  PCAanalysis=prcomp(t(GEN_Data))
  PCdata=PCAanalysis$x
  plot(PCdata[,1]~BatchDataSelected[,3])
  
  if (length(unique(BatchDataSelected$Batch[!is.na(BatchDataSelected$Batch)]))>1) {
    tmp=aov(PCdata[,1]~BatchDataSelected[,3])
    return(list(Pvalues=summary(tmp),PCA=PCdata,BatchDataSelected=BatchDataSelected))
  } else {
    return(-1)
  }
}
