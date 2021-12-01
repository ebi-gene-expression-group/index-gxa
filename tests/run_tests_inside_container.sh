#!/bin/sh

whoami
ls -l /usr/local/tests/fixtures/experiment_files/expdesign
chmod a+w /usr/local/tests/fixtures/experiment_files/expdesign
ls -l /usr/local/tests/fixtures/experiment_files/expdesign

/usr/local/tests/run-tests.sh
