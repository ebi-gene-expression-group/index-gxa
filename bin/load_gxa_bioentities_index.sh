#!/usr/bin/env bash
set -e

[ -z ${BIOENTITIES_TSV+x} ] && echo "BIOENTITIES_TSV env var is needed." && exit 1

export SCHEMA_VERSION=1
export SOLR_COLLECTION=bioentities-v$SCHEMA_VERSION
export PROCESSOR=$SOLR_COLLECTION\_dedup
export ONTOLOGY_PROCESSOR=$SOLR_COLLECTION\_ontology_expansion

echo "Loading bioentities $BIOENTITIES_TSV into host $SOLR_HOST collection $SOLR_COLLECTION..."

bioentities2json.py -i ${BIOENTITIES_TSV} | jsonFilterEmptyFields.sh | loadJSONIndexToSolr.sh