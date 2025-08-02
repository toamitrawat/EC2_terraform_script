// Jenkinsfile for Terraform-based EC2 provisioning via Jenkins
// Place this Jenkinsfile at the root of your Terraform repository

pipeline {
agent {
// Use a Docker image that has Terraform and AWS CLI pre-installed
docker {
image 'hashicorp/terraform:1.5.0'
args  '--entrypoint=/bin/sh'
}
}
environment {
// Jenkins-managed credentials (AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY)
AWS_CREDENTIALS = credentials('aws-eks-creds')
AWS_DEFAULT_REGION = 'ap-south-1'
TF_VAR_key_name     = 'dev-ec2-keypair'
TF_VAR_tag_owner    = 'dev-team@example.com'
}
parameters {
// Git repository and branch parameters
string(name: 'GIT_REPO_URL', defaultValue: 'https://github.com/toamitrawat/EC2_terraform_script.git', description: 'Git repository URL containing Terraform code')
string(name: 'GIT_BRANCH', defaultValue: 'main', description: 'Branch to checkout')
booleanParam(name: 'AUTO_APPROVE', defaultValue: false, description: 'Automatically apply changes?')
}
stages {
stage('Checkout') {
steps {
// Clone Terraform code from Git
git(
url: params.GIT_REPO_URL,
branch: params.GIT_BRANCH,
credentialsId: 'github-pat'
)
}
}
stage('Terraform Init') {
steps {
sh '''
export AWS_ACCESS_KEY_ID=${AWS_CREDENTIALS_USR}
export AWS_SECRET_ACCESS_KEY=${AWS_CREDENTIALS_PSW}
terraform init -input=false
'''
}
}
export AWS_SECRET_ACCESS_KEY=${AWS_CREDENTIALS_PSW}
terraform init -input=false
'''
}
}
stage('Terraform Plan') {
steps {
sh '''
export AWS_ACCESS_KEY_ID=${AWS_CREDENTIALS_USR}
export AWS_SECRET_ACCESS_KEY=${AWS_CREDENTIALS_PSW}
terraform plan -out=tfplan -var aws_region=${AWS_DEFAULT_REGION} -var key_name=${TF_VAR_key_name} -var tag_owner='${TF_VAR_tag_owner}'
'''
archiveArtifacts artifacts: 'tfplan', fingerprint: true
}
}
stage('Terraform Apply') {
when {
expression { return params.AUTO_APPROVE == true }
}
steps {
input message: 'Approve Terraform Apply?', ok: 'Apply'
sh '''
export AWS_ACCESS_KEY_ID=${AWS_CREDENTIALS_USR}
export AWS_SECRET_ACCESS_KEY=${AWS_CREDENTIALS_PSW}
terraform apply -input=false tfplan
'''
}
}
stage('Outputs') {
steps {
sh '''
export AWS_ACCESS_KEY_ID=${AWS_CREDENTIALS_USR}
export AWS_SECRET_ACCESS_KEY=${AWS_CREDENTIALS_PSW}
terraform output
'''
}
}
}
post {
always {
cleanWs()
}
}
}

