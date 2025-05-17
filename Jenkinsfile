pipeline {
  agent any

  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))  // Keep only the latest 5 builds
  }

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub')  // Jenkins credentials ID
  }

  stages {
    stage('SonarQube Analysis') {
      steps {
        dir('/var/lib/jenkins/workspace/CK_Devops_mbp_main') {
          sh '''
            /home/anhhoang3/sonar-scanner/bin/sonar-scanner \
              -Dsonar.projectKey=your_project_key \
              -Dsonar.host.url=http://your-sonarqube-server:9000 \
              -Dsonar.login=your_sonar_token
          '''
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
  }

  post {
    always {
      sh 'docker logout'
    }
  }
}
