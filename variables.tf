# Descriptions should always be provided for terraform-docs/terraform-config-inspect
variable "project" {
  type        = "map"
  description = "GCP project ID to target per workspace"

  default = {
    default = "rmeis-test-staging-tf"
    prod    = "rmeis-test-prod-tf"
  }
}

variable "region" {
  type        = "map"
  description = "GCP default region per workspace"

  default = {
    default = "us-central1"
    prod    = "us-east1"
  }
}

variable "zone" {
  type        = "map"
  description = "GCP default AZ per workspace"

  default = {
    default = "a"
    prod    = "b"
  }
}
