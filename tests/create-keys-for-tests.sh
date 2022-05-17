#!/usr/bin/env bash

set -e
# based on 
# https://solr.apache.org/guide/8_7/package-manager-internals.html "Upload your keys"

# on developers environment export SOLR_HOST and export SOLR_COLLECTION before running
SIGNING_PRIVATE_KEY=${SIGNING_PRIVATE_KEY:-"/tmp/signing.pem"}
SIGNING_PUBLIC_KEY_DER=${SIGNING_PUBLIC_KEY_DER:-"/tmp/signing.der"}

openssl genrsa -out $SIGNING_PRIVATE_KEY 512
# create the public key in .der format
openssl rsa -in $SIGNING_PRIVATE_KEY -pubout -outform DER -out $SIGNING_PUBLIC_KEY_DER
# upload key to package store inside the solr process
# $ bin/solr package add-key my_key.der
