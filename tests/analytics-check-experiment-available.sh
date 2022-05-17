#!/usr/bin/env bash
SCHEMA_VERSION=1

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"bulk-analytics-v$SCHEMA_VERSION"}
SOLR_USER=${QUERY_USER:-"solr"}
SOLR_PASS=${QUERY_U_PWD:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

entries=$(curl $SOLR_AUTH "http://$HOST/solr/$CORE/select?fl=experiment_accession&q=experiment_accession:%22$EXP_ID%22" |   jq '.response.numFound')

if [ $entries -lt 1 ]; then
  echo "$EXP_ID not present in index $CORE at $HOST"
  exit 1
fi  
