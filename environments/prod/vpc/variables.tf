variable "cred_file" {
  default = "~/.aws/credentials/"
}

variable "cred_profile" {
  default = "default"
}

variable "region" {
  default = "us-west-2"
}

variable "vpc_cidr_block" {
  default = "172.20.0.0/16"
}

variable "subnet_count" {
  default = 2
}
