pipeline {
    agent any

    environment {
        // Your Docker Hub credentials ID created in Jenkins
        DOCKER_HUB_CREDS = 'dh2uhf2i'
        IMAGE_NAME       = 'dh2uhf2i/myapp'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Run Lint Tests') {
            steps {
                echo 'Installing HTMLHint and testing source code...'
                bat 'npx htmlhint index.html'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building the production Docker image...'
                // Build with local names using Jenkins BUILD_NUMBER variable
                bat "docker build -t myapp:${BUILD_NUMBER} ."
                bat "docker tag myapp:${BUILD_NUMBER} myapp:latest"
            }
        }

        stage('Push to Registry') {
            steps {
                echo 'Logging into Docker Hub and pushing image...'
                // Using the environment variable DOCKER_HUB_CREDS we defined at the top
                withCredentials([usernamePassword(credentialsId: "${env.DOCKER_HUB_CREDS}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    // Log in using Windows batch variable syntax (%PASS%, %USER%)
                    bat "echo %PASS% | docker login -u %USER% --password-stdin"
                    
                    // Tag using the build number and your Docker Hub repository prefix
                    bat "docker tag myapp:${BUILD_NUMBER} %USER%/myapp:${BUILD_NUMBER}"
                    bat "docker tag myapp:${BUILD_NUMBER} %USER%/myapp:latest"
                    
                    // Push the prefixed repositories to Docker Hub
                    bat "docker push %USER%/myapp:${BUILD_NUMBER}"
                    bat "docker push %USER%/myapp:latest"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Triggering rolling update on Kubernetes cluster...'
                bat "kubectl apply -f deployment.yaml --validate=false"
                bat "kubectl rollout status deployment/webapp-deployment"
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Jenkins workspace...'
            // Dynamically cleans up exactly what was created this build
            bat script: "docker rmi myapp:${BUILD_NUMBER} myapp:latest dh2uhf2i/myapp:${BUILD_NUMBER} dh2uhf2i/myapp:latest", returnStatus: true
        }
        success {
            echo 'Pipeline completed successfully! Webapp is live.'
        }
        failure {
            echo 'Pipeline failed. Check the stages above for errors.'
        }
    }
}
