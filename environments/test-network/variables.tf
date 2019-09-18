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

variable "public_subnet_count" {}
variable "public_subnet_int" {}     
variable "private_subnet_count" {}
variable "private_subnet_int" {}
variable "vpc_endpoint" {}              
variable "create_vpc_endpoint" {}          
variable "enable_nat" {}
variable "global_egress_name" {}

variable "vpc_main_id" {
  default = null
}

