# Load analytics files in Solr


for EXP_ID in E-MTAB-3578 E-MTAB-3579 E-MTAB-3358
do
  INPUT_JSONL=./bulk-analytics/${EXP_ID}.jsonl SOLR_COLLECTION=bulk-analytics SCHEMA_VERSION=1 SOLR_PROCESSORS=dedupe ./bin/solr-jsonl-chunk-loader.sh
done
