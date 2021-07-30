#!/usr/bin/env bash
set -e

[ -z ${BIOENTITIES_TSV+x} ] && echo "BIOENTITIES_TSV env var is needed." && exit 1
[ -z ${PROPERTY_WEIGHTS_YAML+x} ] && echo "PROPERTY_WEIGHTS_YAML env var is needed." && exit 1

export SCHEMA_VERSION=1
export SOLR_COLLECTION=bioentities-v$SCHEMA_VERSION

echo "Loading bioentities $BIOENTITIES_TSV into host $SOLR_HOST collection $SOLR_COLLECTION..."

bioentities2json.py -i ${BIOENTITIES_TSV} -p ${PROPERTY_WEIGHTS_YAML} | jsonFilterEmptyFields.sh | loadJSONIndexToSolr.sh