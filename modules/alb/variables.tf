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

variable "app_name" {
  default = "app"
}

variable "vpc_main_id" {
  default = null
}

variable "vpc_subnet_ids" {
  default = null
}
