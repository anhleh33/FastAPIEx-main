pipeline {
  agent any

  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
    // timeout(time: 10, unit: 'MINUTES')
  }

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub')
    SONAR_TOKEN = credentials('sonar-token')
  }

  stages {
    stage('SonarQube Analysis') {
      // options {
      //   timeout(time: 2, unit: 'MINUTES')
      // }
      steps {
        dir('/var/lib/jenkins/workspace/CK_Devops_mbp_main') {
          catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
            sh '/home/anhhoang3/sonar-scanner-5.0.1.3006-linux/bin/sonar-scanner'
          }
        }
      }
    }

    stage('Build Docker Image') {
      // options {
      //   timeout(time: 2, unit: 'MINUTES')
      // }
      steps {
        catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
          sh 'docker build -t anhhoang499/fastapi .'
        }
      }
    }

    stage('Run Tests') {
      // options {
      //   timeout(time: 2, unit: 'MINUTES')
      // }
      steps {
        catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
          sh 'pytest --maxfail=1 --disable-warnings -q'
        }
      }
    }

    stage('DockerHub Login') {
      // options {
      //   timeout(time: 1, unit: 'MINUTES')
      // }
      steps {
        catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
          sh '''
            echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
          '''
        }
      }
    }

    stage('Push Docker Image') {
      // options {
      //   timeout(time: 2, unit: 'MINUTES')
      // }
      steps {
        catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
          sh 'docker push anhhoang499/fastapi'
        }
      }
    }

    stage('Deploy') {
      // options {
      //   timeout(time: 2, unit: 'MINUTES')
      // }
      steps {
        script {
          withCredentials([sshUserPrivateKey(credentialsId: 'deploy-ssh-key', keyFileVariable: 'SSH_KEY')]) {
            catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
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
  }

  post {
    always {
      sh 'docker logout'
    }

    failure {
      echo "❌ Pipeline FAILED"
      echo "❗ Trạng thái: ${currentBuild.currentResult}"
      echo "🔍 Nguyên nhân lỗi: ${currentBuild.rawBuild.getLog(50).join('\n')}"
      echo "Build result: ${currentBuild.currentResult}"
      echo "Build number: ${currentBuild.number}"
      echo "Build URL: ${currentBuild.absoluteUrl}"
    }

    success {
      echo "✅ Pipeline SUCCESS"
    }
  }
}
