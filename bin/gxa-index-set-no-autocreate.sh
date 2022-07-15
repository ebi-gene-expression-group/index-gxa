#!/usr/bin/env bash
SCHEMA_VERSION=1

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"bulk-analytics-v$SCHEMA_VERSION"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"


curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "set-user-property": {"update.autoCreateFields":"false"}
}' http://$HOST/solr/$CORE/config
