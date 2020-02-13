#!/usr/bin/env bash

# This is a very I/O and memory intensive process. The application will first build a hash of all the gene annotations keyed by gene ID
# and then will concurrently index all experiments, the biggest first in order to maximize parallelization. The first four to five hours will be “silent”
# (i.e. there will be no updates in the progress page). You can alternatively have a look at the web application logs to make sure things are progessing smoothly.
# The last optimization step effectively copies the full index into a consolidated set of files and replaces the old one. This also takes approximately three to four hours.

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

[ -z ${ATLASPROD_PATH+x} ] && echo "Env var ATLASPROD_PATH for the path to atlas prod software check out needs to be defined." && exit 1
[ ! -z ${TOMCAT_HOST_USERNAME+x} ] || ( echo "Env var TOMCAT_HOST_USERNAME ie. xxxx needs to be defined." && exit 1 )
[ ! -z ${TOMCAT_HOST_PASSWORD+x} ] || ( echo "Env var TOMCAT_HOST_PASSWORD ie. xxxx needs to be defined." && exit 1 )
[ ! -z ${TOMCAT_HOST+x} ] || ( echo "Env var TOMCAT_HOST ie. ves:8080 needs to be defined." && exit 1 )


# Set path (this is done at this level since this will be executed directly):
for mod in index-gxa/bin; do
  export PATH=$ATLASPROD_PATH/$mod:$PATH
done

# start indexing analytics
echo "Started analytics indexing ..."
curl -s -u $TOMCAT_HOST_USERNAME:$TOMCAT_HOST_PASSWORD "http://$TOMCAT_HOST/gxa/admin/analyticsIndex/buildIndex?timeout=96" 
if [ $? -ne 0 ]; then
    echo "ERROR: Analytics indexing ${TOMCAT_HOST_USERNAME}@${TOMCAT_HOST}"
    exit 1
fi
