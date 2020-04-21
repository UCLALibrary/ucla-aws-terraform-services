variable "aws_region" {
  type = string
  default = "us-west-2"
}

variable "vpc_main_cidr_block" {
  type = string
  default = "172.16.0.0/16"
}

variable "eks_prod_public_subnets" {
  type = list(string)
  default = []
}

variable "eks_test_public_subnets" {
  type = list(string)
  default = []
}

variable "eks_prod_private_subnets" {
  type = list(string)
  default = []
}

variable "eks_test_private_subnets" {
  type = list(string)
  default = []
}

variable "lambda_prod_private_subnets" {
  type = list(string)
  default = []
}

variable "lambda_test_private_subnets" {
  type = list(string)
  default = []
}

variable "gp_public_subnets" {
  type = list(string)
  default = []
}

variable "uclavpn_ingress_allowed" {
  type = list(string)
  default = []
}

variable "public_http_ports" {
  type = list(number)
  default = []
}

variable "uclalibrary_ingress_allowed" {
  type = list(string)
  default = []
}
