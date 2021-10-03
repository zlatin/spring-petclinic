pipeline { 
    agent any  
    stages { 
        stage('Checkout') { 
            steps { 
               checkout scm
            }
        }
        stage('Build'){
            steps {
                sh './mvnw package'
            }
        }
        stage('Build Docker Image'){
            steps {
                script {
                    dockerImage = docker.build("petshop")
                }
            }
        }
        stage("Publish Docker Image"){
            steps{
                script {
                    docker.withRegistry("https://353770932280.dkr.ecr.us-east-1.amazonaws.com", "ecr:us-east-1:aws_cred") {
                        dockerImage.push("${env.BUILD_NUMBER}")
                    }
                }
            }
        }
        
    }
}