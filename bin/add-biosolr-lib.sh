#!/usr/bin/env bash
SCHEMA_VERSION=1

set -e

# on developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"bulk-analytics-v$SCHEMA_VERSION"}
BIOSOLR_JAR_PATH="${BIOSOLR_JAR_PATH:-${PWD}/../lib/solr-ontology-update-processor-1.1.jar}"

#creates a new file descriptor 3 that redirects to 1 (STDOUT)
exec 3>&1
# There is no need to create the .system collection, it is automatically created by Solr when we set the size property.
printf "\n\nIncreasing blob size limit on blob store collection\n"
HTTP_STATUS=$(curl -w "%{http_code}" -o >(cat >&3) "http://$HOST/solr/.system/config" -H 'Content-type:application/json' -d '{"set-user-property" : {"blob.max.size.mb":"20"}}')

if [[ ! $HTTP_STATUS == 2* ]];
then
	 # HTTP Status is not a 2xx code, so it is an error.
   exit 1
fi

printf "\n\nAdding BioSolr jar to blob store\n"
HTTP_STATUS=$(curl -w "%{http_code}" -o >(cat >&3) -X POST -H 'Content-Type: application/octet-stream' --data-binary @${BIOSOLR_JAR_PATH} "http://$HOST/solr/.system/blob/biosolr")

if [[ ! $HTTP_STATUS == 2* ]];
then
	 # HTTP Status is not a 2xx code, so it is an error.
   exit 1
fi

printf "\n\nAdd runtime lib to collection classpath\n"
HTTP_STATUS=$(curl -w "%{http_code}" -o >(cat >&3) "http://$HOST/solr/$CORE/config" -H 'Content-type:application/json' -d '{"add-runtimelib": {"name":"biosolr","version":1}}')

if [[ ! $HTTP_STATUS == 2* ]];
then
	 # HTTP Status is not a 2xx code, so it is an error.
   exit 1
fi
