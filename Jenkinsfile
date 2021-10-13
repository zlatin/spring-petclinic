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
        stage('Publish Docker Image from main branch') {
            when {
                branch 'main'
            }
            steps {
                script {
                    docker.withRegistry("http://${env.ECR_REPOSITORY}", 'ecr:us-east-1:aws_credentials') {
                        dockerImage.push("${env.BUILD_NUMBER}")
                    }
                }
            }
        }
        stage('Publish Docker Image from other branches') {
            when {
                not {
                    branch 'main'
                }
            }
            steps {
                script {
                    docker.withRegistry("${env.ECR_REPOSITORY}", 'ecr:us-east-1:aws_credentials') {
                        dockerImage.push("${env.BRANCH_NAME}-${env.BUILD_NUMBER}")
                    }
                }
            }
        }
        stage('Deploy servise to ECR') {
            when {
                branch 'main'
            }
            environment {
                LOCAL_AWS = credentials('aws_log_pass')
                AWS_ACCESS_KEY_ID = "${LOCAL_AWS_USR}"
                AWS_SECRET_ACCESS_KEY = "${LOCAL_AWS_PSW}"
                AWS_DEFAULT_REGION = 'us-east-1'
            }
            steps {
                sh "ansible-playbook ./infrastructure/create_service.yml -e 'service_name=petclinic build_id=latest image=${env.ECR_REPOSITORY}:${env.BUILD_NUMBER}'"
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
