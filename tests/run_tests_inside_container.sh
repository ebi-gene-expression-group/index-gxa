#!/bin/sh

#apk add bash bats openjdk11
chmod -R 755 /usr/local/tests

/usr/local/tests/run-tests.sh
