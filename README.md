# Data access
The TCGA data is accessed from ISB-CGC, stored in Google Cloud.

Some useful gc commands:

gcloud init # set up project

gcloud projects list # list all projects

gcloud config list # find current project

gcloud config set compute/region NAME # change default Compute Engine region

# Process
RNASeq data (FastQ) was re-processed using Kallisto and GENCODE release 27 (GRCh38).

dsub was used to submit jobs to Google Cloud.

# Downstream processing
After Kallisto processing, gene-level expression was aggregated from transcript-level results using tximport. TPM values was log transformed. Batch effect was corrected using ComBat. See HNSC/tximport_combat.R for details.
