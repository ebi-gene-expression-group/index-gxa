FROM python:3.8.3-alpine3.11

RUN apk --update add --no-cache g++
RUN apk update && apk add bash curl jq 
RUN pip install pandas

ENV BIOSOLR_JAR_PATH /usr/local/lib/solr-ontology-update-processor-1.1.jar

COPY bin/* /usr/local/bin/
COPY lib/* /usr/local/lib/
