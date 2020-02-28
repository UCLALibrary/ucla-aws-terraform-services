terraform {
  required_version = "~> 0.12.20"
  backend "remote" {}
}

provider "aws" {
  profile          = var.aws_profile
  region           = var.aws_region
}

data "aws_iam_policy_document" "eks_assume_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
 
    principals {
      type = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_for_eks" {
  name = "test-eks"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_policy_document.json
} 

resource "aws_iam_role_policy_attachment" "eks_attach_service_policy" {
  role = aws_iam_role.iam_for_eks.name
  policy_arn = var.eks_iam_policy_attachment_service_arn
}

resource "aws_iam_role_policy_attachment" "eks_attach_cluster_policy" {
  role = aws_iam_role.iam_for_eks.name
  policy_arn = var.eks_iam_policy_attachment_cluster_arn
}

resource "aws_iam_role" "iam_for_eks_node_group" {
  name = "nodegroup_test-eks"

  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "iam_for_eks_node_group-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.iam_for_eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "iam_for_eks_node_group-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.iam_for_eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "iam_for_eks_node_group-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.iam_for_eks_node_group.name
}

resource "aws_iam_policy" "alb_ingress_policy" {
  name = "Test-EKS-ALBIngressController"
  policy = file("policies/ALBIngressController.json")
}

resource "aws_iam_role_policy_attachment" "iam_for_alb_ingress" {
  policy_arn = aws_iam_policy.alb_ingress_policy.arn
  role = aws_iam_role.iam_for_eks.name
}

