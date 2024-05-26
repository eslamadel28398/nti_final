pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID="767397735708"
        AWS_DEFAULT_REGION="us-east-1"
        REPOSITORY_URI_front = "767397735708.dkr.ecr.us-east-1.amazonaws.com/nti-frontend"

        REPOSITORY_URI_back = "767397735708.dkr.ecr.us-east-1.amazonaws.com/nti-backend"
    }
   
    stages {
        
         stage('Logging into AWS ECR') {
            steps {


              withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                script {
                sh """aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"""
                }
              }

                 
            }
        }
        

  
    // Building Docker images
    stage('Building frontend image') {
      steps{
        script {
          sh "docker build -t ${REPOSITORY_URI_front}:$BUILD_NUMBER docker_part/3tier-nodejs/frontend"
        }
      }
    }
   
    // Uploading Docker images into AWS ECR
    stage('Pushing frontend to ECR') {
     steps{  
         script {
          
                sh "docker push ${REPOSITORY_URI_front}:$BUILD_NUMBER"
         }
        }
      }
    stage('Building backend image') {
      steps{
        script {
          sh "docker build -t ${REPOSITORY_URI_back}:$BUILD_NUMBER docker_part/3tier-nodejs/backend"
        }
      }
    }

    // Uploading Docker backend images into AWS ECR
    stage('Pushing backend to ECR') {
     steps{  
         script {
          
                sh "docker push ${REPOSITORY_URI_back}:$BUILD_NUMBER"
         }
        }
      }

  
    }

}

