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

@test "Check that SDRF converter is in the path" {
    run which condSdrf2tsvForGXAJSONFactorsIndex.sh
    [ "$status" -eq 0 ]
}

@test "Check that filtering script is in the path" {
    run which jsonFilterEmptyFields.sh
    [ "$status" -eq 0 ]
}

@test "Check valid JSON output from SDRF converter" {
    condSdrf2tsvForgxaJSONFactorsIndex.sh $BATS_TEST_DIRNAME/example-bulk-conds-sdrf.tsv | jq -s .
    [  $? -eq 0 ]
}

@test "Check that filtering doesn't remove any assays" {
    ASSAY_COUNT=`condSdrf2tsvForGXAJSONFactorsIndex.sh $BATS_TEST_DIRNAME/example-bulk-conds-sdrf.tsv | jsonFilterEmptyFields.sh | grep \"assay\": | sort -u | wc -l`
    UNIQUE_ASSAY_COUNT=`condSdrf2tsvForGXAJSONFactorsIndex.sh $BATS_TEST_DIRNAME/example-bulk-conds-sdrf.tsv | grep \"assay\": | sort -u | wc -l`
    [ $ASSAY_COUNT = $UNIQUE_ASSAY_COUNT ]
}

@test "[analytics] Create collection on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi
  if [ ! -z ${SOLR_COLLECTION_EXISTS+x} ]; then
    skip "Solr collection has been predefined on the current setup"
  fi
  run create-gxa-analytics-config-set.sh
  run create-gxa-analytics-collection.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Set no auto-create on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi
  run gxa-index-set-no-autocreate.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Load schema to collection on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
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

@test "[analytics] Load data to Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to Solr"
  fi
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-bulk-conds-sdrf.tsv
  run load_gxa_analytics_index.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Load additional dataset for deletion testing" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping additional dataset load"
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
    skip "SOLR_HOST not defined, skipping additional dataset deletion"
  fi
  export EXP_ID=E-MTAB-111
  run delete_gxa_analytics_index.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] BioSolr ontology update processor" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping BioSolr update processor test"
  fi
  run add-biosolr-lib.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Check correctness of load" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load correctness check"
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

@test "[analytics] Check health of experiments" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping experiments health check"
  fi
  export EXPERIMENT_ID=E-MTAB-6870
  export EXP_MATCH_MIN=999999999
  export EXP_MATCH_WARNING=100
  # expect exit code 1 as the number of entries is lower than specified
  run gxa-index-check-experiments.sh
  [ "$status" -eq 1 ]
  export EXP_MATCH_MIN=3
  run gxa-index-check-experiments.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}



@test "[bioentities] Generate analytics JSONL files for human" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping suggestions of known gene symbol"
  fi
  export output_dir=$( pwd )
  export CONDA_PREFIX=/opt/conda
  
  export BIN_MAP=$( pwd )
  export SPECIES=homo_sapiens
  export ACCESSIONS=E-MTAB-4754

  generate_analytics_JSONL_files.sh

  echo "output = ${output}"
  [ "${status}" -eq 0 ]
  [ -f "$( pwd )/E-MTAB-4754.jsonl" ]
  # Check that the JSONL output exists
}


@test "[bioentities] Load analytics files into SOLR" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to Solr"
  fi

  export ACCESSIONS=E-MTAB-4754

  export output_dir=$( pwd )

  run load_analytics_files_in_Solr.sh

  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

