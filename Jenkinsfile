pipeline {
    agent any

    environment {
        TF_DIR = "terraform"
        ANSIBLE_DIR = "ansible"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Generate Inventory') {
            steps {
                dir("${TF_DIR}") {
                    sh '''
                    FRONTEND_IP=$(terraform output -raw frontend_public_ip)
                    BACKEND_IP=$(terraform output -raw backend_public_ip)

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
                withCredentials([file(credentialsId: 'ssh-key-file', variable: 'SSH_KEY')]) {
                    sh '''
                    chmod 400 $SSH_KEY
                    ansible-playbook -i ansible/inventory.ini ansible/playbook.yml \
                    --private-key $SSH_KEY
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Deployment Successful 🚀"
        }
        failure {
            echo "Pipeline Failed ❌"
        }
    }
}
