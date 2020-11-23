#!/usr/bin/env bash
# Above ^^ will test that bash is installed

export SOLR_HOST=my_solr:8983

docker network create mynet 
docker run --net mynet --name my_solr -v $(pwd)/lib/solr-ontology-update-processor-1.1.jar:/opt/solr/server/solr/lib/solr-ontology-update-processor-1.1.jar -d -p 8983:8983 -t solr:7.1-alpine -DzkRun -Denable.runtime.lib=true -m 2g
docker build -t test/index-gxa-module .
sleep 20

docker exec -it --user=solr my_solr bin/solr create_collection -c gxa-analytics-v1
docker run -i --net mynet -v $( pwd )/tests:/usr/local/tests -e SOLR_HOST=$SOLR_HOST --entrypoint=/usr/local/tests/run_tests_inside_container.sh test/index-gxa-module
