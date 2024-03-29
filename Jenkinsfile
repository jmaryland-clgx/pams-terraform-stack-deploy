#!/usr/bin/env groovy
pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile'
            additionalBuildArgs "--build-arg terraform_version=0.11.14"
        }
    }
    //environment {
    //    // evaluate use of:
    //    // TF_IN_AUTOMATION = 'true'
    //}
    stages {
        stage('Lint') {
            steps {
                sh 'terraform version'
                sh 'terraform fmt -check' // fail build on lint corrections
                sshagent(['testauth']) {
                    sh 'echo SSH_AUTH_SOCK=$SSH_AUTH_SOCK'
                    sh 'ls -al $SSH_AUTH_SOCK || true'
                    sh 'ssh -vvv -o StrictHostKeyChecking=no git.epam.com uname -a || true'
                    sh 'terraform init -input=false -backend=false' //dont try to connect to a backend yet
                }
                sh 'terraform validate'
                sh 'rm -rf .terraform' // cleanup
            }
        }
        stage('Sandbox') { // Deploy to default backend/state using default workspace
            //when {
            //    branch 'develop' // Optional for git flow
            //}
            steps {
                withCredentials([file(credentialsId: 'gcp_creds_test_auth', variable: 'GOOGLE_CREDENTIALS')]) {
                    sshagent(['testauth']) {
                        sh 'echo SSH_AUTH_SOCK=$SSH_AUTH_SOCK'
                        sh 'ls -al $SSH_AUTH_SOCK || true'
                        sh 'ssh -vvv -o StrictHostKeyChecking=no git.epam.com uname -a || true'
                        sh 'terraform init -input=false'
                    }
                    sh 'terraform workspace select default' // or sandbox, dev, etc.
                    sh 'terraform plan -input=false -out=.terraform/plan' // optional: --var-file sandbox.tvars
                    // input "Deploy to sandbox?"
                    sh 'terraform apply -input=false .terraform/plan'
                    sh 'echo "should run validator here. Terratest, inspec, terraform-compliance, etc"'
                    sh 'rm -rf .terraform' // cleanup
                }
            }
        }
        stage('Prod') {  // Deploy to prod backend/state using prod workspace
            when {
                branch 'master'
            }
            steps {
                withCredentials([file(credentialsId: 'gcp_creds_test_auth', variable: 'GOOGLE_CREDENTIALS')]) {
                    sshagent(['testauth']) {
                        sh 'echo SSH_AUTH_SOCK=$SSH_AUTH_SOCK'
                        sh 'ls -al $SSH_AUTH_SOCK || true'
                        sh 'ssh -vvv -o StrictHostKeyChecking=no git.epam.com uname -a || true'
                        sh 'terraform init -input=false -backend-config=prod.tfbackend' // use a production statefile
                    }
                    sh 'terraform workspace select prod'
                    sh 'terraform plan -input=false -out=.terraform/plan' // optional: --var-file prod.tvars
                    input "Deploy to prod?"
                    sh 'terraform apply -input=false .terraform/plan'
                    sh 'echo "should run validator here. Terratest, inspec, terraform-compliance, etc"'
                }
            }
        }
    }
}
