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

variable "cantaloupe_app_port" {
  default = 8182
}

variable "cantaloupe_latest_image" {
  default = "registry.hub.docker.com/uclalibrary/cantaloupe:latest"
}

variable "cantaloupe_endpoint_secret" {
  default = "changethissecret"
}