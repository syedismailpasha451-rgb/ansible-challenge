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
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {

                        sh '''
                        terraform init
                        '''
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {

                        sh '''
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

                    cat > ../ansible/inventory.ini <<EOF
[frontend]
c8.local ansible_host=$FRONTEND_IP ansible_user=ec2-user

[backend]
u21.local ansible_host=$BACKEND_IP ansible_user=ubuntu
EOF
                    '''
                }
            }
        }

        stage('Run Ansible') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'ec2-ssh-key',
                    keyFileVariable: 'SSH_KEY'
                )]) {
                    sh '''
                    chmod 400 $SSH_KEY
                    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
                    -i ansible/inventory.ini \
                    ansible/playbook.yml \
                    --private-key $SSH_KEY
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline Success ✅"
        }
        failure {
            echo "Pipeline Failed ❌"
        }
    }
}
