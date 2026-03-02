pipeline {
    agent any
    
    environment {
        APP_VERSION = "1.0.${BUILD_NUMBER}"
        APP_SERVER = "52.23.177.47"
        DOCKER_IMAGE = "kubeserve:${APP_VERSION}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Nnamdijohn027/kubeserve-lite.git',
                    credentialsId: 'app-server'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh "sudo docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }
        
    post {
        always {
            echo "Pipeline completed with status: ${currentBuild.result}"
        }
        success {
            echo "✅ Successfully built and deployed ${DOCKER_IMAGE}"
        }
        failure {
            echo "❌ Pipeline failed. Check logs above."
        }
    }
}
