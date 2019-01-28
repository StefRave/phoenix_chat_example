pipeline {
    agent any

    parameters {
		booleanParam(name: 'skipDeploySystemsTest', defaultValue: true, description: 'Skip deploying the systems test')
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: "10"))
        disableConcurrentBuilds()
        timestamps()
    }

    stages {
        stage("Preparation") {
            steps {
                script {
                    env.HOME = env.JENKINS_HOME

                    env.START_POSITION = (params.start_position == "default") ? ( env.BRANCH_NAME == "master"  ? 'begin' : 'build-only') : params.start_position
                    echo "Determining default start position with input (branch name: ${env.BRANCH_NAME}"

                    env.BUILD_VERSION = sh(script: "build/getversion.sh BUILD", returnStdout: true)
                    env.BASE_VERSION = sh(script: "build/getversion.sh BASE", returnStdout: true)

                    echo "Determining version numbers: BUILD_VERSION = ${env.BUILD_VERSION}, BASE_VERSION = ${env.BASE_VERSION}"
                }
            }
        }

        stage("Publish") {
            failFast false
            environment {
                ARTIFACTORY = credentials("artifactory")
                ARTIFACTORY_DOCKER_URL = "10.36.10.23:5002"
                NEXUS_DOCKER_URL = "cm-registry.ccveu.local:5004"
            }
            steps {
                sh "build/publish.sh"
            }
        }

        stage("Deploy application on systemsdev") {
            agent {
                dockerfile {
                    filename "build/deploy/Dockerfile.deploy"
                    additionalBuildArgs "--pull"
                }
            }
            environment {
                ENVIRONMENT = 'systemsdev'
                EXTRA_VARS = "ccv_terminalanywhere_version=${env.BUILD_VERSION}"
                PLAYBOOK_PATH = 'devops360repo/terminalanywhere'
                PLAYBOOK_FILENAME = 'install-terminalanywhere.yml'
                PLAYBOOK_REQUIREMENTS_TEMPLATE = 'requirements.yml.template'
            }
            steps {
                dir('devops360repo'){
                    git branch: "feature/terminalanywhere", url: "git@10.36.10.22:devops/devops360.git"
                    // sh "${env.WORKSPACE}/build/deploy/checkout-nearest-devops360-tag.sh"
                    dir('ssh-pub-keys'){
                        git branch: "master", url: "git@10.36.10.22:devops/ssh-pub-keys.git"
                    }
                }
                
                withCredentials(bindings: [
                    sshUserPrivateKey(credentialsId: '9694ff91-7dd4-4623-a159-1c335673864d',keyFileVariable: 'DEPLOY_KEY'),
                    sshUserPrivateKey(credentialsId: '9694ff91-7dd4-4623-a159-1c335673864d',keyFileVariable: 'GITLAB_KEY')]) {  
                    sh "build/deploy/execute-deploy.sh"
                }
            }
        }

        // stage("Promote development version to final") {
        //     when {
        //         expression { params.skipDeploySystemsTest == false }
        //     }
        //     environment {
        //         ARTIFACTORY = credentials("artifactory")
        //         ARTIFACTORY_DOCKER_URL = "10.36.10.23:5002"
        //         NEXUS_DOCKER_URL = "cm-registry.ccveu.local:5004"
        //     }
        //     steps {
        //         sh "build/publish/docker/promote.sh"
        //     }
        // }

        // stage("Deploy on systemstest") {
        //     when {
        //         expression { params.skipDeploySystemsTest == false }
        //     }
        //     failFast false
        //     stage("Deploy application on systemstest") {
        //         agent {
        //             dockerfile {
        //                 filename "build/deploy/Dockerfile.deploy"
        //                 additionalBuildArgs "--pull"
        //             }
        //         }
        //         environment {
        //             ENVIRONMENT = 'systemstest'
        //             EXTRA_VARS = "ccv_mertical_version=${env.BASE_VERSION}"
        //             PLAYBOOK_PATH = 'devops360repo/mertical2'
        //             PLAYBOOK_FILENAME = 'install-mertical-docker.yml'
        //             PLAYBOOK_REQUIREMENTS_TEMPLATE = 'requirements.yml.template'
        //         }
        //         steps {
        //             dir('devops360repo'){
        //                 git branch: "master", url: "git@10.36.10.22:devops/devops360.git"
        //                 sh "${env.WORKSPACE}/build/deploy/checkout-nearest-devops360-tag.sh"							
        //                 dir('ssh-pub-keys'){
        //                     git branch: "master", url: "git@10.36.10.22:devops/ssh-pub-keys.git"
        //                 }
        //             }
        //             withCredentials(bindings: [
        //                 sshUserPrivateKey(credentialsId: '9694ff91-7dd4-4623-a159-1c335673864d',keyFileVariable: 'DEPLOY_KEY'),
        //                 sshUserPrivateKey(credentialsId: '9694ff91-7dd4-4623-a159-1c335673864d',keyFileVariable: 'GITLAB_KEY')]) {  
        //                 sh "build/deploy/execute-deploy.sh"
        //             }
        //         }
        //     }
        // }
    }
}
