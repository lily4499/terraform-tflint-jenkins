pipeline {
    agent any
    parameters {
        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Choose the Terraform action to perform'
        )
    }
    environment {
        TF_VAR_ACCESS_KEY = credentials('aws-access-key-id')  // AWS Access Key
        TF_VAR_SECRET_KEY = credentials('aws-secret-access-key')  // AWS Secret Key
    }
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('Run TFLint') {
            steps {
                script {
                    try {
                        sh '''
                        echo "Initializing TFLint..."
                        tflint --init
                        echo "Running TFLint..."
                        tflint --format json > tflint-report.json
                        '''
                    } catch (Exception e) {
                        slackSend(channel: '#devops-project', message: "TFLint detected issues in Terraform code!")
                        error "TFLint failed. Please fix the issues before proceeding."
                    }
                }
            }
        }
        stage('Publish TFLint Report') {
            steps {
                script {
                    recordIssues tools: [tflint(pattern: 'tflint-report.json')]
                }
            }
        }
        stage('Initialize Terraform') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Plan Terraform') {
            steps {
                script {
                    if (params.ACTION == 'apply') {
                        sh 'terraform plan -out=tfplan'
                    } else if (params.ACTION == 'destroy') {
                        sh 'terraform plan -destroy -out=tfplan'
                    }
                }
            }
        }
        stage('Execute Terraform Action') {
            steps {
                script {
                    if (params.ACTION == 'apply') {
                        sh 'terraform apply -input=false tfplan'
                    } else if (params.ACTION == 'destroy') {
                        sh 'terraform apply -input=false tfplan'
                    }
                }
            }
        }
    }
    post {
        always {
            echo 'Cleaning up workspace...'
            deleteDir()
        }
        success {
            script {
                if (params.ACTION == 'apply') {
                    slackSend(channel: '#devops-project', message: "Terraform apply executed successfully!")
                } else if (params.ACTION == 'destroy') {
                    slackSend(channel: '#devops-project', message: "Terraform destroy executed successfully!")
                }
            }
        }
        failure {
            script {
                if (params.ACTION == 'apply') {
                    slackSend(channel: '#devops-project', message: "Terraform apply failed!")
                } else if (params.ACTION == 'destroy') {
                    slackSend(channel: '#devops-project', message: "Terraform destroy failed!")
                }
            }
        }
    }
}

