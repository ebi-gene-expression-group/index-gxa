#!/usr/bin/env bash
SCHEMA_VERSION=1

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"gxa-analytics-v$SCHEMA_VERSION"}
NUMSHARDS=${SOLR_NUM_SHARD:-1}
REPLICATES=${SOLR_NUM_REPL:-1}

printf "\n\nCreating collection $CORE based on $HOST"
curl "http://$HOST/solr/admin/collections?action=CREATE&name=$CORE&numShards=$NUMSHARDS&replicationFactor=$REPLICATES"

# Set this value to whatever is needed, it doesn’t really matter with current Lucene versions
# https://issues.apache.org/jira/browse/SOLR-4586
MAX_BOOLEAN_CLAUSES=16384
printf "\n\nRaising value of maxBooleanClauses to $MAX_BOOLEAN_CLAUSES."
curl "http://$HOST/solr/$CORE/config" -H 'Content-type:application/json' -d "
{
  "set-property": {
    "query.maxBooleanClauses" : ${MAX_BOOLEAN_CLAUSES}
  }
}"