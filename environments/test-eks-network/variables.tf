variable "cred_file" {
  default = "~/.aws/credentials/"
}

variable "cred_profile" {
  default = "cachemeoutside"
}

variable "region" {
  default = "us-west-2"
}

variable "default_tag" {
  default = "Test-EKS-Network"
}

variable "vpc_cidr_block" {
  default = "172.50.0.0/16"
}

variable "public_subnet_count" {
  default = 3
}
variable "public_subnet_int" {
  default = 10
}
variable "private_subnet_count" {
  default = 3
}
variable "private_subnet_int" {
  default = 100
}
variable "enable_nat" {
  default = 1
}

