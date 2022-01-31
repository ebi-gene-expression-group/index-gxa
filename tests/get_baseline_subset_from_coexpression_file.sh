#!/usr/bin/env bash

COEXP_TSV_GZ=$1
OUTPUT=$2

START_GENE=$3
NUM_GENES=$4

FILE=$(basename $COEXP_TSV_GZ | sed 's/.gz//')

let "STOP_GENE = $START_GENE + $NUM_GENES"

zcat < $COEXP_TSV_GZ | head -n 1 | cut -f 1,${START_GENE}-${STOP_GENE} > $OUTPUT/$FILE
zcat < $COEXP_TSV_GZ | sed -n "${START_GENE},${STOP_GENE}p" | cut -f 1,${START_GENE}-${STOP_GENE} >> $OUTPUT/$FILE

# Get all first column without first line to get slim IDs for reduce_datasets_to_ids.sh
cat < $OUTPUT/$FILE | cut -f 1 | tail -n +2 > slim_list.txt
echo "GeneID" >> slim_list.txt
echo "Gene ID" >> slim_list.txt

pushd $OUTPUT
gzip $FILE
