pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    withCredentials([usernamePassword(
                        credentialsId: 'aws-credentials',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )]) {
                        sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        terraform init
                        '''
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    withCredentials([usernamePassword(
                        credentialsId: 'aws-credentials',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )]) {
                        sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Generate Inventory') {
            steps {
                dir('terraform') {
                    sh '''
                    FRONTEND_IP=$(terraform output -raw frontend_public_ip)
                    BACKEND_IP=$(terraform output -raw backend_public_ip)

                    mkdir -p ../ansible

                    echo "[frontend]" > ../ansible/inventory.ini
                    echo "c8.local ansible_host=$FRONTEND_IP ansible_user=ec2-user" >> ../ansible/inventory.ini
                    echo "" >> ../ansible/inventory.ini
                    echo "[backend]" >> ../ansible/inventory.ini
                    echo "u21.local ansible_host=$BACKEND_IP ansible_user=ubuntu" >> ../ansible/inventory.ini
                    '''
                }
            }
        }

        stage('Run Ansible') {
            steps {
                withCredentials([file(credentialsId: 'ssh-key', variable: 'SSH_KEY')]) {
                    sh '''
                    chmod 400 $SSH_KEY
                    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --private-key $SSH_KEY
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline Success ✅'
        }
        failure {
            echo 'Pipeline Failed ❌'
        }
    }
}
