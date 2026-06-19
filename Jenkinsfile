pipeline {
   agent any

    environment {
        // Define your Docker Hub credentials ID (configured inside Jenkins GUI)
        DOCKER_HUB_CREDS = 'dockerhub-credentials-id'
        IMAGE_NAME       = 'dh2uhf2i/myapp'
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Automatically pulls the latest code from your Git repository
                checkout scm
            }
        }

        stage('Run Lint Tests') {
            steps {
                echo 'Installing HTMLHint and testing source code...'
                // Runs the same HTML lint test inside the Jenkins workspace
                bat 'npm install -g htmlhint'
                bat 'htmlhint index.html'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building the production Docker image...'
                // Builds the container using the local Dockerfile
                bat "docker build -t ${'myapp'}:${BUILD_NUMBER} ."
                bat "docker tag ${'myapp'}:${BUILD_NUMBER} ${'myapp'}:latest"
            }
        }

        stage('Push to Registry') {
            steps {
                echo 'Logging into Docker Hub and pushing image...'
                // Securely logs into Docker Hub using Jenkins' built-in credential manager
                withCredentials([usernamePassword(credentialsId: "${dh2uhf2i}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    bat "echo ${PASS} | docker login -u ${USER} --password-stdin"
                    bat "docker push ${'myapp'}:${BUILD_NUMBER}"
                    bat "docker push ${'myapp'}:latest"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Triggering rolling update on Kubernetes cluster...'
                // Instructs Kubernetes to roll out the newly built container image
                bat "kubectl apply -f k8s-deployment.yaml"
                bat "kubectl rollout status deployment/webapp-deployment"
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Jenkins workspace...'
            // Cleans up built images locally on the Jenkins server to save disk space
            bat "docker rmi ${'myapp'}:${'myapp'} ${'myapp'}:latest || true"
        }
        success {
            echo 'Pipeline completed successfully! Webapp is live.'
        }
        failure {
            echo 'Pipeline failed. Check the stages above for errors.'
        }
    }
}
