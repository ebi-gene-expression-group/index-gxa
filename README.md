# Module for indexing bulk Expression Atlas (v0.1.0)

This module provides scripts for building gxa indexing for Atlas Production data release process:

- Update experiment designs
- Update coexpressions
- Reindex analytics import

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

You can override the default target Solr collection name by setting `SOLR_COLLECTION`, but remember to include the additional `v<schema-version-number>` at the end, or the loader might refuse to load this.

## Load data
This module loads data from a condensed SDRF in an GXA experiment to the gxa-analytics-v? collection in Solr. These routines expect the collection to be created already, and work as an update to the content of the collection.

export SOLR_HOST=localhost:8983
export CONDENSED_SDRF_TSV=./test/example-bulk-conds-sdrf.tsv


## Delete an experiment
In order to delete a particular experiment's analytics solr documents based on its accession from a live index, do:

```bash
export EXP_ID=desired-exp-identifier
export SOLR_HOST=localhost:8983

delete_gxa_analytics_index.sh
```

## Tests
Tests are located in the `tests` directory and use bats. To run them, execute `bash tests/run-tests.sh`. The `tests` folder includes example data in tsv (a condensed SDRF) and in JSON (as it should be produced by the first step that translates the cond. SDRF to JSON).
