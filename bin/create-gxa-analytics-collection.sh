#!/usr/bin/env bash
SCHEMA_VERSION=1

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"bulk-analytics-v$SCHEMA_VERSION"}
NUMSHARDS=${SOLR_NUM_SHARD:-1}
REPLICATES=${SOLR_NUM_REPL:-1}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

printf "\n\nCreating collection $CORE based on $HOST"
curl $SOLR_AUTH "http://$HOST/solr/admin/collections?action=CREATE&name=$CORE&numShards=$NUMSHARDS&replicationFactor=$REPLICATES"

# Set this value to whatever is needed, it doesn’t really matter with current Lucene versions
# https://issues.apache.org/jira/browse/SOLR-4586
MAX_BOOLEAN_CLAUSES=100000000
printf "\n\nRaising value of maxBooleanClauses to $MAX_BOOLEAN_CLAUSES."
curl $SOLR_AUTH "http://$HOST/solr/$CORE/config" -H 'Content-type:application/json' -d "
{
  "set-property": {
    "query.maxBooleanClauses" : ${MAX_BOOLEAN_CLAUSES}
  }
}"
