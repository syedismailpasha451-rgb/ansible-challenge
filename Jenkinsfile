pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        TF_DIR = "terraform"
        ANSIBLE_DIR = "ansible"
        SSH_KEY = credentials('ec2-ssh-key')   // Jenkins stored SSH key
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/syedismailpasha451-rgb/ansible-challenge.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform validate'
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

        stage('Generate Ansible Inventory') {
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

        stage('Run Ansible Playbook') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh '''
                    ansible-playbook -i inventory.ini playbook.yml \
                    --private-key ${SSH_KEY}
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Infrastructure deployed and configured successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs."
        }
    }
}
