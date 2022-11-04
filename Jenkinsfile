   pipeline {
      options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '5'))
      }

      agent {
        kubernetes {
          cloud 'gke-autopilot'
          workspaceVolume dynamicPVC(storageClassNames: 'fast', accessModes: 'ReadWriteOnce', requestsSize: '5Gi')
          defaultContainer 'openjdk'
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
             sh 'newman run /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-postman-collection/reg_test_for_8_users.postman_collection.json -d /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-data-files/gene-symbols-set1.csv -e /Users/ukumbham/atlas/atlas-solr-regression-test-scripts/bulk-postman-collection/regression-testing.postman_environment.json  -r htmlextra'
           }
         }
       }
 }


