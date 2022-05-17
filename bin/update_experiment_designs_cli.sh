#!/usr/bin/env bash

jar_dir=$CONDA_PREFIX/share/atlas-cli

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $scriptDir/common_routines.sh

require_env_var "SOLR_HOST"
require_env_var "ZK_HOST"
require_env_var "ZK_PORT"
require_env_var "BIOENTITIES"
require_env_var "EXPERIMENT_FILES"
require_env_var "jdbc_url"
require_env_var "jdbc_username"
require_env_var "jdbc_password"
require_env_var "server_port"

require_env_var "ACCESSIONS"

SOLR_PORT=$(get_port_from_hostport $SOLR_HOST)
SOLR_HOST=$(get_host_from_hostport $SOLR_HOST)

require_env_var "SOLR_PORT"

java_opts="-Dsolr.host=$SOLR_HOST"
java_opts="$java_opts -Dsolr.port=$SOLR_PORT"
java_opts="$java_opts -Dzk.host=$ZK_HOST"
java_opts="$java_opts -Dzk.port=$ZK_PORT"
java_opts="$java_opts -Ddata.files.location=$BIOENTITIES"
java_opts="$java_opts -Dexperiment.files.location=$EXPERIMENT_FILES"
java_opts="$java_opts -Djdbc.url=$jdbc_url"
java_opts="$java_opts -Djdbc.username=$jdbc_username"
java_opts="$java_opts -Djdbc.password=$jdbc_password"
java_opts="$java_opts -Djdbc.max_pool_size=2"
java_opts="$java_opts -Dserver.port=$server_port"
# for solr auth
java_opts="$java_opts -Dsolr.httpclient.builder.factory=org.apache.solr.client.solrj.impl.PreemptiveBasicAuthClientBuilderFactory"
java_opts="$java_opts -Dbasicauth=$SOLR_USER:$SOLR_PASS"

# Generate JSONL files from bulk experiments

cmd="java $java_opts -jar $jar_dir/atlas-cli-bulk.jar"
cmd=$cmd" update-experiment-design"

if [ ! -z ${failed_accessions_output+x} ]; then
  cmd="$cmd -f $failed_accessions_output"
fi

echo "$cmd -e $ACCESSIONS"

$cmd -e $ACCESSIONS
status=$?

exit $status
