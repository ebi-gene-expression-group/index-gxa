#!/usr/bin/env bash
# check the health of experiments

[ -z ${SOLR_HOST+x} ] && echo "Env var SOLR_HOST needs to be defined." && exit 1
[ -z ${EXPERIMENT_ID+x} ] && echo "Env var EXPERIMENT_ID needs to be defined." && exit 1
[ -z ${EXP_MATCH_MIN+x} ] && echo "Env var EXP_MATCH_MIN needs to be defined." && exit 1
[ -z ${EXP_MATCH_WARNING+x} ] && echo "Env var EXP_MATCH_WARN needs to be defined." && exit 1

SOLR_USER=${QUERY_USER:-"solr"}
SOLR_PASS=${QUERY_U_PWD:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

out=$(curl $SOLR_AUTH --silent "http://$SOLR_HOST/solr/bulk-analytics-v1/select?fl=experiment_accession&q=*:*&rows=10000000&group=true&group.field=experiment_accession")
status="$?"
if [ "$status" -ne "0" ]; then
    echo $out
    exit 1
fi
for exp in $EXPERIMENT_ID; do
    n_entries=$(echo "$out" | grep -A 1 -e "\"$exp\"" | egrep -o '"numFound":[0-9]+' | egrep -o "[0-9]+")
    [ -z "$n_entries" ] && n_entries=0
    if [ "$n_entries" -lt "$EXP_MATCH_MIN" ]; then
        echo "Error: experiment $exp has $n_entries entries which is below the minimum of $EXP_MATCH_MIN."
        expFail=true
    elif [ "$n_entries" -lt "$EXP_MATCH_WARNING" ]; then
        echo "Warning: experiment $exp has $n_entries matches. Experiments are expected to have over $EXP_MATCH_WARNING entries."
    fi
done
if [ "$expFail" = true ]; then
    echo "Experiments with insufficient entries found - see out/errors"
    exit 1
fi
echo "All indexed experiments have sufficient entries - Successful Run"
exit 0
