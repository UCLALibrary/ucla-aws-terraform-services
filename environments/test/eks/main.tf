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
  name = "test-iiif-cluster"
  role_arn = data.terraform_remote_state.iam.outputs.eks_role_arn
  version = var.eks_version
  
  vpc_config {
    subnet_ids = data.terraform_remote_state.vpc.outputs.vpc_private_subnet_ids
  }
}

# This data requires OpenSSL and tac installed on the runner
data "external" "eks_oidc_thumbprint" {
  program = ["bash", "./helpers/oidc-thumbprint.sh", var.aws_region]
}

resource "aws_iam_openid_connect_provider" "eks_openid_connect" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.eks_oidc_thumbprint.result.thumbprint]
  url             = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}

resource "aws_eks_node_group" "gp_eks_nodegroup" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_group_name = "gp-test-iiif"
  node_role_arn = data.terraform_remote_state.iam.outputs.eks_nodegroup_role_arn
  subnet_ids = data.terraform_remote_state.vpc.outputs.vpc_private_subnet_ids
  instance_types = ["m5.large"]

  scaling_config {
    desired_size = var.node_desired_size
    max_size = var.node_max_size
    min_size = var.node_min_size
  }
}

resource "aws_iam_policy" "alb_ingress_policy" {
  name = "Test-EKS-ALBIngressController"
  policy = file("policies/ALBIngressController.json")
}

resource "aws_iam_role" "alb_ingress_role" {
  name = "TestALBIngressRole"
  assume_role_policy =  templatefile("policies/oidc_assume_role_policy.json.template", { OIDC_ARN = aws_iam_openid_connect_provider.eks_openid_connect.arn, OIDC_URL = replace(aws_iam_openid_connect_provider.eks_openid_connect.url, "https://", ""), NAMESPACE = "kube-system", SA_NAME = "alb-ingress-controller" })
}

resource "aws_iam_role_policy_attachment" "iam_attach_alb_ingress" {
  policy_arn = aws_iam_policy.alb_ingress_policy.arn
  role       = aws_iam_role.alb_ingress_role.name
}

