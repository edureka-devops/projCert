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
                sh 'docker build -t $JOB_NAME:1.$BUILD_NUMBER .' 
            }
        }

        stage ('Docker Image Tag'){
            steps{
                sh 'docker tag $JOB_NAME:1.$BUILD_NUMBER mithunedappulath/$JOB_NAME:1.$BUILD_NUMBER'
                sh 'docker tag $JOB_NAME:1.$BUILD_NUMBER mithunedappulath/$JOB_NAME:latest'
            }
        }
        
        stage ('Docker-Image-Push'){
            steps{
                    withCredentials([usernamePassword(credentialsId: 'docker-login-edurekaproject', passwordVariable: 'docker-password', usernameVariable: 'docker-username')]) {
                        echo "username: ${env.docker-username}, password: ${env.docker-password}" 
                    }
                }
            }
        }
    }
}