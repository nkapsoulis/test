pipeline {
    agent any
    tools {
          maven 'Maven 3.6.3'
          jdk 'jdk8'
    }
    environment {
      APP_NAME = "test-module-rest"
      ARTIFACTORY_SERVER = "https://116.203.2.204:443/artifactory/plgregistry/"
      ARTIFACTORY_DOCKER_REGISTRY = "116.203.2.204:443/plgregistry/"
      BRANCH_NAME = "master"
      DOCKER_IMAGE_TAG = "$APP_NAME:R${env.BUILD_ID}"
      VM_DEV01 = "116.203.2.205:2376"
      VM_DEV02 = "116.203.2.206:2376"
    }

    stages {
      stage('Checkout') {
          steps {
              echo 'Checkout SCM'
              checkout scm
              checkout([$class: 'GitSCM',
                        branches: [[name: env.BRANCH_NAME]],
                        extensions: [[$class: 'CleanBeforeCheckout']],
                        userRemoteConfigs: scm.userRemoteConfigs
              ])
            }
        }

        stage('Build with Maven') {
            steps {
                echo 'Build with Maven'
                sh 'mvn -f pom.xml clean package'
            }
        }

        stage('Build image') { // build and tag docker image
            steps {
                echo 'Starting to build docker image'
                script {
                    def dockerImage = docker.build(ARTIFACTORY_DOCKER_REGISTRY + DOCKER_IMAGE_TAG)
                }
            }
        }

        stage ('Push image to Artifactory') {
            steps {
              withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'Artifacts', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                  echo 'Login to Artifactory Registry'
                  sh "docker login --password=${PASSWORD} --username=${USERNAME} ${ARTIFACTORY_SERVER}"

                  echo 'Pull image with Build-ID'
                  sh 'docker push "$ARTIFACTORY_DOCKER_REGISTRY$DOCKER_IMAGE_TAG"'

                  echo 'Logout from Registry'
                  sh 'docker logout $ARTIFACTORY_SERVER'
              }
            }
        }

        stage('Docker Remove Image from CI Server') {
        steps {
                sh 'docker rmi "$ARTIFACTORY_DOCKER_REGISTRY$DOCKER_IMAGE_TAG"'
            }
        }

        stage('Deploy image on DEV_XX') {
          steps{
            script {
              docker.withServer("$VM_DEV01", 'vm-dev01-creds') {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'Artifacts', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                    echo 'Login to Artifactory Registry'
                    sh "docker login --password=${PASSWORD} --username=${USERNAME} ${ARTIFACTORY_SERVER}"

                    echo 'Pull image with Build-ID'
                    sh 'docker pull "$ARTIFACTORY_DOCKER_REGISTRY$DOCKER_IMAGE_TAG"'

                    echo 'Run docker image in detach mode'
                    sh 'docker run -d -p 8080:8080 --name "$APP_NAME" "$ARTIFACTORY_DOCKER_REGISTRY$DOCKER_IMAGE_TAG"'

                    echo 'Logout from Registry'
                    sh 'docker logout $ARTIFACTORY_SERVER'
                }
              }
            }
          }
        }
    }
}
