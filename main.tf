terraform {
  # Define minimum terraform version to use when developing/deploying this stack
  required_version = "~> 0.11.4"

  # Providers allow us to affect the public clouds, versioning allows us to avoid breaking implementation changes
  required_providers {
    google      = "~> 2.19.0"
    google-beta = "~> 2.19.0"
  }

  # Setup backend for remote state and locking helping with multiple developer teams
  backend "gcs" {
    # CI/CD can manage higher level environment backends. staging, uat, prod, etc. "terraform init -backend-config=..."
    # https://www.terraform.io/docs/backends/config.html#partial-configuration
    # We manage higher level backends in *.tfbackend files listed in root with override values
    bucket = "rmeis-test-staging-tf" # REPLACE ME WITH VALID BUCKET

    prefix = "myTerraformProjectName" # REPLACE ME WITH APPROPRIATE PROJECT NAME
  }
}

locals {
  # Use terraform workspace name to automatically select values from variables.
  # If value is undefined for your workspace the default variable from the map will be used.
  # Only works on strings. Must use .tfvars for more complex types.
  selected_project = "${lookup(var.project, terraform.workspace, var.project["default"])}"

  selected_region = "${lookup(var.region, terraform.workspace, var.region["default"])}"
  selected_zone   = "${local.selected_region}-${lookup(var.zone, terraform.workspace, var.zone["default"])}" # Combine region and zone. Ex. us-central1-a
}

provider "google" {
  project = "${local.selected_project}"
  region  = "${local.selected_region}"
  zone    = "${local.selected_zone}"
}

provider "google-beta" {
  project = "${local.selected_project}"
  region  = "${local.selected_region}"
  zone    = "${local.selected_zone}"
}

module "simple_bucket" {
  # Note ?ref= can be followed by a git tag, branch name, or commit hash
  source = "git::ssh://git@git.epam.com/epm-gcp/terraform/terraform_reference_module.git?ref=v0.0.2"

  bucket             = "test-bucket"
  random_bucket_name = true
  force_destroy      = true
}
