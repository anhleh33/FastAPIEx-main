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
          // Ensure SSH host key is trusted (avoids "Host key verification failed")
          sh '''
            mkdir -p ~/.ssh
            ssh-keyscan -H 172.171.243.226 >> ~/.ssh/known_hosts
          '''
          
          // Run deployment commands on the remote server
          sh '''
            ssh -o StrictHostKeyChecking=no ubuntu2@172.171.243.226 /bin/bash << 'EOF'
              echo "Pulling the latest Docker image..."
              docker pull anhhoang499/fastapi:latest || exit 1
              echo "Stopping and removing old container..."
              docker stop fastapi || true
              docker rm fastapi || true
              echo "Starting new container..."
              docker run -d --name fastapi -p 8000:8000 anhhoang499/fastapi
            EOF
          '''
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