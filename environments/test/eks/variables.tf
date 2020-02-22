### AWS Config Variables
variable "aws_region" {
    default = "us-west-2"
}

variable "aws_profile" {
    default = "default"
}


### Authentication variables to access remote VPC workspace
variable "terraform_remote_hostname" { default = "app.terraform.io" }
variable "terraform_remote_token" {}
variable "terraform_remote_organization" {}
variable "terraform_remote_networking_workspace" {}
variable "terraform_remote_iam_workspace" {}

variable "node_desired_size" {
 default = 1
}

variable "node_max_size" {
 default = 1
}

variable "node_min_size" {
  default = 1
}

