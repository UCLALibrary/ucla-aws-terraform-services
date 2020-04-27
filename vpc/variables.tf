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

variable "iiif_nat_egress_list" {
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "vpc_tag" {
  type = map
  default = {
    "Name" = "iiif-main"
  }
}

variable "prod_eks_public_vpc_tag" {
  type = map
  default = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/prod-services_cluster" = "shared"
  }
}

variable "test_eks_public_vpc_tag" {
  type = map
  default = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/test-services_cluster" = "shared"
  }
}

variable "prod_eks_private_vpc_tag" {
  type = map
  default = {
    "kubernetes.io/cluster/prod-services_cluster" = "shared"
  }
}

variable "test_eks_private_vpc_tag" {
  type = map
  default = {
    "kubernetes.io/cluster/test-services_cluster" = "shared"
  }
}
