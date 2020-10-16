#!/usr/bin/env bash

awk -F'\t' 'BEGIN { OFS = "\t"; } { if( $4 == "factor" ) { gsub(/ /, "_", $5); print $1, $3, "factor_"$5, $6; } }' $1
