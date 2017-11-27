library(readr)
library(tximport)
library(sva)
source("/srv/gevaertlab/data/Hong/TCGA/scripts/combat.R")

#######
# get gene level expression from transcript level result
#######
tx2gene<-read.table("/srv/gevaertlab/reference/GENCODE/release27/tx2gene.txt")
samples <- scan("/srv/gevaertlab/data/Hong/TCGA/HNSC/Kallisto/sampleID",what="character",quiet=TRUE)

### gather kallisto files
files <- file.path("/srv/gevaertlab/data/Hong/TCGA/HNSC/Kallisto/abundance",samples,"abundance.tsv")
all(file.exists(files))
names(files)<-samples

### tximport
Kallisto.txim <- tximport(files,type="kallisto",tx2gene = tx2gene)
#Kallisto.txim_adjustedcounts <- tximport(files,type="kallisto",tx2gene = tx2gene,countsFromAbundance = "lengthScaledTPM")

### get TPM values and modify column names
HNSC.Kallisto.TPM<-as.data.frame(Kallisto.txim$abundance)
colnames(HNSC.Kallisto.TPM)<-apply(read.table(text=colnames(HNSC.Kallisto.TPM),sep="-",as.is = T)[,1:4],1,paste,collapse="-")
colnames(HNSC.Kallisto.TPM)<-substr(colnames(HNSC.Kallisto.TPM),1,15)

#######
# load batch data
#######
load("/srv/gevaertlab/data/Hong/TCGA/BatchData.rda")

#######
# batch effect correction
#######
### Log normalization
HNSC.Kallisto.TPM[,1:ncol(HNSC.Kallisto.TPM)] <- sapply(HNSC.Kallisto.TPM[,1:ncol(HNSC.Kallisto.TPM)],function(x){replace(x,x<0.001,0.001)})
HNSC.Kallisto.TPMlog <- log(HNSC.Kallisto.TPM)

### check batch effect
HNSC.Kallisto.TPMlog.check<-TCGA_GENERIC_CheckBatchEffect(HNSC.Kallisto.TPMlog,BatchData)

### correct batch effect
HNSC.Kallisto.TPMlog.BatchEffcorrected<-TCGA_GENERIC_BatchCorrection(as.matrix(HNSC.Kallisto.TPMlog),BatchData)

### check batch effect again
HNSC.Kallisto.TPMlog.BatchEffcorrected.check<-TCGA_GENERIC_CheckBatchEffect(HNSC.Kallisto.TPMlog.BatchEffcorrected,BatchData)

### read gene annotation info
geneinfo<-read.table("/srv/gevaertlab/reference/GENCODE/release27/gencode.v27.gene.txt",sep="\t",head=F)
colnames(geneinfo) <- c("id","type","gene")

### write outputs
HNSC.Kallisto.TPMlog.BatchEffcorrected.m<-cbind(geneinfo[match(rownames(HNSC.Kallisto.TPMlog.BatchEffcorrected),geneinfo$id),],HNSC.Kallisto.TPMlog.BatchEffcorrected)
write.table(HNSC.Kallisto.TPMlog.BatchEffcorrected.m,"HNSC.Kallisto.TPMlog.txt",sep="\t",quote = F,row.names = F)
