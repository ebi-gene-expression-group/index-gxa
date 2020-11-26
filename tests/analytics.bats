setup() {
  export SOLR_COLLECTION=gxa-analytics-v1
}

@test "Check that curl is in the path" {
    run which curl
    [ "$status" -eq 0 ]
}

@test "Check that awk is in the path" {
    run which awk
    [ "$status" -eq 0 ]
}

@test "Check that jq is in the path" {
    run which jq
    [ "$status" -eq 0 ]
}

@test "Check that sdrf converter is in the path" {
    run which condSdrf2tsvForGXAJSONFactorsIndex.sh
    [ "$status" -eq 0 ]
}

@test "Check that filtering script is in the path" {
    run which jsonFilterEmptyFields.sh
    [ "$status" -eq 0 ]
}

@test "Check valid json output from sdrf converter" {
    condSdrf2tsvForgxaJSONFactorsIndex.sh $BATS_TEST_DIRNAME/example-bulk-conds-sdrf.tsv | jq -s .
    [  $? -eq 0 ]
}

@test "Check that filtering doesn't remove any assays" {
    ASSAY_COUNT=`condSdrf2tsvForGXAJSONFactorsIndex.sh $BATS_TEST_DIRNAME/example-bulk-conds-sdrf.tsv | jsonFilterEmptyFields.sh | grep \"assay\": | sort -u | wc -l`
    UNIQUE_ASSAY_COUNT=`condSdrf2tsvForGXAJSONFactorsIndex.sh $BATS_TEST_DIRNAME/example-bulk-conds-sdrf.tsv | grep \"assay\": | sort -u | wc -l`
    [ $ASSAY_COUNT = $UNIQUE_ASSAY_COUNT ]
}

@test "[analytics] Create collection on solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on solr"
  fi
  if [ ! -z ${SOLR_COLLECTION_EXISTS+x} ]; then
    skip "solr collection has been predifined on the current setup"
  fi
  run create-gxa-analytics-config-set.sh
  run create-gxa-analytics-collection.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Set no auto-create on solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on solr"
  fi
  run gxa-index-set-no-autocreate.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Load schema to collection on solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on solr"
  fi
  run create-gxa-analytics-schema.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Check that all fields are in the created schema" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping check of fields on schema"
  fi
  run analytics-check-created-fields.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Load data to solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-bulk-conds-sdrf.tsv
  run load_gxa_analytics_index.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Load additional dataset for deletion testing" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export EXP_ID=E-MTAB-111
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-conds-sdrf-delete.tsv
  sed s/E-MTAB-6870/$EXP_ID/ $BATS_TEST_DIRNAME/example-bulk-conds-sdrf.tsv > $CONDENSED_SDRF_TSV
  run load_gxa_analytics_index.sh && rm $CONDENSED_SDRF_TSV && analytics-check-experiment-available.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Delete additional dataset" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export EXP_ID=E-MTAB-111
  run delete_gxa_analytics_index.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] ontology biosolr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  run add-biosolr-lib.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Check correctness of load" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-bulk-conds-sdrf.tsv
  run analytics-check-index-content.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Check that deleted experiment is no longer available, but previous one is" {
  export EXP_ID=E-MTAB-111
  run analytics-check-experiment-available.sh
  # this will return exit code 1 if the experiment is not available
  [ "$status" -eq 1 ]
  export EXP_ID=E-MTAB-6870
  run analytics-check-experiment-available.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Check the health of experiments" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export ATLAS_EXPS=E-MTAB-6870
  export EXP_MATCH_MIN=999999999
  export EXP_MATCH_WARNING=100
  export EXPERIMENT_TYPE="gxa"
  # expect exit code 1 as the number of entries is lower than specified
  run gxa-index-check-experiments.sh 
  [ "$status" -eq 1 ]
  export EXP_MATCH_MIN=3
  run gxa-index-check-experiments.sh 
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

