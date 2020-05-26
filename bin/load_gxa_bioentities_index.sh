#!/usr/bin/env bash
set -e

[ -z ${BIOENTITIES_JSON+x} ] && echo "BIOENTITIES_JSON env var is needed." && exit 1

export SCHEMA_VERSION=1
export SOLR_COLLECTION=bioentities-v$SCHEMA_VERSION
export PROCESSOR=$SOLR_COLLECTION\_dedup
export ONTOLOGY_PROCESSOR=$SOLR_COLLECTION\_ontology_expansion

echo "Loading bioentities $BIOENTITIES_JSON into host $SOLR_HOST collection $SOLR_COLLECTION..."

#cat $BIOENTITIES_JSON | jsonFilterEmptyFields.sh | loadJSONIndexToSolr.sh
cat $BIOENTITIES_JSON | loadJSONIndexToSolr.sh