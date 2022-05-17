#!/usr/bin/env bash
export SCHEMA_VERSION=1
export SOLR_COLLECTION=bulk-analytics-v$SCHEMA_VERSION
HOST=${SOLR_HOST:-localhost:8983}
CONFIG=$SOLR_COLLECTION
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

curl $SOLR_AUTH "http://$HOST/solr/admin/configs?action=DELETE&name=$CONFIG"
