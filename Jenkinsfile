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
                    credentialsId: 'app-server'  // Add this in Jenkins if using private repo
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}")
                }
            }
        }
        
        stage('Save and Compress Image') {
            steps {
                sh """
                    docker save ${DOCKER_IMAGE} -o kubeserve.tar
                    gzip -f kubeserve.tar
                """
            }
        }
        
        stage('Copy Image to App Server') {
            steps {
                sh """
                    scp -o StrictHostKeyChecking=no kubeserve.tar.gz ec2-user@${APP_SERVER}:/home/ec2-user/
                    ssh -o StrictHostKeyChecking=no ec2-user@${APP_SERVER} "gunzip -f /home/ec2-user/kubeserve.tar.gz && docker load -i /home/ec2-user/kubeserve.tar"
                    ssh -o StrictHostKeyChecking=no ec2-user@${APP_SERVER} "docker tag ${DOCKER_IMAGE} kubeserve:latest"
                """
            }
        }
        
        stage('Deploy to k3s') {
            steps {
                sh """
                    ssh -o StrictHostKeyChecking=no ec2-user@${APP_SERVER} "kubectl apply -f ~/deployment.yaml"
                    ssh -o StrictHostKeyChecking=no ec2-user@${APP_SERVER} "kubectl rollout status deployment/kubeserve --timeout=60s"
                """
                echo "✅ Application deployed successfully!"
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