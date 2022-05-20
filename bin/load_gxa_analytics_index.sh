#!/usr/bin/env bash
set -e

[ -z ${CONDENSED_SDRF_TSV+x} ] && echo "CONDENSED_SDRF_TSV env var is needed." && exit 1

export SCHEMA_VERSION=1
export SOLR_COLLECTION=bulk-analytics-v$SCHEMA_VERSION
#export PROCESSOR=$SOLR_COLLECTION\_dedup
export PROCESSOR=dedupe
#export ONTOLOGY_PROCESSOR=$SOLR_COLLECTION\_ontology_expansion

echo "Loading cond. sdrf $CONDENSED_SDRF_TSV into host $SOLR_HOST collection $SOLR_COLLECTION..."

condSdrf2tsvForGXAJSONFactorsIndex.sh $CONDENSED_SDRF_TSV | jsonFilterEmptyFields.sh | loadJSONIndexToSolr.sh

