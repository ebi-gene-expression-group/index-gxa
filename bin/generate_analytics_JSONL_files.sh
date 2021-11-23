#!/usr/bin/env bash

jar_dir=$CONDA_PREFIX/share/atlas-cli

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $scriptDir/common_routines.sh

require_env_var "SOLR_HOST"
require_env_var "ZK_HOST"
require_env_var "ZK_PORT"
require_env_var "BIOENTITIES"
require_env_var "output_dir"
require_env_var "EXPERIMENT_FILES"
require_env_var "jdbc_url"
require_env_var "jdbc_username"
require_env_var "jdbc_password"
require_env_var "server_port"

require_env_var "SPECIES" 
require_env_var "ACCESSIONS"
require_env_var "BIN_MAP"

SOLR_PORT=$(get_port_from_hostport $SOLR_HOST)
SOLR_HOST=$(get_host_from_hostport $SOLR_HOST)

require_env_var "SOLR_PORT"

JAVA_OPTS="-Dsolr.host=$SOLR_HOST"
JAVA_OPTS="$JAVA_OPTS -Dsolr.port=$SOLR_PORT"
JAVA_OPTS="$JAVA_OPTS -Dzk.host=$ZK_HOST"
JAVA_OPTS="$JAVA_OPTS -Dzk.port=$ZK_PORT"
JAVA_OPTS="$JAVA_OPTS -Ddata.files.location=$BIOENTITIES"
JAVA_OPTS="$JAVA_OPTS -Dexperiment.files.location=$EXPERIMENT_FILES"
JAVA_OPTS="$JAVA_OPTS -Djdbc.url=$jdbc_url"
JAVA_OPTS="$JAVA_OPTS -Djdbc.username=$jdbc_username"
JAVA_OPTS="$JAVA_OPTS -Djdbc.password=$jdbc_password"
JAVA_OPTS="$JAVA_OPTS -Dserver.port=$server_port"

# Generate JSONL files from bulk experiments

cmd="java -jar $jar_dir/atlas-cli-bulk.jar"
cmd=$cmd" bulk-analytics-json -o $output_dir -i ${BIN_MAP}/$SPECIES.map.bin " 

$cmd -e $ACCESSIONS
status=$?

exit $status
