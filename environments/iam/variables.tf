variable "aws_region" {
  default = "us-west-2"
}

variable "eks_deployment_robot_name" {
  type = string
  default = "eks-deployment-robot"
}

variable "prefix_tag" {
  type = string
  default = "terraform"
}
