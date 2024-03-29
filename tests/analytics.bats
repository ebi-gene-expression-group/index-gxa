setup() {
  export SOLR_COLLECTION=bulk-analytics-v1
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

@test "Check that java is in the path" {
    run which java
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

@test "[solr-auth] Create definitive users" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi

  # default user to start - admin user will be used by other tasks
  export SOLR_USER=solr
  export SOLR_PASS=SolrRocks

  echo "Solr user: $SOLR_USER"
  echo "Solr pwd: $SOLR_PASS"

  run create-users.sh
  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

@test "Check that filtering doesn't remove any assays" {
    ASSAY_COUNT=`condSdrf2tsvForGXAJSONFactorsIndex.sh $BATS_TEST_DIRNAME/example-bulk-conds-sdrf.tsv | jsonFilterEmptyFields.sh | grep \"assay\": | sort -u | wc -l`
    UNIQUE_ASSAY_COUNT=`condSdrf2tsvForGXAJSONFactorsIndex.sh $BATS_TEST_DIRNAME/example-bulk-conds-sdrf.tsv | grep \"assay\": | sort -u | wc -l`
    [ $ASSAY_COUNT = $UNIQUE_ASSAY_COUNT ]
}

@test "Upload biosolr lib" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi

  run upload-biosolr-lib.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Create collection on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi
  if [ ! -z ${SOLR_COLLECTION_EXISTS+x} ]; then
    skip "Solr collection has been predefined on the current setup"
  fi
  run create-bulk-analytics-config-set.sh
  run create-bulk-analytics-collection.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Load schema to collection on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi
  run create-bulk-analytics-schema.sh
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

# @test "[analytics] Load data to Solr" {
#   if [ -z ${SOLR_HOST+x} ]; then
#     skip "SOLR_HOST not defined, skipping load to Solr"
#   fi
#   export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-bulk-conds-sdrf.tsv
#   run load_gxa_analytics_index.sh
#   echo "output = ${output}"
#   [ "$status" -eq 0 ]
# }

# @test "[analytics] Load additional dataset for deletion testing" {
#   if [ -z ${SOLR_HOST+x} ]; then
#     skip "SOLR_HOST not defined, skipping additional dataset load"
#   fi
#   export EXP_ID=E-MTAB-111
#   export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-conds-sdrf-delete.tsv
#   run load_gxa_analytics_index.sh
#   run analytics-check-experiment-available.sh
#   echo "output = ${output}"
#   [ "$status" -eq 0 ]
# }

# @test "[analytics] Delete additional dataset" {
#   if [ -z ${SOLR_HOST+x} ]; then
#     skip "SOLR_HOST not defined, skipping additional dataset deletion"
#   fi
#   export EXP_ID=E-MTAB-111
#   run delete_bulk_analytics_index.sh
#   echo "output = ${output}"
#   [ "$status" -eq 0 ]
# }

# @test "[analytics] Check correctness of load" {
#   if [ -z ${SOLR_HOST+x} ]; then
#     skip "SOLR_HOST not defined, skipping load correctness check"
#   fi
#   export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-bulk-conds-sdrf.tsv
#   run analytics-check-index-content.sh
#   echo "output = ${output}"
#   [ "$status" -eq 0 ]
# }

# @test "[analytics] Check that deleted experiment is no longer available, but previous one is" {
#   export EXP_ID=E-MTAB-111
#   run analytics-check-experiment-available.sh
#   # this will return exit code 1 if the experiment is not available
#   [ "$status" -eq 1 ]
#   export EXP_ID=E-MTAB-6870
#   run analytics-check-experiment-available.sh
#   echo "output = ${output}"
#   [ "$status" -eq 0 ]
# }

# @test "[analytics] Check health of experiments" {
#   if [ -z ${SOLR_HOST+x} ]; then
#     skip "SOLR_HOST not defined, skipping experiments health check"
#   fi
#   export EXPERIMENT_ID=E-MTAB-6870
#   export EXP_MATCH_MIN=999999999
#   export EXP_MATCH_WARNING=100
#   # expect exit code 1 as the number of entries is lower than specified
#   run gxa-index-check-experiments.sh
#   [ "$status" -eq 1 ]
#   export EXP_MATCH_MIN=3
#   run gxa-index-check-experiments.sh
#   echo "output = ${output}"
#   [ "$status" -eq 0 ]
# }

@test "[external] Update experiment designs" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping suggestions of known gene symbol"
  fi

  export CONDA_PREFIX=/opt/conda
  export ACCESSIONS=E-MTAB-4754,E-MTAB-5072

  # shorten lines in exp design file to check that update re-instates them
  FILE_TO_CHECK=$EXPERIMENT_FILES/expdesign/ExpDesign-E-MTAB-4754.tsv
  sed -i '$ d' $FILE_TO_CHECK

  run update_experiment_designs_cli.sh
  echo "output = ${output}"
  # we should see an increase from 4 to 5 lines
  exp_design_4754_lines=$(wc -l $FILE_TO_CHECK | awk '{ print $1 }')
  [ "$exp_design_4754_lines" -eq 5 ]
  [ "$status" -eq 0 ]
}

@test "[external] Update experiment designs which errors out" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping suggestions of known gene symbol"
  fi

  export CONDA_PREFIX=/opt/conda
  export ACCESSIONS=E-ERAD-475

  # shorten lines in exp design file to check that update re-instates them
  FILE_TO_CHECK=$EXPERIMENT_FILES/expdesign/ExpDesign-E-ERAD-475.tsv

  run update_experiment_designs_cli.sh
  echo "output = ${output}"
  grep_count=$(echo $output | grep -c 'Only in XML configuration file: ERR1442629, ERR1442663, ERR1442683, ERR1442695, ERR1442731')
  (( grep_count == 1 ))
  [ "$status" -eq 1 ]
}

@test "[external] Fail to update experiment designs" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping suggestions of known gene symbol"
  fi

  export CONDA_PREFIX=/opt/conda
  # first accession is not available,
  # so it fails on that one and leaves it in the failed file
  export ACCESSIONS=E-MTAB-4700,E-MTAB-5072
  export failed_accessions_output="/tmp/failed_accessions_exp_design.txt"

  run update_experiment_designs_cli.sh
  echo "output = ${output}"

  failed_acc=$(wc -l $failed_accessions_output | awk '{ print $1 }')
  [ "$status" -eq 1 ]
  [ "$failed_acc" -eq 1 ]
  [ -f "$failed_accessions_output" ]
}


@test "[external] Update coexpressions" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping suggestions of known gene symbol"
  fi

  export CONDA_PREFIX=/opt/conda
  export ACCESSIONS=E-MTAB-5072,E-MTAB-4754

  run update_coexpressions_cli.sh
  # TODO it would be nice to add here a query against
  # rnaseq_bsln_ce_profiles table, once the index-base container includes
  # psql - for now I have checked that the table gets populated.
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[external] Try failed coexpression" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping suggestions of known gene symbol"
  fi

  export CONDA_PREFIX=/opt/conda
  # try with one experiment that doesn't exist and see if it fails as expected
  export ACCESSIONS=E-MTAB-4444,E-MTAB-5072

  run update_coexpressions_cli.sh
  echo "output = ${output}"
  # TODO ideally we would want this to fail in the future - make sure web application
  # complains when reading a faulty file and set below to 1.
  [ "$status" -eq 0 ]
}

@test "[analytics] Generate analytics JSONL files for human" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping suggestions of known gene symbol"
  fi
  export output_dir=$( pwd )
  export CONDA_PREFIX=/opt/conda
  export BIN_MAP=$BATS_TEST_DIRNAME
  export SPECIES=homo_sapiens
  export ACCESSIONS=E-MTAB-4754

  export JAVA_OPTS="-Xmx1g"
  run generate_analytics_JSONL_files.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
  [ -f "$( pwd )/E-MTAB-4754.jsonl" ]
  # Check that the JSONL output exists
}

@test "[analytics] Fail Generating analytics JSONL files for human" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping suggestions of known gene symbol"
  fi
  export output_dir=$( pwd )
  export CONDA_PREFIX=/opt/conda
  export BIN_MAP=$BATS_TEST_DIRNAME
  export SPECIES=homo_sapiens
  export ACCESSIONS=E-MTAB-4754 # use two fake ACCESSIONS
  export failed_accessions_output="/tmp/failed_accessions_analytics_JSONL.txt"

  mkdir -p /tmp/magetab
  mkdir -p /tmp/expdesign
  cp -r $EXPERIMENT_FILES/magetab/E-MTAB-4754 /tmp/magetab/
  cp $EXPERIMENT_FILES/expdesign/ExpDesign-E-MTAB-4754.tsv /tmp/expdesign/
  cp $EXPERIMENT_FILES/*.json /tmp/
  rm /tmp/magetab/E-MTAB-4754/E-MTAB-4754.idf.txt

  export EXPERIMENT_FILES=/tmp

  export JAVA_OPTS="-Xmx1g"
  run generate_analytics_JSONL_files.sh
  echo "output = ${output}"
  failed_acc=$(wc -l $failed_accessions_output | awk '{ print $1 }')
  [ "$status" -eq 1 ]
  [ "$failed_acc" -eq 1 ]
  [ -f "$( pwd )/E-MTAB-4754.jsonl" ]
  [ -f "$failed_accessions_output" ]
  # Check that the JSONL output exists
}

@test "[analytics] Fail Generating analytics JSONL files for human without failed acc file" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping suggestions of known gene symbol"
  fi
  export output_dir=$( pwd )
  export CONDA_PREFIX=/opt/conda
  export BIN_MAP=$BATS_TEST_DIRNAME
  export SPECIES=homo_sapiens
  export ACCESSIONS=E-MTAB-4754 # use two fake ACCESSIONS

  mkdir -p /tmp/magetab
  mkdir -p /tmp/expdesign
  cp -r $EXPERIMENT_FILES/magetab/E-MTAB-4754 /tmp/magetab/
  cp $EXPERIMENT_FILES/expdesign/ExpDesign-E-MTAB-4754.tsv /tmp/expdesign/
  cp $EXPERIMENT_FILES/*.json /tmp/
  rm /tmp/magetab/E-MTAB-4754/E-MTAB-4754.idf.txt

  export EXPERIMENT_FILES=/tmp

  export JAVA_OPTS="-Xmx1g"
  run generate_analytics_JSONL_files.sh
  echo "output = ${output}"
  [ "$status" -eq 1 ]
  [ -f "$( pwd )/E-MTAB-4754.jsonl" ]
  # Check that the JSONL output exists
}

# @test "[analytics] Enable automatic field generation in the Solr collection" {
#   if [ -z ${SOLR_HOST+x} ]; then
#     skip "SOLR_HOST not defined, skipping suggestions of known gene symbol"
#   fi
#   run gxa-index-set-autocreate.sh
#   echo "output = ${output}"
#   [ "$status" -eq 0 ]
# }

@test "[analytics] Load analytics files into SOLR" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to Solr"
  fi
  export ACCESSIONS=E-MTAB-4754
  export analytics_jsonl_dir=$( pwd )
  run load_analytics_files_in_Solr.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Load analytics files into SOLR with previous deletion" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to Solr"
  fi
  export ACCESSIONS=E-MTAB-4754
  export analytics_jsonl_dir=$( pwd )
  export delete_existing=true
  run load_analytics_files_in_Solr.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Optimise collection" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to Solr"
  fi

  run optimise-analytics.sh

  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

@test "[analytics] Check that optimisation worked" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to Solr"
  fi
  run analytics-check-optimisation.sh

  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

@test "[bioentities] Disable automatic field generation in the Solr collection" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping suggestions of known gene symbol"
  fi
  run gxa-index-set-no-autocreate.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}
