terraform {
  required_version = "~> 0.12.20"
  backend "remote" {}
}

### Retrieve VPC and subnet resources from network workspace
data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    hostname = var.terraform_remote_hostname
    token = var.terraform_remote_token
    organization = var.terraform_remote_organization
    workspaces = {
      name = var.terraform_remote_networking_workspace
    }
  }
}

### Retrieve IAM resources from IAM workspace
data "terraform_remote_state" "iam" {
  backend = "remote"
  config = {
    hostname = var.terraform_remote_hostname
    token = var.terraform_remote_token
    organization = var.terraform_remote_organization
    workspaces = {
      name = var.terraform_remote_iam_workspace
    }
  }
}


provider "aws" {
  profile          = var.aws_profile
  region           = var.aws_region
}

resource "aws_eks_cluster" "eks_cluster" {
  name = "eks_cluster"
  role_arn = data.terraform_remote_state.iam.outputs.eks_role_arn
  
  vpc_config {
    subnet_ids = data.terraform_remote_state.vpc.outputs.vpc_private_subnet_ids
  }
}

resource "aws_eks_node_group" "gp_eks_nodegroup" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_group_name = "gp-test-eks"
  node_role_arn = data.terraform_remote_state.iam.outputs.eks_nodegroup_role_arn
  subnet_ids = data.terraform_remote_state.vpc.outputs.vpc_private_subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    max_size = var.node_max_size
    min_size = var.node_min_size
  }
}

