# Module for indexing bulk Expression Atlas (v0.1.0)

This module provides scripts for building gxa indexing for Atlas Production data release process:

- Update experiment designs
- Update coexpressions
- Reindex analytics import

The easiest way to run this without having to deal with dependencies is to mount this scripts into the quay.io/ebigxa/atlas-index-base container as done in the tests, mounting the data there and making the call so that the data mount points (including a data output mount point if needed) are used:

```bash
docker run --rm -i --net mynet -v $( pwd )/tests:/usr/local/tests \
  -v $( pwd )/bin:/usr/local/bin \
  -v /local/path/to/desired/data:/data \
  -v /local/path/for/outputs:/outputs \
  -e SOLR_HOST=$SOLR_HOST -e ZK_HOST=$ZK_HOST -e ZK_PORT=$ZK_PORT \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -e jdbc_url=$jdbc_url quay.io/ebigxa/atlas-index-base:1.0 bash <desired-script> -i /data/<relevant-data>
```

Scripts to create and load data into the `gxa-*` Solr indexes (for analytics). Execution of tasks here require that `bin/` directory in the root of this repo is part of the path, and that the following executables are available:

- awk
- jq (1.5)
- curl

# `gxa-analytics` index v1

To create the schema, set the environment variable `SOLR_HOST` to the appropriate server, and execute as shown

```bash
export SOLR_HOST=localhost:8983

create-gxa-analytics-config-set.sh
create-gxa-analytics-collection.sh
```

## Create schema
```bash
create-gxa-scxa-analytics-schema.sh
```

You can override the default target Solr collection name by setting `SOLR_COLLECTION`, but remember to include the additional `v<schema-version-number>` at the end, or the loader might refuse to load this. For instance, in the tests the collection name used is `bulk-analytics-v1`.

## Load data
This module loads data from a condensed SDRF in an GXA experiment to the gxa-analytics-v? collection in Solr. These routines expect the collection to be created already, and work as an update to the content of the collection.

export SOLR_HOST=localhost:8983
export CONDENSED_SDRF_TSV=./test/example-bulk-conds-sdrf.tsv

This is still WIP.

### Legacy method

The current setup still in use loads bulk-analytics-v1 through the web application:

```bash
export ATLASPROD_PATH=...
export TOMCAT_HOST_USERNAME=...
export TOMCAT_HOST_PASSWORD=...
export TOMCAT_HOST=... # Tomcat host where Atlas GXA is running, usually the prod environment.

# Optionally, you can parametrise the execution with
export SOLR_DOCS_BATCH=30000 # for the number of documents per batch to load to Solr
export SOLR_THREADS=4 # Number of concurrent operations to run against solr
export SOLR_TIMEOUT_HRS=72 # hours for connection timeout.

#run
index_analytics.sh
```

## Delete an experiment
In order to delete a particular experiment's analytics solr documents based on its accession from a live index, do:

```bash
export EXP_ID=desired-exp-identifier
export SOLR_HOST=localhost:8983

delete_gxa_analytics_index.sh
```

## Check the number of entries per experiment in the Solr index
To make sure experiments have a sufficient number of matches in the index, run  
```
bin/gxa-index-check-experiments.sh
```
This script expects the following variables to be defined:
- `EXPERIMENT_ID`: one or more experiment accessions for which index state should be checked
- `EXP_MATCH_MIN`: minimal accepted number of matches per experiment
- `EXP_MATCH_WARNING`: fewer matches than this number cause a warning
- `EXPERIMENT_TYPE`: gxa or bulk

## Tests
Tests are located in the `tests` directory and use bats. To run them, execute `bash tests/run-tests.sh`. The `tests` folder includes example data in tsv (a condensed SDRF) and in JSON (as it should be produced by the first step that translates the cond. SDRF to JSON).
