variable "tfstate_bucket_name" {
  default = "services-terraform"
}
variable "cred_file" {
  default = "~/.aws/credentials"
}

variable "cred_profile" {
  default = "services"
}

variable "region" {
  default = "us-east-1"
}

variable "bucketeer_s3_access_key" {}
variable "bucketeer_s3_secret_key" {}
variable "bucketeer_s3_region" {}
variable "bucketeer_s3_bucket" {}
variable "services_docker_registry_username" {}
variable "services_dockerhub_password" {}
variable "services_dockerhub_username" {}