#!/usr/bin/env bash

export SOLR_HOST=my_solr:8983
SOLR_CONT_NAME=my_solr
SOLR_VERSION=8.7
export ZK_HOST=gxa-zk-1
export ZK_PORT=2181
ZK_VERSION=3.5.8
export POSTGRES_HOST=postgres
export POSTGRES_DB=gxa
export POSTGRES_USER=gxa
export POSTGRES_PASSWORD=postgresPass
export POSTGRES_PORT=5432
DOCKER_NET=net-index-gxa
export jdbc_url="jdbc:postgresql://$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB"

docker stop $SOLR_CONT_NAME && docker rm $SOLR_CONT_NAME
docker stop $ZK_HOST && docker rm $ZK_HOST
docker stop $POSTGRES_HOST && docker rm $POSTGRES_HOST
docker network rm $DOCKER_NET

docker network create $DOCKER_NET
# create container with zookeeper
docker run --rm --net $DOCKER_NET --name $ZK_HOST -d \
    -p $ZK_PORT:$ZK_PORT \
    -e ZOO_MY_ID=1 \
    -e ZOO_4LW_COMMANDS_WHITELIST="mntr,conf,ruok" \
    -e ZOO_SERVERS="server.1=$ZK_HOST:2888:3888;$ZK_PORT" \
    -t zookeeper:$ZK_VERSION

sleep 10

export SIGNING_PRIVATE_KEY=signing_key.pem
export SIGNING_PUBLIC_KEY_DER=signing_key.der
export BIOSOLR_VERSION=2.0.0

bash tests/create-keys-for-tests.sh

docker run --rm --net $DOCKER_NET --name $SOLR_CONT_NAME \
    -d -p 8983:8983 \
    -e ZK_HOST=$ZK_HOST:$ZK_PORT \
    -v $( pwd )/tests:/opt/tests \
    -v $( pwd )/$SIGNING_PUBLIC_KEY_DER:/tmp/$SIGNING_PUBLIC_KEY_DER \
    -t solr:$SOLR_VERSION -c -Denable.packages=true -m 2g

SECURITY_JSON=/usr/local/tests/security.json

# Setup auth
echo "Setup auth"
docker run --net $DOCKER_NET \
    -d -v $( pwd )/tests/security.json:$SECURITY_JSON \
    -t solr:$SOLR_VERSION bin/solr zk cp file:$SECURITY_JSON zk:/security.json -z $ZK_HOST:$ZK_PORT

# Upload der to Solr
echo "Upload public der key to Solr"
docker exec -d $SOLR_CONT_NAME \
    bin/solr package add-key /tmp/$SIGNING_PUBLIC_KEY_DER

# For atlas-web-bulk-cli application context
docker run --rm --net $DOCKER_NET --name $POSTGRES_HOST \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_DB=$POSTGRES_DB \
  -p $POSTGRES_PORT:$POSTGRES_PORT -d postgres:10.3-alpine

sleep 20

# Setup the database schema
if [ ! -d "atlas-schemas" ]; then
  rm -rf ebi-gene-expression-group-atlas-schemas*
  wget https://github.com/ebi-gene-expression-group/atlas-schemas/tarball/master -O - | tar -xz
  mv ebi-gene-expression-group-atlas-schemas* atlas-schemas
fi

# migrate schemas to database
docker run --rm -i --net $DOCKER_NET \
  -v $( pwd )/atlas-schemas/flyway/gxa:/flyway/gxa \
  quay.io/ebigxa/atlas-schemas-base:1.0 \
  flyway migrate -url=$jdbc_url -user=$POSTGRES_USER -password=$POSTGRES_PASSWORD -locations=filesystem:/flyway/gxa

# Add experiment to database
docker run --rm -i --net $DOCKER_NET \
  -v $( pwd )/tests/load_experiment_query.sh:/tmp/load_experiment_query.sh \
  -e PGPASSWORD=$POSTGRES_PASSWORD \
  -e PGUSER=$POSTGRES_USER \
  -e PGDATABASE=$POSTGRES_DB \
  -e PGPORT=$POSTGRES_PORT \
  -e PGHOST=$POSTGRES_HOST \
  quay.io/ebigxa/atlas-schemas-base:1.0 \
  /tmp/load_experiment_query.sh E-MTAB-4754 RNASEQ_MRNA_BASELINE 'Homo sapiens'

docker run --rm -i --net $DOCKER_NET \
  -v $( pwd )/tests/load_experiment_query.sh:/tmp/load_experiment_query.sh \
  -e PGPASSWORD=$POSTGRES_PASSWORD \
  -e PGUSER=$POSTGRES_USER \
  -e PGDATABASE=$POSTGRES_DB \
  -e PGPORT=$POSTGRES_PORT \
  -e PGHOST=$POSTGRES_HOST \
  quay.io/ebigxa/atlas-schemas-base:1.0 \
    /tmp/load_experiment_query.sh E-MTAB-5072 RNASEQ_MRNA_BASELINE 'Arabidopsis lyrata'

    docker run --rm -i --net $DOCKER_NET \
      -v $( pwd )/tests/load_experiment_query.sh:/tmp/load_experiment_query.sh \
      -e PGPASSWORD=$POSTGRES_PASSWORD \
      -e PGUSER=$POSTGRES_USER \
      -e PGDATABASE=$POSTGRES_DB \
      -e PGPORT=$POSTGRES_PORT \
      -e PGHOST=$POSTGRES_HOST \
      quay.io/ebigxa/atlas-schemas-base:1.0 \
        /tmp/load_experiment_query.sh E-ERAD-475 RNASEQ_MRNA_BASELINE 'Danio rerio'


# disable data driven schema functionality - not recommended for production
# curl http://localhost:8983/solr/bulk-analytics-v1/config -d '{"set-user-property": {"update.autoCreateFields":"false"}}'

BIOSOLR_REMOTE_JAR_PATH=/packages/solr-ontology-update-processor-$BIOSOLR_VERSION.jar

docker exec -i --user=solr my_solr bin/solr create_collection -c bulk-analytics-v1

docker run --rm -i --net $DOCKER_NET -v $( pwd )/tests:/usr/local/tests:rw \
  -v $( pwd )/bin:/usr/local/bin \
  -v $(pwd)/lib/solr-ontology-update-processor-$BIOSOLR_VERSION.jar:$BIOSOLR_REMOTE_JAR_PATH \
  -v $(pwd)/$SIGNING_PRIVATE_KEY:/packages/$SIGNING_PRIVATE_KEY \
  -e SOLR_HOST=$SOLR_HOST -e ZK_HOST=$ZK_HOST -e ZK_PORT=$ZK_PORT \
  -e BIOSOLR_JAR_PATH=$BIOSOLR_REMOTE_JAR_PATH \
  -e BIOSOLR_VERSION=$BIOSOLR_VERSION \
  -e SIGNING_PRIVATE_KEY=/packages/$SIGNING_PRIVATE_KEY \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -e jdbc_url=$jdbc_url --entrypoint=/usr/local/tests/run-tests.sh quay.io/ebigxa/atlas-index-base:1.5


#docker stop my_solr
#docker network rm $DOCKER_NET
