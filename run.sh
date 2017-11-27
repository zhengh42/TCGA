source dsub_libs/bin/activate
export GS_BUCKET=gs://tcga_hong
export GS_PROJECT=ISB-CGC-data-Hong

#######
# download transcriptome fasta file
#######
curl -L ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_27/gencode.v27.transcripts.fa.gz | gsutil cp - ${GS_BUCKET}/reference/gencode.v27.transcripts.fa.gz

#######
# build transcriptome index for kallisto
#######
dsub \
   --name kallisto_index \
   --project ${GS_PROJECT} \
   --zones 'us-west1-b' \
   --image "zhengh42/kallisto:0.43.1" \
   --input "KALREF=${GS_BUCKET}/reference/gencode.v27.transcripts.fa.gz" \
   --output "KALIDX=${GS_BUCKET}/reference/gencode.v27.transcripts.kallisto.idx" \
   --logging ${GS_BUCKET}/logs/kallisto_index \
   --command 'kallisto index -i ${KALIDX} ${KALREF}' \
   --min-ram 16 \
   --wait

#######
# get the listing of files
#######
gsutil ls gs://5aa919de-0aa0-43ec-9ec3-288481102b6d/tcga/HNSC/RNA/RNA-Seq/UNC-LCCC/ILLUMINA > HNSC/TCGA.HNSC.RNASeq.gslist
wget https://raw.githubusercontent.com/isb-cgc/readthedocs/master/docs/include/LATEST_MANIFEST.tsv
less LATEST_MANIFEST.tsv  | grep RNA-Seq  | grep -v miRNA-Seq | grep unaligned > LATEST_MANIFEST.RNASeq.unaligned.tsv
less LATEST_MANIFEST.RNASeq.unaligned.tsv | awk 'OFS="\t"{print $2,$0}' | sed 's/-[0-9][0-9][ABC]-[[:graph:]]*//' | egrep -v 'poor quality' | awk '$4=="HNSC"' > HNSC/LATEST_MANIFEST.RNASeq.unaligned.HNSC.tsv
less HNSC/TCGA.HNSC.RNASeq.gslist | awk 'OFS="\t"{print $1,$1}' | sed 's/[[:graph:]]*ILLUMINA\///' | grep 'tar.gz' | match.pl - 1 HNSC/LATEST_MANIFEST.RNASeq.unaligned.HNSC.tsv 15 | paste - HNSC/LATEST_MANIFEST.RNASeq.unaligned.HNSC.tsv | cut -f1,2,5 > HNSC/LATEST_MANIFEST.RNASeq.unaligned.HNSC.gslist.tsv

#######
# build jobs to run
#######
less HNSC/LATEST_MANIFEST.RNASeq.unaligned.HNSC.gslist.tsv | cut -f1 | cut -d "." -f3- | sed 's/.tar.gz/_tar.gz/' | awk -F "_" 'OFS="_"{print $1,$2,$3,$4,$6,"L00"$5}' | paste - HNSC/LATEST_MANIFEST.RNASeq.unaligned.HNSC.gslist.tsv | awk 'OFS="\t"{print "FASTQ=\""$3"\";","IDA=\""$1"\";","IDB=\""$4"\""}'  > HNSC/LATEST_MANIFEST.RNASeq.unaligned.HNSC.gslist.dsub

less HNSC/LATEST_MANIFEST.RNASeq.unaligned.HNSC.gslist.dsub | awk '$2!~/tar.gz/' > HNSC/LATEST_MANIFEST.RNASeq.unaligned.HNSC.gslist.dsub.clean
#less HNSC/LATEST_MANIFEST.RNASeq.unaligned.HNSC.gslist.dsub | awk '$2~/tar.gz/' > HNSC/LATEST_MANIFEST.RNASeq.unaligned.HNSC.gslist.dsub.check # check the correct name manually
cat HNSC/LATEST_MANIFEST.RNASeq.unaligned.HNSC.gslist.dsub.clean | while read LINE; do echo "$LINE" > test; pre=`less test | awk '{print $3}' | sed 's/.*="//;s/"//'`; cat test scripts/run_trim_galore_kallisto_trunk.sh > HNSC/jobs/run_persample.${pre}.sh ; done
cat HNSC/LATEST_MANIFEST.RNASeq.unaligned.HNSC.gslist.dsub.check | while read LINE; do echo "$LINE" > test; pre=`less test | awk '{print $3}' | sed 's/.*="//;s/"//'`; cat test scripts/run_trim_galore_kallisto_trunk.sh > HNSC/jobs/run_persample.${pre}.sh ; done

