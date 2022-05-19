#!/usr/bin/env bash
SCHEMA_VERSION=1

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"bulk-analytics-v$SCHEMA_VERSION"}

#############################################################################################

printf "\n\nDelete field experiment_accession "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "experiment_accession"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate field experiment_accession (string) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "experiment_accession",
    "type": "string",
    "docValues": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field is_private\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "is_private"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field is_private (boolean)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "is_private",
    "type": "boolean"
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete copy field rule bioentity_identifier -> bioentity_identifier_search\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-copy-field":
  {
    "source": "bioentity_identifier",
    "dest": "bioentity_identifier_search"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nDelete field bioentity_identifier\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "bioentity_identifier"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field bioentity_identifier (string, DocValues)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "bioentity_identifier",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nDelete field bioentity_identifier_search\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "bioentity_identifier_search"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field bioentity_identifier_search (lowercase)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "bioentity_identifier_search",
    "type": "lowercase"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nAdd copy field rule bioentity_identifier -> bioentity_identifier_search\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":
  {
    "source": "bioentity_identifier",
    "dest": "bioentity_identifier_search"
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete field assay_group_id\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field" :
  {
    "name": "assay_group_id"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field assay_group_id (string, DocValues)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "assay_group_id",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

# TODO Do we need assay? is not in https://github.com/ebi-gene-expression-group/solr-bulk/blob/master/bin/create-bulk-analytics-schema.sh
printf "\n\nDelete field assay "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field" :
  {
    "name": "assay"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate field assay (string) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "assay",
    "type": "string",
    "docValues": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field contrast_id\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "contrast_id"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field contrast_id (string)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "contrast_id",
    "type": "string"
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete field species\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "species"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field species (string, DocValues)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "species",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete field kingdom\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "kingdom"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field kingdom (string, DocValues)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "kingdom",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${CORE}/schema


#############################################################################################

printf "\n\nDelete field experiment_type\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "experiment_type"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field experiment_type (string, DocValues)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "experiment_type",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete field default_query_factor_type\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "default_query_factor_type"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field default_query_factor_type (string, DocValues)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "default_query_factor_type",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete field factors\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "factors"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field factors (string, multi-valued, DocValues)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "factors",
    "type": "string",
    "multiValued": true,
    "docValues": true
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete field expression_level\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "expression_level"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field expression_level (pdouble, DocValues)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "expression_level",
    "type": "pdouble",
    "docValues": true
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete field expression_level_fpkm\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "expression_level_fpkm"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field expression_level_fpkm (pdouble, DocValues)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "expression_level_fpkm",
    "type": "pdouble",
    "docValues": true
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete expression_levels\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "expression_levels"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate expression_levels (pdouble, multi-valued)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "expression_levels",
    "type": "pdouble",
    "multiValued": true
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete field num_replicates\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "num_replicates"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field num_replicates (pint, DocValues)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "num_replicates",
    "type": "pint",
    "docValues": true
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete field fold_change\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "fold_change"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field fold_change (pdouble, DocValues)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "fold_change",
    "type": "pdouble",
    "docValues": true
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete field p_value\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "p_value"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field p_value (pdouble, DocValues)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "p_value",
    "type": "pdouble",
    "docValues": true
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete field t_statistic\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "t_statistic"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field t_statistic (pdouble)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "t_statistic",
    "type": "pdouble"
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete field regulation\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "regulation"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field regulation (string, DocValues)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "regulation",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete dynamic field rule keyword_*\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field": {
     "name": "keyword_*"}
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate dynamic rule keyword_* (string, multi-valued)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field": {
     "name": "keyword_*",
     "type": "lowercase",
     "multiValued": true}
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete field identifier_search\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field" :
  {
    "name": "identifier_search"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field identifier_search (text_en)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "identifier_search",
    "type": "text_en",
    "stored": false
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete field conditions_search\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field" :
  {
    "name": "conditions_search"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nDelete field type text_en_tight\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field-type":
  {
    "name": "text_en_tight"
  }
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field type text_en_tight\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
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
}' http://${HOST}/solr/${CORE}/schema

printf "\n\nCreate field conditions_search (text_en_tight)\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "conditions_search",
    "type": "text_en_tight",
    "stored": false
  }
}' http://${HOST}/solr/${CORE}/schema

#############################################################################################

printf "\n\nDelete field ontology_annotation "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "ontology_annotation"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate ontology_annotation (string, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "ontology_annotation",
    "type": "string",
    "multiValued": true,
    "docValues": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# Deletion of copy field needs to come before the deletion of the actual fields.
# 1.1
printf "\n\nDelete copy field rule for facet_factor_* "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-copy-field":{
     "source": "factor_*",
     "dest": "facet_factor_*" }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# 1.2
printf "\n\nDelete dynamic field rule factor_* "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "factor_*"
  }
}' http://$HOST/solr/$CORE/schema
# 1.3
printf "\n\nCreate dynamic field rule factor_* (lowercase, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "factor_*",
    "type": "lowercase",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# 1.4
printf "\n\nDelete dynamic field rule facet_factor_* "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "facet_factor_*"
  }
}' http://$HOST/solr/$CORE/schema
# 1.5
printf "\n\nCreate dynamic field rule facet_factor_* (lowercase, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "facet_factor_*",
    "type": "string",
    "multiValued": true,
    "docValues": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# 1.6
printf "\n\nCreate copy field rule factor_* -> facet_factor_* "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":{
     "source": "factor_*",
     "dest": "facet_factor_*" }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

#############################################################################################
# Deletion of copy field needs to come before the deletion of the actual fields.
# 2.1
printf "\n\nDelete copy field rule characteristic_* -> facet_characteristic_* "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-copy-field":{
     "source": "characteristic_*",
     "dest": "facet_characteristic_*" }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# 2.2
printf "\n\nDelete dynamic field rule characteristic_* "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "characteristic_*"
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# 2.3
printf "\n\nCreate dynamic field rule characteristic_* (lowercase, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "characteristic_*",
    "type": "lowercase",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

# #############################################################################################
# 2.4
printf "\n\nDelete dynamic field rule facet_characteristic_* "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "facet_characteristic_*"
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# 2.5
printf "\n\nCreate dynamic field rule facet_characteristic_* (lowercase, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "facet_characteristic_*",
    "type": "string",
    "multiValued": true,
    "docValues": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# 2.6
printf "\n\nCreate copy field rule characteristic_* -> facet_characteristic_* "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":{
     "source": "characteristic_*",
     "dest": "facet_characteristic_*" }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# Fields required for BioSolr
# TODO do we need these dynamic field rules *_ for bulk analytics, they are not in https://github.com/ebi-gene-expression-group/solr-bulk/blob/master/bin/create-bulk-analytics-schema.sh

printf "\n\nDelete dynamic field rule *_rel_iris "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "*_rel_iris"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate dynamic field rule *_rel_iris (string, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "*_rel_iris",
    "type": "string",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nDelete dynamic field rule *_rel_labels "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "*_rel_labels"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate dynamic field rule *_rel_iris (text_general, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "*_rel_labels",
    "type": "text_general",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nDelete dynamic field rule *_s "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "*_s"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate dynamic field rule *_s (string, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "*_s",
    "type": "string",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nDelete dynamic field rule *_t "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "*_t"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate dynamic field rule *_t (string, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "*_t",
    "type": "text_general",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################

printf "\n\nDelete dedupe update processor\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-updateprocessor": "dedupe"
}' http://${HOST}/solr/${CORE}/config


printf "\n\nDisable autoCreateFields (aka “Data driven schema”)"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "set-user-property": {
    "update.autoCreateFields": "false"
  }
}' http://${HOST}/solr/${CORE}/config


printf "\n\nCreate dedupe update processor\n"
curl -X POST -H 'Content-type:application/json' --data-binary '{
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
}' http://${HOST}/solr/${CORE}/config

############################################################################

# TODO do we need all the ones below for bulk analytics? They are not in https://github.com/ebi-gene-expression-group/solr-bulk/blob/master/bin/create-bulk-analytics-schema.sh

printf "\n\nDelete update processor "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-updateprocessor": "'$CORE'_dedup"
}' http://$HOST/solr/$CORE/config


printf "\n\nDisable autoCreateFields (aka “Data driven schema”)"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "set-user-property": {
    "update.autoCreateFields": "false"
  }
}' http://$HOST/solr/$CORE/config


printf "\n\nCreate update processor "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-updateprocessor":
  {
    "name": "'$CORE'_dedup"
    "class": "solr.processor.SignatureUpdateProcessorFactory",
    "enabled": "true",
    "signatureField": "id",
    "overwriteDupes": "true",
    "fields": "experiment_accession,assay,characteristic_name,factor_name",
    "signatureClass": "solr.processor.Lookup3Signature"
  }
}' http://$HOST/solr/$CORE/config


printf "\n\nDelete ontology expansion update processor "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-updateprocessor": "'$CORE'_ontology_expansion"
}' http://$HOST/solr/$CORE/config


printf "\n\nCreate ontology expansion update processor "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-updateprocessor":
  {
    "name": "'$CORE'_ontology_expansion"
    "runtimeLib": true,
    "class": "uk.co.flax.biosolr.solr.update.processor.OntologyUpdateProcessorFactory",
    "enabled": "true",
    "annotationField": "ontology_annotation",
    "synonymsField": "",
    "definitionField": "",
    "childField": "",
    "descendantsField": "",
    "ontologyURI": "https://www.ebi.ac.uk/efo/efo.owl"
  }
}' http://$HOST/solr/$CORE/config
