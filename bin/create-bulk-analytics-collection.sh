#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. ${DIR}/schema-version.env
. ${DIR}/common_routines.sh

# Exit on error and fail pipelines if any command fails
set -e
set -o pipefail

# On developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u ${SOLR_USER}:${SOLR_PASS}"
COLLECTION=${SOLR_COLLECTION:-"bulk-analytics-v${SCHEMA_VERSION}"}
DEBUG_POPULATION=${DEBUG_POPULATION:-"false"}

NUM_SHARDS=${SOLR_NUM_SHARDS:-1}
REPLICATION_FACTOR=${SOLR_REPLICATION_FACTOR:-1}
# Default curl behavior: silent progress, show errors, fail on HTTP errors
export CURL_OUTPUT_PARSER=$(which jq > /dev/null && echo jq || echo tee)

CURL_OPTS="${SOLR_AUTH} --fail"
if [ "${DEBUG_POPULATION}" = "true" ]; then
  set -vx
  CURL_OPTS="$CURL_OPTS -v"
fi

info "Deleting alias 'bulk-analytics' if exists"
curl $CURL_OPTS "http://${HOST}/solr/admin/collections?action=DELETEALIAS&name=bulk-analytics" > /dev/null 2>&1 || warn "Alias delete may have been unnecessary"

info "Deleting collection ${COLLECTION} on ${HOST} (ignore if not exists)"
curl ${CURL_OPTS} "http://${HOST}/solr/admin/collections?action=DELETE&name=${COLLECTION}" || warn "Collection delete may have been unnecessary"

info "Creating collection ${COLLECTION} on ${HOST}"
curl ${CURL_OPTS} "http://${HOST}/solr/admin/collections?action=CREATE&name=${COLLECTION}&numShards=${NUM_SHARDS}&replicationFactor=${REPLICATION_FACTOR}" | $CURL_OUTPUT_PARSER
success "Collection ensured: ${COLLECTION}"

#############################################################################################

info "Disabling auto-commit and soft auto-commit in ${COLLECTION}"
curl ${CURL_OPTS} "http://${HOST}/solr/${COLLECTION}/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoCommit.maxTime":-1
  }
}' | $CURL_OUTPUT_PARSER

curl ${CURL_OPTS} "http://${HOST}/solr/${COLLECTION}/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoCommit.maxDocs":-1
  }
}' | $CURL_OUTPUT_PARSER

curl ${CURL_OPTS} "http://${HOST}/solr/${COLLECTION}/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoSoftCommit.maxTime":-1
  }
}' | $CURL_OUTPUT_PARSER

curl ${CURL_OPTS} "http://${HOST}/solr/${COLLECTION}/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoSoftCommit.maxDocs":-1
  }
}' | $CURL_OUTPUT_PARSER
#############################################################################################

info "Creating alias 'bulk-analytics' -> ${COLLECTION}"
printf "\n\nAliasing base collection atlas-bulk to latest iteration ${COLLECTION}\n"
curl ${CURL_OPTS} "http://${HOST}/solr/admin/collections?action=CREATEALIAS&name=bulk-analytics&collections=${COLLECTION}" | $CURL_OUTPUT_PARSER

success "created collection ${COLLECTION}"
