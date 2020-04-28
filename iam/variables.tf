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

variable "eks_iam_policy_attachment_service_policy_arn" {
  type = string
  default = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

variable "eks_iam_policy_attachment_cluster_policy_arn" {
  type = string
  default = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

variable "eks_nodegroup_iam_policy_attachment_workernode_policy_arn" {
  type = string
  default = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

variable "eks_nodegroup_iam_policy_attachment_cni_policy_arn" {
  type = string
  default = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

variable "eks_nodegroup_iam_policy_attachment_ecr_policy" {
  type = string
  default = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
