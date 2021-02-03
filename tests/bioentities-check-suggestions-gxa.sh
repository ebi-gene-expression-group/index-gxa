#!/usr/bin/env bash
SCHEMA_VERSION=1

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"bioentities-v$SCHEMA_VERSION"}

echo "Checking suggesters..."

curl -s -o /dev/null "http://$HOST/solr/$CORE/suggest?suggest.dictionary=propertySuggester&suggest.build=true"

NUM_SUGGESTIONS=$(curl -s \
  "http://$HOST/solr/$CORE/suggest?suggest.dictionary=propertySuggester&suggest.q=pseudo" | \
  jq '.suggest.propertySuggester.pseudo.numFound')
if ((! $NUM_SUGGESTIONS > 0 ))
then
  exit 1
fi

NUM_SUGGESTIONS=$(curl -s \
  "http://$HOST/solr/$CORE/suggest?suggest.dictionary=propertySuggester&suggest.q=foobar" | \
  jq '.suggest.propertySuggester.foobar.numFound')
if (( $NUM_SUGGESTIONS != 0 ))
then
  exit 1
fi
