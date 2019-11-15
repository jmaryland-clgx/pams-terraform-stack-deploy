pipeline {
    agent {
        docker {
            image 'hashicorp/terraform:0.11.14'
            // ssh needed for tf-init to pull modules
            // workspace is for convenience
            // setting bash as default command to allow for different runtime environment changes
            args '-it -v $HOME/.ssh:$HOME/.ssh:ro -w /workspace -v $(pwd):/workspace --entrypoint sh'
        }
    }
    stages {
        stage('Lint') {
            steps {
                sh 'echo hello'
                sh 'terraform fmt'
                sh 'terraform init -input=false -backend=false' //dont try to connect to a backend yet
                sh 'terraform validate'
            }
        }
        stage('Sandbox') { // Deploy with default workspace in default environment
            steps {
                sh 'replace me with default credentials for GOOGLE_CREDENTIALS'
                // or GOOGLE_CLOUD_KEYFILE_JSON
                // or  GCLOUD_KEYFILE_JSON
                // or GOOGLE_APPLICATION_CREDENTIALS'
                sh 'terraform init -input=false'
                sh 'terraform workspace select default' // or sandbox, dev, etc.
                sh 'terraform plan -input=false .terraform/plan'
                sh 'terraform apply -input=false .terraform/plan'
                sh 'echo "should run validator here. Terratest, inspec, terraform-compliance, etc"'
            }
        }
        ////Pipeline: Input Step. https://plugins.jenkins.io/pipeline-input-step
        //stage('Prod Deploy Approval') {
        //    input "Deploy to prod?"
        //}
        stage('Prod') { // deploy to production workspace
            steps {
                sh 'replace me with prod credentials for GOOGLE_CREDENTIALS'
                sh 'terraform init -input=false -backend-config=prod.tfbackend' // use a production statefile
                sh 'terraform workspace select prod'
                sh 'terraform plan -input=false .terraform/plan' // optional: --var-file prod.tvars
                sh 'echo "should run validator here. Terratest, inspec, terraform-compliance, etc"'
            }
        }
    }
}
