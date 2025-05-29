pipeline {
  agent any

  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))  // Keep only the latest 5 builds
  }

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub')
    SONAR_TOKEN = credentials('sonar-token')
  }

  stages {
    stage('SonarQube Analysis') {
      steps {
        dir('/var/lib/jenkins/workspace/CK_Devops_mbp_main') {
          sh '/home/anhhoang3/sonar-scanner-5.0.1.3006-linux/bin/sonar-scanner'
        }
      }
    }
    
    stage('DockerHub Login') {
      steps {
        sh '''
          echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        echo 'Starting build Docker image...'
        sh 'docker build -t anhhoang499/fastapi .'
        echo 'Built Docker image.'
      }
    }

    stage('Deploy') {
      steps {
        script {
          withCredentials([sshUserPrivateKey(credentialsId: 'deploy-ssh-key', keyFileVariable: 'SSH_KEY')]) {
              sh """
                  ssh -o StrictHostKeyChecking=no -i $SSH_KEY ubuntu2@172.171.243.226 << 'ENDSSH'
                  docker pull anhhoang499/fastapi
                  docker stop fastapi || true
                  docker rm fastapi || true
                  docker run -d --name fastapi -p 8000:8000 anhhoang499/fastapi
                  docker image prune -f
              """
          }
        }
      }
    }
  }

  post {
    always {
      sh 'docker logout'
    }
  }
}