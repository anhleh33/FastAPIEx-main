pipeline {
  agent any

  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))  // Keep only the latest 5 builds
  }

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub')  // Jenkins credentials ID
    SONAR_TOKEN = credentials('sonar-token')
  }

  stages {
    stage('SonarQube Analysis') {
      steps {
        sh """
          /opt/sonar-scanner/bin/sonar-scanner \
            -Dsonar.projectKey=FastAPI \
            -Dsonar.sources=. \
            -Dsonar.host.url=http://172.212.93.226:9000 \
            -Dsonar.login=${SONAR_TOKEN}
        """
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
  }

  post {
    always {
      sh 'docker logout'
    }
  }
}
