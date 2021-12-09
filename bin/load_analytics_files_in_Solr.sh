#!/usr/bin/env bash

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $scriptDir/common_routines.sh

require_env_var "SOLR_HOST"
require_env_var "ACCESSIONS"
require_env_var "analytics_jsonl_dir"

# Load analytics files in Solr

failed=0
if [[ "$ACCESSIONS" == *","* ]]; then
  ACCESSIONS=$( echo $ACCESSIONS | sed 's/,/ /g')
fi

for EXP_ID in $ACCESSIONS; do
  if [ ! -z ${delete_existing+x} ]; then
    $scriptDir/delete_gxa_analytics_index.sh
  fi
  INPUT_JSONL=${analytics_jsonl_dir}/${EXP_ID}.jsonl SOLR_COLLECTION=bulk-analytics SCHEMA_VERSION=1 solr-jsonl-chunk-loader.sh  # SOLR_COLLECTION=bulk-analytics SOLR_PROCESSORS=dedupe
  if [ $? -ne 0 ]; then
    echo "Loading JSONL to $SOLR_HOST failed for $EXP_ID"
    failed=1
  fi
done

exit $failed
