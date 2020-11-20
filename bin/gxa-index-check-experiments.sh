#!/usr/bin/env bash
# check the health of experiments

# $1: path to the list of experiments 
# $2: minimum number of matches for experiment to pass the check 
# $3: minimum number of matches to avoid warnings 

experiments=$(ls $1)
# extract number of entries per experiment 
out=$(curl "http://wp-np2-87:8983/solr/bulk-analytics-v1/select?fl=experiment_accession&q=*:*&rows=10000000&group=true&group.field=experiment_accession")
for exp in $experiments; do
    n_entries=$(echo $out | grep -A 1 $exp | egrep -o '"numFound":[0-9]+' | egrep -o "[0-9]+")
    if [ "$n_entries" -lt $2 ]; then
        echo "Error: experiment $exp has $n_entries entries which is below the minimum of $2."
        expFail=true
    elif [ "$n_entries" -lt $3 ]; then
        echo "Warning: experiment $exp has $n_entries. Experiments are expected to have over $3 entries." 
    fi
done
if [ "$expFail" = true ]; then
    echo "Experiments with insufficient entries found - see out/errors"
    exit 1
fi
echo "All indexed experiments have sufficient entries - Successful Run" 
exit 0


