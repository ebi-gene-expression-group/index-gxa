#!/usr/bin/env bash

ID_SLIM_FILE=$1
SOURCE=$2
DEST=$3
ACCESSION=$( basename $DEST )

cp -a $SOURCE/*methods.tsv $DEST/
cp -a $SOURCE/*.xml $DEST/
cp -a $SOURCE/*condensed-sdrf.tsv $DEST/
cp -a $SOURCE/*idf.txt $DEST/

for SUFFIX in -fpkms.tsv .tsv.undecorated -tpms.tsv -raw-counts.tsv.undecorated -transcripts-tpms.tsv; do
  grep -f $ID_SLIM_FILE $SOURCE/${ACCESSION}${SUFFIX} > $DEST/${ACCESSION}${SUFFIX}
done
