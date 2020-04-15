variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "iiif_k8s_ssm_parameters_map" {
  type = map
  default = {}
}

variable "iiif_k8s_secure_ssm_parameters_map" {
  type = map
  default = {}
}

variable "dockerhub_secure_ssm_parameters_map" {
  type = map
  default = {}
}

locals {
  iiif_k8s_ssm_parameters_merged = merge("${var.iiif_k8s_ssm_parameters_map}", "${var.iiif_k8s_secure_ssm_parameters_map}", "${var.dockerhub_secure_ssm_parameters_map}")
}
