#!/usr/bin/env bash
export SCHEMA_VERSION=1
export SOLR_COLLECTION=gxa-analytics-v$SCHEMA_VERSION
HOST=${SOLR_HOST:-localhost:8983}
CONFIG=$SOLR_COLLECTION

curl "http://$HOST/solr/admin/configs?action=DELETE&name=$CONFIG"
