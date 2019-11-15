# Descriptions should always be provided for terraform-docs/terraform-config-inspect
variable "project" {
  type        = "map"
  description = "GCP project to use"

  default = {
    default = "dev GCP project ID"
    prod    = "prod GCP project ID"
  }
}

variable "region" {
  type        = "map"
  description = "GCP project to use"

  default = {
    default = "us-central1"
    prod    = "us-east1"
  }
}

variable "zone" {
  type        = "map"
  description = "GCP project to use"

  default = {
    default = "a"
    prod    = "b"
  }
}
