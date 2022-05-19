#!/usr/bin/env bash
SCHEMA_VERSION=1
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"bulk-analytics-v$SCHEMA_VERSION"}

curl "http://${SOLR_HOST}/solr/admin/collections?action=CLUSTERSTATUS&collection=${COLLECTION}" | jq '..|.replicas? | select( . != null ) | to_entries | .[] | .value | (.base_url|tostring)+"/admin/cores?action=STATUS&core="+(.core|tostring)' | xargs curl -s | jq '..|.deletedDocs? | select( . != null )' | uniq
