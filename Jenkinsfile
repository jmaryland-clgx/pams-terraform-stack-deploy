pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile'
			// ssh needed for tf-init to pull modules
        	// args '-v $HOME/.ssh:$HOME/.ssh:ro'
        }
    }
    stages {
        stage('Lint') {
            steps {
                sh 'terraform fmt -check'
                sh 'terraform init -input=false -backend=false' //dont try to connect to a backend yet
                sh 'terraform validate'
            }
        }
        stage('Sandbox') { // Deploy to default backend/state using default workspace
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
        stage('Prod') {  // Deploy to prod backend/state using prod workspace
            steps {
                sh 'replace me with prod credentials for GOOGLE_CREDENTIALS'
                sh 'terraform init -input=false -backend-config=prod.tfbackend' // use a production statefile
                sh 'terraform workspace select prod'
                sh 'terraform plan -input=false .terraform/plan' // optional: --var-file prod.tvars
                input "Deploy to prod?"
				sh 'echo "should run validator here. Terratest, inspec, terraform-compliance, etc"'
            }
        }
    }
}
