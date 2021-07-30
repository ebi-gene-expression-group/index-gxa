#!/usr/bin/env bash
SCHEMA_VERSION=1

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"gxa-analytics-v$SCHEMA_VERSION"}
BASE=${SOLR_BASE_CONFIG:-"_default"}

printf "\n\nCreating config based on $BASE for our collection."
curl "http://$HOST/solr/admin/configs?action=CREATE&name=$CORE&baseConfigSet=$BASE"