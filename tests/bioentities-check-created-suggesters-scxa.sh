#!/usr/bin/env bash
SCHEMA_VERSION=1

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"bioentities-v$SCHEMA_VERSION"}

echo "Checking suggesters in the schema"

for SUGGEST_DICTIONARY in propertySuggesterNoHighlight bioentitySuggester
do
  HTTP_STATUS=$(curl -s -w "%{http_code}" -o /dev/null "http://$HOST/solr/$CORE/suggest?suggest.dictionary=$SUGGEST_DICTIONARY")

  if [[ ! $HTTP_STATUS == 2* ]];
  then
    # HTTP Status is not a 2xx code, so it is an error.
    exit 1
  fi
done
