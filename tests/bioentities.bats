setup() {
  export SOLR_COLLECTION=bioentities-v1
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

@test "[bioentities] Create collection on solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on solr"
  fi
  if [ ! -z ${SOLR_COLLECTION_EXISTS+x} ]; then
    skip "solr collection has been predifined on the current setup"
  fi
  run create-bioentities-collection.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[bioentities] Load schema to collection on solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on solr"
  fi
  run create-bioentities-schema.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[bioentities] Check that all fields are in the created schema" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping check of fields on schema"
  fi
  run analytics-check-created-fields.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[bioentities] Load data to solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export BIOENTITIES_TSV=$BATS_TEST_DIRNAME/example.homo_sapiens.ensgene.tsv
  #export BIOENTITIES_JSON=$BATS_TEST_DIRNAME/bioentities_cli_test.json
  run load_gxa_bioentities_index.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}