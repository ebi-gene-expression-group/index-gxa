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
  -e SOLR_USER=<an-existing-solr-username-that-can-write-or-read> \
  -e SOLR_PASS=<passsword-forl-that-solr-user> \
  -e jdbc_url=$jdbc_url quay.io/ebigxa/atlas-index-base:1.0 bash <desired-script> -i /data/<relevant-data>
```

Scripts to create and load data into the `gxa-*` Solr indexes (for analytics). Execution of tasks here require that `bin/` directory in the root of this repo is part of the path, and that the following executables are available:

- awk
- jq (1.5)
- curl

However, the direct usage without `atlas-index-base:1.5` container (or the container tag currently used in the CI tests on [run_tests_in_containers.sh](run_tests_in_containers.sh)) is discouraged.

# Authentication

The setup on the CI is made to use authentication with default user and password. The calls assume these settings (solr:SolrRocks), but the user and password can be modified by doing:

```
export SOLR_USER=<new-user>
export SOLR_PASS=<new-pass>
```

To use default auth in a new solr cloud instance, upload `test/security.json` to ZK as shown in the `Setup auth` part of the `run_tests_in_containers.sh`. To setup users in a production setting the script [create-users.sh](bin/create-users.sh) will receive two set of users:

```
ADMIN_USER=<admin-username>
ADMIN_U_PWD=<password>

QUERY_USER=<query-username>
QUERY_U_PWD=<password>
```

it will create both users, giving the first admin privileges and the second reading privileges only, delete the default user and set the instance to only work with authenticated users.

## Enable BioSolr

`bulk-analytics-v1` makes use of the [BioSolr plugin](https://github.com/ebi-gene-expression-group/BioSolr) to perform ontology expansion on document indexing based on EFO. In order to enable BioSolr, there are 2 options:

### Option 1: Local `.jar` file

Place BioSolr jar (which can be found in the repository's `lib` directory) under `/server/solr/lib/` in your Solr installation directory. This is the oldest option, and has some security issues, but for testing should be fine.

### Option 2: Blob store API

You can use the BioSolr jar as a runtime library stored in the blob store API. In order to enable the use of runtime libraries, you must start your Solr instance with the flag `-Denable.runtime.lib=true`. **This option is now deprecated in solr 8 and will not be available anymore in Solr 9.**

To load the jar, set the environment variable `SOLR_HOST` to the appropriate server, and execute as shown

```bash
export SOLR_HOST=192.168.99.100:32080

create-scxa-analytics-biosolr-lib.sh
```

You can override the default target Solr collection by setting `SOLR_COLLECTION`. You can also provide your own path to the BioSolr jar file by setting `BIOSOLR_JAR_PATH`.

### Option 3: Solr package manager (used in the CI - preferred for production)

Newer versions of solr introduced a new approach, named package manager, to deal with 3rd party JARs and files to be made available to solr. This implies the following steps:

- Create a set of private/public keys (you can run [create-keys-for-tests.sh](tests/create-keys-for-tests.sh) as shown in [run_tests_in_containers.sh](run_tests_in_containers.sh) and keep those).
- Start solr cloud with the `-Denable.packages=true` as done in the CI.
- Upload the public key to solr through Zookeeper (see how the `SIGNING_*` variables are used and the `Upload der to Solr` part, both in [run_tests_in_containers.sh](run_tests_in_containers.sh)).
- Sign the JAR file with the private key and upload it to the solr file store (in our case, BioSolr solr-ontology-update-processor-2.0.0.jar, done by [upload-biosolr-lib.sh](bin/upload-biosolr-lib.sh) in the [analytics.bats](tests/analytics.bats), noting that it is running inside the solr container and that for this purpose, the private key was mounted inside that container on startup).
- Create the package `biosolr` (done as well by [upload-biosolr-lib.sh](bin/upload-biosolr-lib.sh)) in solr pointing to that signed JAR in the solr file store.
- Verify the package (done as well by [upload-biosolr-lib.sh](bin/upload-biosolr-lib.sh)).
- Deploy the package as part of the schema creation (done by [create-scxa-analystics-schema.sh](bin/create-scxa-analytics-schema.sh)).

In the CI, all these steps are done. In some cases, through the API, and in some cases through direct `bin/solr` calls, which might require a container with the same solr version plus the URI to the desired solr server (or execute them inside the same solr server).

Please note that for changes in the Solr version, most likely changes in [BioSolr plugin](https://github.com/ebi-gene-expression-group/BioSolr) will be required, at the very least to point to the newer Solr version, and hence a new JAR will need to be added here. Version 2.0.0 was built against Solr 8.7 (as used in the CI).

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
Tests are located in the `tests` directory and only require docker to be available. To run them, execute `bash tests/run_tests_in_containers.sh`. The `tests` folder includes example data in tsv (a condensed SDRF) and in JSON (as it should be produced by the first step that translates the cond. SDRF to JSON).

## Generating tests datasets for baseline

1.- Get the contents of a small baseline experiments from $ATLAS_EXPS or the ftp into the `tmp` directory.

2.- Get a subset of genes (50 genes starting from gene 4000 in this example) from the coexpression matrix in the `tmp` directory:

```
cd tests
bash get_baseline_subset_from_coexpression_file.sh ../tmp/E-MTAB-5072-coexpressions.tsv.gz fixtures/experiment_files/magetab/E-MTAB-5072 4000 50
```

3.- Obtain subsets of other files from this slim list created:

```
bash reduce_dataset_to_ids.sh slim_list.txt ../tmp/ fixtures/experiment_files/magetab/E-MTAB-5072
```

4.- Clean up `tmp`.
