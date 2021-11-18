#!/usr/bin/env bash

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $scriptDir/common_routines.sh

require_env_var "SOLR_HOST"
require_env_var "ACCESSIONS"
require_env_var "output_dir"

# Load analytics files in Solr

failed=0

for FILE in $output_dir/$ACCESSIONS
do
  INPUT_JSONL=${FILE}.jsonl SOLR_COLLECTION=gxa-analytics SCHEMA_VERSION=1 solr-jsonl-chunk-loader.sh  # SOLR_COLLECTION=bulk-analytics SOLR_PROCESSORS=dedupe
  if [ $? -ne 0 ]; then
    echo "Loading JSONL to $SOLR_HOST failed for $FILE"
    failed=1
  fi
done

exit $failed

