#!/usr/bin/env
newman run /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-postman-collection/reg_test_for_8_users.postman_collection.json -d /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-data-files/gene-symbols-set1.csv -e /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-postman-collection/regression-testing.postman_environment.json >> /Users/ukumbham/Documents/regression_testing/results/user1_output.json &


newman run /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-postman-collection/reg_test_for_8_users.postman_collection.json -d /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-data-files/gene-symbols-set1.csv -e /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-postman-collection/regression-testing.postman_environment.json >> /Users/ukumbham/Documents/regression_testing/results/user2_output.json &

newman run /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-postman-collection/reg_test_for_8_users.postman_collection.json -d /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-data-files/gene-symbols-set1.csv -e /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-postman-collection/regression-testing.postman_environment.json  >> /Users/ukumbham/Documents/regression_testing/results/user3_output.json &

newman run /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-postman-collection/reg_test_for_8_users.postman_collection.json -d /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-data-files/gene-symbols-set1.csv -e /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-postman-collection/regression-testing.postman_environment.json  >> /Users/ukumbham/Documents/regression_testing/results/user4_output.json &

newman run /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-postman-collection/reg_test_for_8_users.postman_collection.json -d /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-data-files/gene-symbols-set1.csv -e /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-postman-collection/regression-testing.postman_environment.json  >> /Users/ukumbham/Documents/regression_testing/results/user5_output.json &


newman run /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-postman-collection/reg_test_for_8_users.postman_collection.json -d /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-data-files/gene-symbols-set1.csv -e /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-postman-collection/regression-testing.postman_environment.json  >> /Users/ukumbham/Documents/regression_testing/results/user6_output.json






