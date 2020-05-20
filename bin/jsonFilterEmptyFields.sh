#!/usr/bin/env bash

# "Slurps" a stream of JSON objects and converts them to a JSON array. Filters out empty fields (for example, not all factors/characteristics have ontology annotations)

jq -s '. | del(.[][] | select(. == [""]))'
