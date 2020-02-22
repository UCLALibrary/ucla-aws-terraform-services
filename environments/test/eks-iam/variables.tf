# AWS Config Variables
variable "aws_region" {
    default = "us-west-2"
}

variable "aws_profile" {
    default = "default"
}

variable "eks_iam_policy_attachment_service_arn" {
 default = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

variable "eks_iam_policy_attachment_cluster_arn" {
 default = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

