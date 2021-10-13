pipeline {
    agent 'any'
    options {
        skipDefaultCheckout(true)
    }
    stages {
        stage('Build') {
            steps {
                cleanWs()
                checkout scm
                sh './mvnw package'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build('petclinic')
                }
            }
        }
        stage('Publish Docker Image') {
            steps {
                script {
                    docker.withRegistry('env.ECR_REPOSITORY', 'ecr:us-east-1:aws_credentials') {
                        dockerImage.push("${env.BUILD_NUMBER}")
                    }
                }
            }
        }
    }
    post {
    // Clean after build
        always {
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                            [pattern: '.propsfile', type: 'EXCLUDE']])
        }
    }
}
