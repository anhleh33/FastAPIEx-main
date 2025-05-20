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

    stage('SonarQube Analysis') {
      steps {
        dir('/var/lib/jenkins/workspace/CK_Devops_mbp_main') {
          sh 'whoami'
          sh '/home/anhhoang3/sonar-scanner-5.0.1.3006-linux/bin/sonar-scanner'
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
