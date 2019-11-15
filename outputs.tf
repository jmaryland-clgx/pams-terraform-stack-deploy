# Descriptions should always be provided for terraform-docs/terraform-config-inspect
# All outputs defined here will be shown at the end of a terraform plan/apply run.
output "bucket_URL" {
  description = "URL of the bucket created by terraform"
  value       = "${module.simple_bucket.bucket_URL}"
}
