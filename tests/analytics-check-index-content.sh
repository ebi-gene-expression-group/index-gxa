#!/usr/bin/env bash
set -e
SCHEMA_VERSION=1

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"gxa-analytics-v$SCHEMA_VERSION"}

# This is the dependant of the example file.
# We will query for organism_part and assay SRR6257788
characteristic="disease"
assay="ERR2619175"

org_part=$(grep $assay $CONDENSED_SDRF_TSV | grep 'disease' | awk -F'\t' '{ print $6 }')

# BioSolr seems to do the ontology expansion in the background and not blocking
# the loading call. As such, we need to wait during testing to make sure that
# elements have been loaded
pings=0
numRecordsLoaded=0
while [ "$numRecordsLoaded" -eq 0 ]; do
  if [ "$pings" -gt 50 ]; then
    echo "Timed out waiting for load after $pings tries."
    exit 1
  fi
  sleep 20
  numRecordsLoaded=$(curl -s "http://$HOST/solr/$CORE/select?fl=characteristic_name,characteristic_value&q=assay:$assay%20AND%20characteristic_name:$characteristic" | jq '.response.numFound')
  ((++pings))
done
echo "Pings: $pings"

response=$(curl "http://$HOST/solr/$CORE/select?q=assay:$assay%20AND%20characteristic_name:$characteristic" | jq .response)

# Check number of returned documents
numberOfDocuments=$(echo "${response}" | jq .numFound)
if [ "$numberOfDocuments" -ne 1 ]; then
    echo "Expected 1 document, returned $numberOfDocuments instead"
    exit 1
fi

# Check if the organism part returned has the right value
echo ${response} | jq -e --arg org_part "$org_part" '.docs[0].characteristic_value | contains([$org_part])'

# Check ontology expansion was successful - we only care about the labels for the ontology terms, rather than the URIs
echo ${response} | jq -e '.docs | map(has("ontology_annotation")) | all'