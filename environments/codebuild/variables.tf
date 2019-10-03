variable "region" { default = "us-east-1" }
variable "codebuild_project_name" {}
variable "codebuild_project_description" {}
variable "codebuild_project_timeout_minutes" {}
variable "codebuild_project_image" {}

variable "ssm_parameters_map" { type = map }

