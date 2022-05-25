#!/usr/bin/env bash
SCHEMA_VERSION=1

set -e

# On developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"bulk-analytics-v$SCHEMA_VERSION"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

NUMSHARDS=${SOLR_NUM_SHARDS:-1}
REPLICATES=${SOLR_REPLICATION_FACTOR:-1}
MAX_SHARDS_PER_NODE=${SOLR_MAX_SHARDS_PER_NODE:-1}

printf "\n\nDeleting collection $COLLECTION based on $HOST\n"
curl $SOLR_AUTH "http://$HOST/solr/admin/collections?action=DELETE&name=$COLLECTION"

printf "\n\nCreating collection $COLLECTION based on $HOST\n"
curl $SOLR_AUTH "http://$HOST/solr/admin/collections?action=CREATE&name=$COLLECTION&numShards=$NUMSHARDS&replicationFactor=$REPLICATES&maxShardsPerNode=$MAX_SHARDS_PER_NODE"

#############################################################################################

printf "\n\nAliasing base collection atlas-bulk to latest iteration $COLLECTION\n"
curl $SOLR_AUTH "http://$HOST/solr/admin/collections?action=CREATEALIAS&name=bulk-analytics&collections=$COLLECTION"

#############################################################################################

printf "\n\nDisabling auto-commit and soft auto-commit in $COLLECTION\n"
curl $SOLR_AUTH "http://$HOST/solr/$COLLECTION/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoCommit.maxTime":-1
  }
}'

curl $SOLR_AUTH "http://$HOST/solr/$COLLECTION/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoCommit.maxDocs":-1
  }
}'

curl $SOLR_AUTH "http://$HOST/solr/$COLLECTION/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoSoftCommit.maxTime":-1
  }
}'

curl $SOLR_AUTH "http://$HOST/solr/$COLLECTION/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoSoftCommit.maxDocs":-1
  }
}'
