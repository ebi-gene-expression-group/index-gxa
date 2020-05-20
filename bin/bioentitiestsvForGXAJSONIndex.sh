#!/usr/bin/env bash

awk -F'\t' 'BEGIN { OFS = "\t"; } { if( $4 == "factor" || $4 == "characteristic" ) { gsub(/ /, "_", $5); print "{ \"experiment_accession\": \""$1"\",\n \"cell_id\": \""$3"\",\n \""$4"_name\": \""$5"\",\n \""$4"_value\": [\""$6"\"],\n \"ontology_annotation\": [\""$7"\"] }"; } }' $1