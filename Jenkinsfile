pipeline {
  agent any
  options { timestamps() }
  triggers { githubPush() } // webhook triggers

  stages {
    stage('Checkout') { steps { checkout scm } }

    stage('Build & Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub',
                                          usernameVariable: 'DOCKERHUB_USER',
                                          passwordVariable: 'DOCKERHUB_PASS')]) {
          script {
            def branch = env.BRANCH_NAME ?: sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
            def target = (branch == 'main' || branch == 'master') ? 'prod' : 'dev'
            sh 'chmod +x scripts/build.sh'
            sh "DOCKERHUB_USER=${DOCKERHUB_USER} DOCKERHUB_PASS=${DOCKERHUB_PASS} ./scripts/build.sh ${target}"
          }
        }
      }
    }

    stage('Deploy on EC2') {
      when { anyOf { branch 'dev'; branch 'main'; branch 'master' } }
      steps {
        script {
          def branch = env.BRANCH_NAME ?: sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
          def target = (branch == 'main' || branch == 'master') ? 'prod' : 'dev'
          sh 'chmod +x scripts/deploy.sh'
          sh "./scripts/deploy.sh ${target}"
        }
      }
    }
  }

  post {
    success { echo 'Deploy complete.' }
    failure { echo 'Build failed.' }
  }
}

