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
          sh 'whoami'
          sh '/home/anhhoang3/sonar-scanner-5.0.1.3006-linux/bin/sonar-scanner'
        }
      }
    }
    
    stage('Build Docker Image') {
      steps {
        sh 'docker build -t anhhoang499/fastapi .'
      }
    }

    stage('DockerHub Login') {
      steps {
        sh '''
          echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
        '''
      }
    }

    stage('Push Docker Image') {
      steps {
        sh 'docker push anhhoang499/fastapi'
      }
    }

    stage('Deploy') {
        steps {
            script {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'deploy-ssh-key',
                    keyFileVariable: 'SSH_KEY',
                    usernameVariable: 'SSH_USER'
                )]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY $SSH_USER@172.171.243.226 << 'ENDSSH'
                            docker pull anhhoang499/fastapi:latest
                            docker stop fastapi || true
                            docker rm fastapi || true
                            docker run -d --name fastapi -p 8000:8000 anhhoang499/fastapi
                        ENDSSH
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