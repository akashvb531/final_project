pipeline {
  agent any
  options { timestamps() }
  triggers { githubPush() }   // builds on GitHub push (webhook)

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build & Push Image') {
      steps {
        // Exposes DOCKERHUB_USER / DOCKERHUB_PASS env vars for build.sh
        withCredentials([usernamePassword(credentialsId: 'dockerhub',
                                          usernameVariable: 'DOCKERHUB_USER',
                                          passwordVariable:  'DOCKERHUB_PASS')]) {
          script {
            // Determine target based on branch
            def branch = env.BRANCH_NAME ?: sh(script: 'git rev-parse --abbrev-ref HEAD',
                                               returnStdout: true).trim()
            def target = (branch == 'main' || branch == 'master') ? 'prod' : 'dev'

            sh 'chmod +x scripts/build.sh'
            // build.sh reads DOCKERHUB_* from env (no secrets in command line)
            sh "bash ./scripts/build.sh ${target}"
          }
        }
      }
    }

    stage('Deploy on EC2') {
      when { anyOf { branch 'dev'; branch 'main'; branch 'master' } }
      steps {
        script {
          def branch = env.BRANCH_NAME ?: sh(script: 'git rev-parse --abbrev-ref HEAD',
                                             returnStdout: true).trim()
          def target = (branch == 'main' || branch == 'master') ? 'prod' : 'dev'

          sh 'chmod +x scripts/deploy.sh'
          sh "bash ./scripts/deploy.sh ${target}"
        }
      }
    }
  }

  post {
    success { echo 'Deploy complete.' }
    failure { echo 'Build failed.' }
  }
}

