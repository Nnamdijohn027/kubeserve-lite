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
        
        stage('Save and Compress Image') {
            steps {
                sh """
                    sudo docker save ${DOCKER_IMAGE} -o kubeserve.tar
                    sudo chown jenkins:jenkins kubeserve.tar
                    gzip -f kubeserve.tar
                """
            }
        }
        
        stage('Copy Image to App Server') {
            steps {
                sh """
                    scp -o StrictHostKeyChecking=no -i ~/Downloads/devops-portfolio-key.pem kubeserve.tar.gz ec2-user@${APP_SERVER}:/home/ec2-user/
                    ssh -o StrictHostKeyChecking=no -i ~/Downloads/devops-portfolio-key.pem ec2-user@${APP_SERVER} "gunzip -f /home/ec2-user/kubeserve.tar.gz && sudo docker load -i /home/ec2-user/kubeserve.tar"
                    ssh -o StrictHostKeyChecking=no -i ~/Downloads/devops-portfolio-key.pem ec2-user@${APP_SERVER} "sudo docker tag ${DOCKER_IMAGE} kubeserve:latest"
                """
            }
        }
        
        stage('Deploy to k3s') {
            steps {
                sh """
                    ssh -o StrictHostKeyChecking=no -i ~/Downloads/devops-portfolio-key.pem ec2-user@${APP_SERVER} "kubectl apply -f ~/deployment.yaml"
                    ssh -o StrictHostKeyChecking=no -i ~/Downloads/devops-portfolio-key.pem ec2-user@${APP_SERVER} "kubectl rollout status deployment/kubeserve --timeout=60s"
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