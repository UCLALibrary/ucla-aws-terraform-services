variable "region" { default = "us-east-1" }
variable "codebuild_project_name" {}
variable "codebuild_project_description" {}
variable "codebuild_project_timeout_minutes" {}
variable "codebuild_project_image" {}

variable "ssm_parameters_map" { type = map }
variable "secure_ssm_parameters_map" { type = map }

locals {
  ssm_parameters_merged = merge("${var.ssm_parameters_map}", "${var.secure_ssm_parameters_map}")
}

