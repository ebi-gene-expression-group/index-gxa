#!/usr/bin/env bash
export SCHEMA_VERSION=1
export SOLR_COLLECTION=bulk-analytics-v$SCHEMA_VERSION
HOST=${SOLR_HOST:-localhost:8983}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

set -e

[ -z ${EXP_ID+x} ] && echo "EXP_ID env var is needed." && exit 1

curl $SOLR_AUTH "http://$HOST/solr/$SOLR_COLLECTION/update?commit=true" -H "Content-Type: text/xml" \
  --data-binary "<delete><query>experiment_accession:$EXP_ID</query></delete>"
