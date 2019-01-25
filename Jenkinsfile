pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: "10"))
        disableConcurrentBuilds()
        timestamps()
    }

    stages {
        stage("Preparation") {
            steps {
                sh "build/prepare.sh"
                script {
                    env.BUILD_VERSION = readFile("BUILD_VERSION")
                    env.BACKEND_ARTIFACT = readFile("BACKEND_ARTIFACT")
                    env.FRONTEND_ARTIFACT = readFile("FRONTEND_ARTIFACT")
                    env.HOME = env.JENKINS_HOME
                }
            }
        }

        stage("Publish") {
            failFast true
            parallel {
                stage("Publish to Docker registry") {
                    when {
                        expression { env.BRANCH_NAME == "master" || env.BRANCH_NAME == "develop" }
                    }
                    steps {
                        sh "build/publish/docker/publish.sh"
                    }
                }
            }
        }
    }
}