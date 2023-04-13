pipeline{
    agent {
        label 'Slave1-BuildServer'
    }

    stages{
        stage ('git-clone'){
            steps{
                git branch: 'feature2', url: 'https://github.com/MithunEdappulath/projCert.git'
            }
        }

        stage ('Docker-Build'){
            steps{
                sh 'docker build -t $JOB_NAME:V1.$BUILD_NUMBER .' 
            }
        }

        stage ('Docker Image Tag'){
            steps{
                sh 'docker tag $JOB_NAME:V1.$BUILD_NUMBER mithunedappulath/$JOB_NAME:V1.$BUILD_NUMBER'
                sh 'docker tag $JOB_NAME:V1.$BUILD_NUMBER mithunedappulath/$JOB_NAME:latest'
                sh 'docker images'
            }
        }

        stage ('Image-Push to Docker-Hub'){
            steps{
                withCredentials([usernamePassword(credentialsId: 'edureka-project-docker-login', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                    sh "docker login -u ${env.USERNAME} -p ${env.PASSWORD}"
                    sh 'docker push mithunedappulath/$JOB_NAME:V1.$BUILD_NUMBER'
                    sh 'docker push mithunedappulath/$JOB_NAME:latest'
                }
            }
        }

        stage ('Docker Image Clean-up'){
            steps{
                sh 'docker rmi $JOB_NAME:V1.$BUILD_NUMBER'
                sh 'docker rmi mithunedappulath/$JOB_NAME:V1.$BUILD_NUMBER'
                sh 'docker rmi mithunedappulath/$JOB_NAME:latest'
            }
        }  

        stage ('Deploy to Test-Server'){
            steps{
                echo 'Will be deployed soon - Working on'
            }
        }  
        
        
    }
}