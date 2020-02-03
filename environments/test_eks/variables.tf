# AWS Config Variables
variable "aws_region" {
    default = "us-west-2"
}

variable "aws_profile" {
    default = "cachemeoutside"
}

# AWS Availability Zones
variable "us-west-2_az" {
    default = [
        "us-west-2a",
        "us-west-2b",
        "us-west-2c",
        "us-west-2d"
    ]
}

variable "us-east-1_az" {
    default = [
        "us-east-1a",
        "us-east-1b",
        "us-east-1c",
        "us-east-1d",
        "us-east-1e",
        "us-east-1f"
    ]
}

variable "eks_vpc_network" {
    default = "172.10.0.0/16"
}
variable "eks_subnets" {
    default = [
        "172.10.11.0/24",
        "172.10.12.0/24",
        "172.10.13.0/24",
        "172.10.14.0/24"
    ]
}

variable "eks_iam_policy_attachment_service_arn" {
    default = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

variable "eks_iam_policy_attachment_cluster_arn" {
    default = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

variable "node_desired_size" {
    default = 1
}

variable "node_max_size" {
    default = 1
}

variable "node_min_size" {
    default = 1
}

locals {
  hosted_az = "${var.aws_region == "us-west-2" ? var.us-west-2_az : var.us-east-1_az}"
}

