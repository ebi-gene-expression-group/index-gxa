#!/usr/bin/env bash

scriptDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

[ -z ${ATLASPROD_PATH+x} ] && echo "Env var ATLASPROD_PATH for the path to atlas prod software check out needs to be defined." && exit 1
[ ! -z ${TOMCAT_HOST_USERNAME+x} ] || ( echo "Env var TOMCAT_HOST_USERNAME ie. curator needs to be defined." && exit 1 )
[ ! -z ${TOMCAT_HOST_PASSWORD+x} ] || ( echo "Env var TOMCAT_HOST_PASSWORD needs to be defined." && exit 1 )
[ ! -z ${TOMCAT_HOST+x} ] || ( echo "Env var TOMCAT_HOST ie. ves:8080 needs to be defined." && exit 1 )


# Set path (this is done at this level since this will be executed directly):
for mod in index-gxa/bin; do
  export PATH=$ATLASPROD_PATH/$mod:$PATH
done

# start updating coexpression
echo "Started updating coexpressions ..."
curl -s -u $TOMCAT_HOST_USERNAME:$TOMCAT_HOST_PASSWORD "http://$TOMCAT_HOST/gxa/admin/experiments/all/COEXPRESSION_UPDATE"
if [ $? -ne 0 ]; then
    echo "ERROR: failed to update coexpressions - $TOMCAT_HOST"
    exit 1
fi
echo "Completed updating coexpressions ..."

