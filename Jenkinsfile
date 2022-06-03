pipeline {
    agent any

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "3.8.5"
        jdk "JDK11"
    }

    stages {
        stage('Build') {
            steps {

                // Get Pet Clinic code
                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/mordrid/spring-petclinic-jfrog.git'

                // Run Maven on a Unix agent but skip testing to allow testing to be a separate stage
                sh "./mvnw -Dmaven.test.skip package clean package"

            }

            post {
                success {
                    archiveArtifacts 'target/*.jar'
                }
            }
        }

        stage('Test') {
             steps {

               // Get Pet Clinic code
               git branch: "${env.BRANCH_NAME}", url: 'https://github.com/mordrid/spring-petclinic-jfrog.git'

                // Run Maven on a Unix agent.
                sh "./mvnw -Dmaven.test.failure.ignore=true test"

             }

             post {
                // If Maven was able to run the tests, even if some of the test
                // failed, record the test results and archive the jar file.
                success {
                   junit '**/target/surefire-reports/TEST-*.xml'
                }
             }
        }

        stage('Package') {
            steps {
                // Get Pet Clinic code
                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/mordrid/spring-petclinic-jfrog.git'

                // Docker Build with built jar as arg
                sh "docker build --build-arg JAR_FILE=target/*.jar -t https://vcem.jfrog.io/artifactory/default-docker-virtual/spring-petclinic-jfrog ."
            }
        }
    }
}
