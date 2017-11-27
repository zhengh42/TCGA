#######
# unzip fastq files
#######
tar -zxf ${FASTQ} --directory ${SEQ_DIR}

#######
# QC
#######
trim_galore -q 15 --stringency 3 --gzip --length 15 --paired  ${SEQ_DIR}/${IDA}_1.fastq ${SEQ_DIR}/${IDA}_2.fastq --fastqc --output_dir ${SEQ_DIR}

#######
# delete raw fastq files
#######
rm ${SEQ_DIR}/${IDA}_1.fastq ${SEQ_DIR}/${IDA}_2.fastq

#######
# run kallisto
#######
kallisto quant -i ${KALLISTO_INDEX} -o ${KALLISTO_DIR} ${SEQ_DIR}/${IDA}_1_val_1.fq.gz ${SEQ_DIR}/${IDA}_2_val_2.fq.gz
