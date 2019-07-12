variable "tfstate_bucket_name" {
  default = "services-terraform"
}
variable "cred_file" {
  default = "~/.aws/credentials/"
}

variable "cred_profile" {
  default = "default"
}

variable "region" {
  default = "us-west-2"
}

variable "privateflag" {
  default = 0
}

variable "cantaloupe_stable_app_port" {
  default = 8182
}

variable "cantaloupe_latest_image" {
  default = "registry.hub.docker.com/uclalibrary/cantaloupe:latest"
}

variable "cantaloupe_stable_image" {
  default = "registry.hub.docker.com/uclalibrary/cantaloupe:4.1.1"
}

variable "cantaloupe_endpoint_secret" {
  default = "changethissecret"
}

variable "cantaloupe_stable_app_count" {
  default = 1
}
