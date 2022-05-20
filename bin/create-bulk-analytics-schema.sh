#!/usr/bin/env bash
SCHEMA_VERSION=1

# On developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"bulk-analytics-v${SCHEMA_VERSION}"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

#############################################################################################

printf "\n\nDelete field experiment_accession\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "experiment_accession"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field experiment_accession (string, DocValues)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "experiment_accession",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete field is_private\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "is_private"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field is_private (boolean)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "is_private",
    "type": "boolean"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete copy field rule bioentity_identifier -> bioentity_identifier_search\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-copy-field":
  {
    "source": "bioentity_identifier",
    "dest": "bioentity_identifier_search"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nDelete field bioentity_identifier\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "bioentity_identifier"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field bioentity_identifier (string, DocValues)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "bioentity_identifier",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nDelete field bioentity_identifier_search\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "bioentity_identifier_search"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field bioentity_identifier_search (lowercase)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "bioentity_identifier_search",
    "type": "lowercase"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nAdd copy field rule bioentity_identifier -> bioentity_identifier_search\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":
  {
    "source": "bioentity_identifier",
    "dest": "bioentity_identifier_search"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete field assay_group_id\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field" :
  {
    "name": "assay_group_id"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field assay_group_id (string, DocValues)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "assay_group_id",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete field contrast_id\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "contrast_id"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field contrast_id (string)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "contrast_id",
    "type": "string"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete field species\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "species"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field species (string, DocValues)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "species",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete field kingdom\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "kingdom"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field kingdom (string, DocValues)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "kingdom",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema


#############################################################################################

printf "\n\nDelete field experiment_type\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "experiment_type"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field experiment_type (string, DocValues)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "experiment_type",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete field default_query_factor_type\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "default_query_factor_type"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field default_query_factor_type (string, DocValues)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "default_query_factor_type",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema


#############################################################################################

printf "\n\nDelete field factors\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "factors"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field factors (string, multi-valued, DocValues)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "factors",
    "type": "string",
    "multiValued": true,
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete field expression_level\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "expression_level"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field expression_level (pdouble, DocValues)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "expression_level",
    "type": "pdouble",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete field expression_level_fpkm\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "expression_level_fpkm"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field expression_level_fpkm (pdouble, DocValues)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "expression_level_fpkm",
    "type": "pdouble",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete expression_levels\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "expression_levels"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate expression_levels (pdouble, multi-valued)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "expression_levels",
    "type": "pdouble",
    "multiValued": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete expression_levels_fpkm\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "expression_levels_fpkm"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate expression_levels_fpkm (pdouble, multi-valued)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "expression_levels_fpkm",
    "type": "pdouble",
    "multiValued": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete field num_replicates\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "num_replicates"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field num_replicates (pint, DocValues)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "num_replicates",
    "type": "pint",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete field fold_change\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "fold_change"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field fold_change (pdouble, DocValues)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "fold_change",
    "type": "pdouble",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete field p_value\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "p_value"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field p_value (pdouble, DocValues)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "p_value",
    "type": "pdouble",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete field t_statistic\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "t_statistic"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field t_statistic (pdouble)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "t_statistic",
    "type": "pdouble"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete field regulation\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "regulation"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field regulation (string, DocValues)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "regulation",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete dynamic field rule keyword_*\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field": {
     "name": "keyword_*"}
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate dynamic rule keyword_* (string, multi-valued)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field": {
     "name": "keyword_*",
     "type": "lowercase",
     "multiValued": true}
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete field identifier_search\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field" :
  {
    "name": "identifier_search"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field identifier_search (text_en)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "identifier_search",
    "type": "text_en",
    "stored": false
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete field conditions_search\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field" :
  {
    "name": "conditions_search"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nDelete field type text_en_tight\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field-type":
  {
    "name": "text_en_tight"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field type text_en_tight\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field-type": {
    "name": "text_en_tight",
    "class": "solr.TextField",
    "positionIncrementGap": "100",
    "analyzer" : {
      "tokenizer": {
        "class": "solr.WhitespaceTokenizerFactory"
      },
      "filters": [
        {
          "class":"solr.LowerCaseFilterFactory"
        },
        {
          "class":"solr.EnglishPossessiveFilterFactory"
        },
        {
          "class":"solr.PorterStemFilterFactory"
        }
      ]
    }
  }
}' http://${HOST}/solr/${COLLECTION}/schema

printf "\n\nCreate field conditions_search (text_en_tight)\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "conditions_search",
    "type": "text_en_tight",
    "stored": false
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

printf "\n\nDelete dedupe update processor\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-updateprocessor": "dedupe"
}' http://${HOST}/solr/${COLLECTION}/config


printf "\n\nDisable autoCreateFields (aka “Data driven schema”)"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "set-user-property": {
    "update.autoCreateFields": "false"
  }
}' http://${HOST}/solr/${COLLECTION}/config


printf "\n\nCreate dedupe update processor\n"
curl $SOLR_AUTH -X POST -H 'Content-type:application/json' --data-binary '{
  "add-updateprocessor":
  {
    "name": "dedupe"
    "class": "solr.processor.SignatureUpdateProcessorFactory",
    "enabled": "true",
    "signatureField": "id",
    "overwriteDupes": "true",
    "fields": "experiment_accession,bioentity_identifier,assay_group_id,contrast_id",
    "signatureClass": "solr.processor.Lookup3Signature"
  }
}' http://${HOST}/solr/${COLLECTION}/config
