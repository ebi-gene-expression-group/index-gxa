#!/usr/bin/env bash
SCHEMA_VERSION=1

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"bulk-analytics-v$SCHEMA_VERSION"}
SOLR_USER=${QUERY_USER:-"solr"}
SOLR_PASS=${QUERY_U_PWD:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

echo "Retrieving fields in the schema"
curl $SOLR_AUTH "http://$HOST/solr/$CORE/schema?wt=json" \
  | jq '.schema.fields + .schema.dynamicFields | .[].name ' | sed s/\"//g \
  | sort > analytics_loaded_fields.txt

echo "Parsing creation script"
grep -A 2 '\("add-field"\|"add-dynamic-field"\)' "$(dirname "${BASH_SOURCE[0]}")"/../bin/create-bulk-analytics-schema.sh \
  | grep '"name"' | awk -F':' '{ print $2 }' | sed 's/[\", ]//g' \
  | sort > analytics_expected_loaded_fields.txt

echo "Running comm"
comm -13 analytics_loaded_fields.txt analytics_expected_loaded_fields.txt 
