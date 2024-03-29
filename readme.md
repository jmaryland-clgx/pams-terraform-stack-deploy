# Terraform Stack Deploy

Opinionated stack deployment for use with Jenkins CI/CD (Atlantis incoming). Based on best practices recommended by hashicorp/terraform.

Feel free to use this as a starting point for new deployments and projects.

## Quickstart for a new project

1. Download or fork this repo. Cloning is not recommended as that will already have git configuration.
1. Replace terraform backend config in main.tf with lowest level environment config. For example, dev or sandbox. local deployments should be acceptable here.
1. Add or edit the \*.tfbackend files to fit your needs for higher level environments. For example, staging, UAT, production, DR. Anywhere that local deploys are not acceptable.
1. Edit the various \*.tf files to fit your project needs.
1. `terraform init`
1. `terraform plan -out .terraform/plan` # Generate and store plan locally.
1. `terraform apply .terraform/plan` # Apply generated plan to a shared development environment with dev settings.
1. (Optional) Edit Jenkinsfile to fit your CI/CD strategy.
1. (Optional, repeat per target environment beyond shared dev)

   ```bash
   rm -rf .terraform;
   terraform init -backend-config=higherlevel.tfbackend
   terraform workspace new higherlevel
   ```

1. if CI/CD is configured, it will deploy to higher level environments with different backends and explicitly set workspaces.

## Common developer workflow for project deployments

1. Create a new feature branch
1. (Optional) create or select a personal workspace instead of default. Example: `terraform workspace new phillipfry` OR `terraform workspace select phillipfry`
1. Add/Edit \*.tf files
1. `terraform init`
1. `terraform plan -out .terraform/plan`
1. Review generated plan.
1. `terraform apply .terraform/plan`
1. Run validators(kitchen-ci, terratest, etc.)
1. git commit
1. git push
1. Open merge-request or pull-request and ask for team review of proposed(and tested) changes.

## Environment separation strategy

We recommend separating environments in using 2 terraform techniques. Workspaces, and backends.

### Terraform workspace separation

Terraform workspaces use the same backend and state file but track entirely separate copies of the defined resources. If you don't specify a workspace with `terraform workspace new` or `terraform workspace select` commands then you are operating on the "default" workspace.

For example, we have a project "planet-express" with one backend named "planet-express-state-storage-bucket". We init -> plan -> apply our terraform and are serving planet-express in the cloud on the default workspace. Now we want to add some features, but we don't want to impact our first deployment yet. We can use `terraform workspace new Phillip_Fry` then plan -> apply will not be aware of our default workspace resources at all, and will create an entirely new service for us.

We can make a separate workspace for each shared environment, developer, or any other separation that makes sense for your project.

We can also use the workspace names to help keep most of our terraform variables dry and predictable using lookup functions, look to variables.tf for examples.

### Terraform backend separation

Workspaces help us create similar or exact copies of infrastructure, but in an ideal world as few developers as possible should be touching production. In fact a popular goal is to deliver to production only through automation and service accounts.

To aid in this objective we can further separate access and environments by dynamically changing the backend for terraform state.

For example we can give all project developers access to test and apply terraform in the "planet-express-dev" backend, but we can have another "planet-express-prod" that only our CI/CD server has access to write to.

We can store the configuration for these higher level backends in a git tracked file. In this repository we include a "prod.tfbackend" file that is used in CI/CD for this purpose.

### Combining workspaces and backends

By combining both workspaces and backends we have a secure and predictable pipeline to deliver infrastructure as code. We are also still enabling local testing by various team members without fear of constant resource collision.

The default workspace for the default backend should be considered a "shared dev" environment in most cases.

In higher level environments with specified backends it is not recommended to use the "default" workspace because that can make variable interpolation more complicated in the terraform code.

For example, when switching to prod.tfbackend you should also switch to the prod workspace with `terraform workspace select prod` so that all of the correct production values are applied, instead of "default" workspace values for that backend.

Luckily with this pattern in use, a deployment to "default" workspace in "prod" backend would only create new and separate resources with development values. In almost all cases this would not cause an outage but it would be a waste of money and would require cleanup.

## Local testing requirements

- Terraform

## Jenkins CI/CD testing requirements

- docker
- Jenkins or cloud bees Jenkins distribution(free license required) docker images
- Install docker in container and mount the docker sock to emulate docker in docker
- ssh key for Jenkins to read checkout root repo and private terraform module dependencies

## Jenkins configuration walkthrough

### Setup ssh auth for terraform private modules

1. <http://$JENKINS_URL/credentials/store/system/domain/_/newCredentials>
1. Kind: SSH Username with private key
1. Scope: Global
1. Fill the other fields as desired
1. Edit the jenkinsfile "sshagent" section/s to match your key values

### Setup GCP Authentication

1. <http://$JENKINS_URL/credentials/store/system/domain/_/newCredentials>
1. Kind: Secret File
1. Scope: Global
1. Fill the other fields as desired
1. Edit the jenkinsfile "withCredentials" sections to match your key values

## Documentation sources

- <https://www.terraform.io/docs/commands/init.html>
- <https://learn.hashicorp.com/terraform/development/running-terraform-in-automation>

## Optional Jenkinsfile.alt

This is not suggested for most teams as it allows for far more human error(copy-paste, fatfingering, etc). Teams using this option will need to set strict rules and expectations about how deployments should be handled/approved for all environments. Some of it can be codified using "script" syntax(example is present in Jenkinsfile.alt and commented out)

You can use an alternate jenkinsfile by overwriting Jenkinsfile with Jenkinsfile.alt.

This option is useful for teams who want any commit(to any branch) to be deployable to any environment through a bit of manual work on Jenkins.

This guarantees that "the same terraform code" that was applied in staging can be applied in production on demand. Regardless of source branch or possible git merge issues.

Default parameters should be set to deploy to a shared development environment or sandbox account. Higher level builds should be "rebuilt" with new parameters by the appropriate engineers.

The "https://wiki.jenkins.io/display/JENKINS/Rebuild+Plugin" is required to help with these "rebuild with new parameters" activities from the Jenkins GUI.

To Rerun a build with new parameters go to http://$JENKINS_URL/job/$PIPELINE_NAME/job/$BUILD_NAME/$BUILD_ID/rebuild/parameterized
