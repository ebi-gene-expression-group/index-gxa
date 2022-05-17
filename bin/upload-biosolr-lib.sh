#!/usr/bin/env bash

set -e

CWD=`dirname "$0"`
# on developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

[ -z ${BIOSOLR_JAR_PATH+x} ] && echo "BIOSOLR_JAR_PATH env var is needed." && exit 1
[ -z ${BIOSOLR_VERSION+x} ] && echo "BIOSOLR_VERSION env var is needed." && exit 1
[ -z ${SIGNING_PRIVATE_KEY+x} ] && echo "SIGNING_PRIVATE_KEY env var is needed." && exit 1

# Sign biosolr JAR
echo $SIGNING_PRIVATE_KEY
SIGNATURE=$(openssl dgst -sha1 -sign $SIGNING_PRIVATE_KEY $BIOSOLR_JAR_PATH | openssl enc -base64 | sed 's/+/%2B/g' | tr -d \\n )

#creates a new file descriptor 3 that redirects to 1 (STDOUT)
exec 3>&1

REMOTE_BIOSOLR_PATH=/biosolr/$BIOSOLR_VERSION/biosolr.jar
# Upload JAR with signature
HTTP_STATUS=$(curl $SOLR_AUTH -w "%{http_code}" -o >(cat >&3) --data-binary @$BIOSOLR_JAR_PATH -X PUT  "http://$HOST/api/cluster/files$REMOTE_BIOSOLR_PATH?sig=$SIGNATURE")

if [[ ! $HTTP_STATUS == 2* ]];
then
	# HTTP Status is not a 2xx code, so it is an error.
   echo "Failed to upload the signed JAR file"
   exit 1
fi

# Verify upload of signed JAR
HTTP_STATUS=$(curl $SOLR_AUTH -w "%{http_code}" -o >(cat >&3) "http://$HOST/api/node/files/biosolr/$BIOSOLR_VERSION?omitHeader=true" )
if [[ ! $HTTP_STATUS == 2* ]];
then
	# HTTP Status is not a 2xx code, so it is an error.
   echo "Could not verify biosolr jar for http://$HOST/api/node/files/biosolr/$BIOSOLR_VERSION?omitHeader=true"
   exit 1
fi

# Create the package
HTTP_STATUS=$(curl $SOLR_AUTH -w "%{http_code}" -o >(cat >&3) "http://$HOST/api/cluster/package" -H 'Content-type:application/json' -d '
{"add": {
         "package" : "biosolr",
         "version":"'$BIOSOLR_VERSION'",
         "files" :["'$REMOTE_BIOSOLR_PATH'"]}}')


if [[ ! $HTTP_STATUS == 2* ]];
then
	# HTTP Status is not a 2xx code, so it is an error.
   echo "Failed to create the remote biosolr package for $REMOTE_BIOSOLR_PATH"
   exit 1
fi

# Verify the package
HTTP_STATUS=$(curl $SOLR_AUTH -w "%{http_code}" -o >(cat >&3) "http://$HOST/api/cluster/package?omitHeader=true" )

if [[ ! $HTTP_STATUS == 2* ]];
then
	# HTTP Status is not a 2xx code, so it is an error.
   echo "Failed to create the remote biosolr package for $REMOTE_BIOSOLR_PATH"
   exit 1
fi


# # Deploy the package
# # This is not needed since it happens on schema creation of the update-processor
# HTTP_STATUS=$(curl $SOLR_AUTH -w "%{http_code}" -o >(cat >&3) "http://$HOST/api/cluster/package" -H 'Content-type:application/json' -d '
# {"deploy": {
#          "package" : "biosolr",
#          "version":"'$BIOSOLR_VERSION'",
#          }')


# if [[ ! $HTTP_STATUS == 2* ]];
# then
# 	# HTTP Status is not a 2xx code, so it is an error.
#    echo "Failed to create the remote biosolr package for $REMOTE_BIOSOLR_PATH"
#    exit 1
# fi

echo "The package for biosolr should now be ready for attaching it to a handler/processor during schema creation."