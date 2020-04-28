variable "aws_region" {
  type = string
  default = "us-west-2"
}

variable "node_desired_size" {
  type = number 
  default = 1
}

variable "node_max_size" {
  type = number
  default = 1
}

variable "node_min_size" {
  type = number
  default = 1
}

variable "eks_version" {
  type = number
  default = 1.15
}

variable "nodegroup_instance_types" {
  type = list(string)
  default = ["t3.micro"]
}

variable "prefix_tag" {
  type = string
  default = "eks"
}
