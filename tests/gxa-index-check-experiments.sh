#!/usr/bin/env bash
# check the health of experiments

[ ! -z ${SOLR_HOST+x} ] || ( echo "Env var SOLR_HOST needs to be defined." && exit 1 )
[ ! -z ${ATLAS_EXPS+x} ] || (echo "Env var ATLAS_EXPS needs to be defined." && exit 1)
[ ! -z ${EXP_MATCH_MIN+x} ] || (echo "Env var EXP_MATCH_MIN needs to be defined." && exit 1)
[ ! -z ${EXP_MATCH_WARNING+x} ] || (echo "Env var EXP_MATCH_WARN needs to be defined." && exit 1)


out=$(curl "http://$SOLR_HOST/solr/gxa-analytics-v1/select?fl=experiment_accession&q=*:*&rows=10000000&group=true&group.field=experiment_accession")
status="$?"
if [[ "$status" -ne "0" ]]; then
    echo $out
    exit 1
fi
for exp in $ATLAS_EXPS; do
    n_entries=$(echo "$out" | grep -A 1 $exp | egrep -o '"numFound":[0-9]+' | egrep -o "[0-9]+")
    if [[ $n_entries -lt $EXP_MATCH_MIN ]]; then
        echo "Error: experiment $exp has $n_entries entries which is below the minimum of $EXP_MATCH_MIN."
        expFail=true
    elif [[ $n_entries -lt $EXP_MATCH_WARNING ]]; then
        echo "Warning: experiment $exp has $n_entries matches. Experiments are expected to have over $EXP_MATCH_WARN entries."
    fi
done
if [ "$expFail" = true ]; then
    echo "Experiments with insufficient entries found - see out/errors"
    exit 1
fi
echo "All indexed experiments have sufficient entries - Successful Run"
exit 0