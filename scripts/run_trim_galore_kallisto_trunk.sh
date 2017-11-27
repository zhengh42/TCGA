source dsub_libs/bin/activate
export GS_BUCKET=gs://tcga_hong
export GS_PROJECT=ISB-CGC-data-Hong

dsub \
   --name trim-galore_kallisto \
   --project ${GS_PROJECT} \
   --zones 'us-west1-b' \
   --image "zhengh42/trim-galore_kallisto" \
   --min-ram 20 \
   --input "FASTQ=$FASTQ" \
   --input "KALLISTO_INDEX=${GS_BUCKET}/reference/gencode.v27.transcripts.kallisto.idx" \
   --env IDA=$IDA \
   --output-recursive "SEQ_DIR=${GS_BUCKET}/RNASeq/HNSC/seq" \
   --output-recursive "KALLISTO_DIR=${GS_BUCKET}/RNASeq/HNSC/Kallisto/$IDB" \
   --logging ${GS_BUCKET}/RNASeq/HNSC/logs/trim-galore_kallisto \
   --script scripts/trim-galore_kallisto.sh \
   --wait
