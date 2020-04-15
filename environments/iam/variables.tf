variable "aws_region" {
  type = string
  default = "us-west-2"
}

variable "terraform_state_lock_table" {
  type = string
  default = "dynamodb_state_lock_table"
}

variable "terraform_state_bucket" {
  type = string
  default = "s3_state_bucket"
}

variable "eks_deployment_robot_name" {
  type = string
  default = "eks-deployment-robot"
}

variable "prefix_tag" {
  type = string
  default = "terraform"
}
