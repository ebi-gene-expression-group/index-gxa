FROM alpine:3.8

RUN apk update && apk add bash curl jq

ENV BIOSOLR_JAR_PATH /usr/local/lib/solr-ontology-update-processor-1.1.jar

COPY bin/* /usr/local/bin/
COPY lib/* /usr/local/lib/
