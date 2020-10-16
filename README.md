# Module for indexing bulk Expression Atlas (v0.1.0)

This module provides scripts for building gxa indexing for Atlas Production data release process:

- Update experiment designs
- Update coexpressions 
- Reindex bioentities collection
- Reindex analytics import

Scripts to create and load data into the `gxa-*` Solr indexes (for bionetities and analytics). Execution of tasks here require that `bin/` directory in the root of this repo is part of the path, and that the following executables are available:

- awk
- jq (1.5)
- curl

# `gxa-analytics` index v1

To create the schema, set the environment variable `SOLR_HOST` to the appropriate server, and execute as shown

```
export SOLR_HOST=localhost:8983

create-gxa-analytics-config-set.sh
create-gxa-analytics-collection.sh
```

## Create schema
```
create-gxa-scxa-analytics-schema.sh
```

You can override the default target Solr collection name by setting `SOLR_COLLECTION`, but remember to include the additional `v<schema-version-number>` at the end, or the loader might refuse to load this.


## Load data
This module loads data from a condensed SDRF in an GXA experiment to the gxa-analytics-v? collection in Solr. These routines expect the collection to be created already, and work as an update to the content of the collection.

export SOLR_HOST=localhost:8983
export CONDENSED_SDRF_TSV=./test/example-bulk-conds-sdrf.tsv


## Delete an experiment
In order to delete a particular experiment's analytics solr documents based on its accession from a live index, do:

```
export EXP_ID=desired-exp-identifier
export SOLR_HOST=localhost:8983

delete_gxa_analytics_index.sh
```

## Tests
Tests are located in the `tests` directory and use bats. To run them, execute `bash tests/run-tests.sh`. The `tests` folder includes example data in tsv (a condensed SDRF) and in JSON (as it should be produced by the first step that translates the cond. SDRF to JSON).


# `bioentities-collection` index v1

To create the schema, set the environment variable `SOLR_HOST` to the appropriate server, and execute as shown

```
export SOLR_HOST=localhost:8983

create-bioentities-collections.sh
create-bioentities-schema.sh
```
## Load data
Before loading, the bioentities (tests file homo_sapiens.ensgene.tsv) which is in tsv format are converted to JSON. Property yaml file contains predefined weights for an attribute that is given priority while searching in webapp

```
export BIOENTITIES_TSV=./tests/homo_sapiens.ensgene.tsv
export ROPERTY_WEIGHTS_YAML=./property_weights

load_gxa_bioentities_index.sh

```

## Tests
Tests are located in the `tests` directory and use bats. To run them, execute `bash tests/run-tests.sh`. The `tests` folder includes example data in tsv (homo_sapiens.ensgene.tsv)