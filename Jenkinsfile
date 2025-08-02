pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        TF_VAR_key_name    = 'dev-ec2-keypair'
        TF_VAR_tag_owner   = 'dev-team@example.com'
    }

    parameters {
        string(name: 'GIT_REPO_URL', defaultValue: 'https://github.com/toamitrawat/EC2_terraform_script.git', description: 'Git repository URL containing Terraform code')
        string(name: 'GIT_BRANCH', defaultValue: 'main', description: 'Branch to checkout')
        booleanParam(name: 'AUTO_APPROVE', defaultValue: false, description: 'Automatically apply changes?')
    }

    stages {
        stage('Checkout') {
            steps {
                git(
                    url: params.GIT_REPO_URL,
                    branch: params.GIT_BRANCH,
                    credentialsId: 'github-pat'
                )
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-eks-creds']]) {
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-eks-creds']]) {
                    sh """
                    terraform plan -out=tfplan \\
                        -var aws_region=${AWS_DEFAULT_REGION} \\
                        -var key_name=${TF_VAR_key_name} \\
                        -var tag_owner=${TF_VAR_tag_owner}
                    """
                }
                archiveArtifacts artifacts: 'tfplan', fingerprint: true
            }
        }

        stage('Terraform Apply') {
            when {
                expression { return params.AUTO_APPROVE == true }
            }
            steps {
                script {
                    input message: 'Approve Terraform Apply?', ok: 'Apply'
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-eks-creds']]) {
                        try {
                            sh 'terraform apply -input=false tfplan'
                        } catch (err) {
                            echo 'Terraform apply failed. Attempting cleanup with destroy...'
                            sh '''
                            terraform destroy -auto-approve \
                                -var aws_region=${AWS_DEFAULT_REGION} \
                                -var key_name=${TF_VAR_key_name} \
                                -var tag_owner=${TF_VAR_tag_owner}
                            '''
                            error("Terraform apply failed. Resources have been destroyed.")
                        }
                    }
                }
            }
        }

        stage('Terraform Output') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-eks-creds']]) {
                    sh 'terraform output'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
