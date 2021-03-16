pipeline {
    agent any
        stages{
        stage('INIT'){
            steps{
                sh 'cd ./gcpinst && sudo terraform init'
            }
        }
        stage('plan'){
            steps{
                sh 'cd ./gcpinst && sudo terraform plan'
            }
        }
        stage('apply'){
            steps{
                sh 'cd ./gcpinst && sudo terraform apply --auto-approve'
            }
        }
        stage('fix hosts file'){
            steps{
                sh 'cd /home/s4nl3d3/qwe && sudo sed -i -e "s/^.*[1-255].*$/gcp_instance_ip/g" inventory/hosts'
            }
        }
    }
}