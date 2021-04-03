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

      stage('Remove APP_NAME from VM-DEV01') {
        steps {
          script {
            docker.withServer("$VM_DEV01", 'vm-dev01-creds') {
              sh 'docker stop $(docker ps -a |grep $APP_NAME|awk \'{print $1;}\')'
              sh 'docker rm $(docker ps -a |grep $APP_NAME|awk \'{print $1;}\')'
              sh 'docker system prune -a -f'
            }
          }
        }
      }

      stage('Remove APP_NAME from VM-DEV02') {
        steps {
          script {
            docker.withServer("$VM_DEV02", 'vm-dev02-creds') {
              sh 'docker stop $(docker ps -a |grep $APP_NAME|awk \'{print $1;}\')'
              sh 'docker rm $(docker ps -a |grep $APP_NAME|awk \'{print $1;}\')'
              sh 'docker system prune -a -f'
            }
          }
        }
      }


      stage('Setup NFS Server on VM-DEV01') {
        steps {
          script {
            docker.withServer("$VM_DEV01", 'vm-dev01-creds') {
              echo 'Setup NFS Server on VM1'
              sh 'cat nfs-server.sh | sed "s/CLIENT_IP/$VM_DEV02/g" | bash'
              sh 'ls -ahl /local'
            }
          }
        }
      }

      stage('Setup NFS Client on VM-DEV02') {
        steps {
          script {
            docker.withServer("$VM_DEV02", 'vm-dev02-creds') {
              echo 'Setup NFS Client on VM2'
              sh 'cat nfs-client.sh | sed "s/HOST_IP/$VM_DEV01/g" | bash'
              sh 'ls -ahl /local'
            }
          }
        }
      }

      stage('FAIL') {
          steps {
              sh 'ifconfig'
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
