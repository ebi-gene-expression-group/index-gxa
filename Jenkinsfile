   pipeline {
      options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '5'))
      }

      agent {
        kubernetes {
          defaultContainer 'newman'
          yamlFile 'jenkins-k8s-pod.yaml'
        }
      }

     stages {
         stage('Test') {
           options {
             timeout (time: 20, unit: "MINUTES")
           }
           steps {
            echo 'testing stage........'
             sh 'newman run ~/solr-regression-test-scripts/postman-collection/Reg_tests_with_threshould_limit.postman_collection.json -d ~/solr-regression-test-scripts/data-files/popular-gene-symbols.csv -e ~/solr-regression-test-scripts/postman-collection/regression-testing.postman_environment.json  -r htmlextra'
           }
         }
       }
 }


