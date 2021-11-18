#!/usr/bin/env bash

export SOLR_HOST=my_solr:8983
export ZK_HOST=gxa-zk-1
export ZK_PORT=2181
export POSTGRES_HOST=postgres
export POSTGRES_DB=gxa
export POSTGRES_USER=gxa
export POSTGRES_PASSWORD=postgresPass
export POSTGRES_PORT=5432
export jdbc_url="jdbc:postgresql://$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB"

#export jdbc_username=$POSTGRES_USER
#export jdbc_password=$POSTGRES_PASSWORD
#export server_port=8081 #fake
#export BIOENTITIES=./tests/fixtures/
#export EXPERIMENT_FILES=./tests/fixtures/experiment_files

docker network create mynet
# create container with zookeeper
docker run --rm --net mynet --name $ZK_HOST -d -p $ZK_PORT:$ZK_PORT -e ZOO_MY_ID=1 -e ZOO_SERVERS='server.1=0.0.0.0:2888:3888' -t zookeeper:3.4.14

docker run --rm --net mynet --name my_solr -v $(pwd)/lib/solr-ontology-update-processor-1.1.jar:/opt/solr/server/solr/lib/solr-ontology-update-processor-1.1.jar -d -p 8983:8983 -e ZK_HOST=$ZK_HOST:$ZK_PORT -t solr:7.1-alpine -DzkRun -Denable.runtime.lib=true -m 2g

# For atlas-web-bulk-cli application context
docker run --rm --net mynet --name $POSTGRES_HOST \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_DB=$POSTGRES_DB \
  -p $POSTGRES_PORT:$POSTGRES_PORT -d postgres:10.3-alpine

# create docker for tests
docker build -t test/index-gxa-module .
sleep 20

# Setup the database schema
if [ ! -d "atlas-schemas" ]; then
  rm -rf ebi-gene-expression-group-atlas-schemas*
  wget https://github.com/ebi-gene-expression-group/atlas-schemas/tarball/master -O - | tar -xz
  mv ebi-gene-expression-group-atlas-schemas* atlas-schemas
fi

# migrate schemas to database
docker run --rm -i --net mynet \
  -v $( pwd )/atlas-schemas/flyway/gxa:/flyway/gxa \
  quay.io/ebigxa/atlas-schemas-base:1.0 \
  flyway migrate -url=$jdbc_url -user=$POSTGRES_USER -password=$POSTGRES_PASSWORD -locations=filesystem:/flyway/gxa

# Add experiment to database
docker run --rm -i --net mynet \
  -v $( pwd )/tests/load_experiment_query.sh:/tmp/load_experiment_query.sh \
  -e PGPASSWORD=$POSTGRES_PASSWORD \
  -e PGUSER=$POSTGRES_USER \
  -e PGDATABASE=$POSTGRES_DB \
  -e PGPORT=$POSTGRES_PORT \
  -e PGHOST=$POSTGRES_HOST \
  quay.io/ebigxa/atlas-schemas-base:1.0 \
  /tmp/load_experiment_query.sh E-MTAB-4754 RNASEQ_MRNA_BASELINE 'Homo sapiens'



# disable data driven schema functionality - not recommended for production
# curl http://localhost:8983/solr/bulk-analytics-v1/config -d '{"set-user-property": {"update.autoCreateFields":"false"}}'

docker exec -it --user=solr my_solr bin/solr create_collection -c bulk-analytics-v1


docker run --rm -i --net mynet -v $( pwd )/tests:/usr/local/tests \
  -v $( pwd )/bin:/usr/local/bin \
  -e SOLR_HOST=$SOLR_HOST -e ZK_HOST=$ZK_HOST -e ZK_PORT=$ZK_PORT \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -e jdbc_url=$jdbc_url --entrypoint=/usr/local/tests/run_tests_inside_container.sh test/index-gxa-module

# -e jdbc_username=$jdbc_username -e jdbc_password=$jdbc_password -e server_port=$server_port -e BIOENTITIES=$BIOENTITIES -e EXPERIMENT_FILES=$EXPERIMENT_FILES 

#docker stop my_solr
#docker network rm mynet


