pipeline {
    agent any

    environment {
    AWS_ACCOUNT_ID="767397735708"
    AWS_DEFAULT_REGION="us-east-1"

    }

    stages {
      stage('Clone repository') {  
        steps {

git branch: 'main', url: 'https://github.com/eslamadel28398/final-project.git'
        }
      }

      stage("deploy to kubernetes cluster"){
          steps{
              withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                script {
                sh "aws eks update-kubeconfig --region us-east-1 --name eks1"

                sh "kubectl apply -f kubernetes_part/5-storage_class.yml"
                sh "kubectl apply -f kubernetes_part/6-pv.yml"
                sh "kubectl apply -f kubernetes_part/4-mongo_pvc.yml"
                sh "kubectl apply -f kubernetes_part/3-mongo.yml"
                sh "kubectl apply -f kubernetes_part/2-backend.yml"
                sh "kubectl apply -f kubernetes_part/1-frontend.yml"


                }
              }
          }

      }
    }
}
