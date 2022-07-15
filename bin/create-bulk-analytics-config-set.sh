#!/usr/bin/env bash
SCHEMA_VERSION=1

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"bulk-analytics-v$SCHEMA_VERSION"}
BASE=${SOLR_BASE_CONFIG:-"_default"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

printf "\n\nDelete config $COLLECTION\n"
curl $SOLR_AUTH "http://$HOST/solr/admin/configs?action=DELETE&name=$COLLECTION"

printf "\n\nCreating config based on $BASE for our collection\n"
curl $SOLR_AUTH "http://$HOST/solr/admin/configs?action=CREATE&name=$COLLECTION&baseConfigSet=$BASE"
