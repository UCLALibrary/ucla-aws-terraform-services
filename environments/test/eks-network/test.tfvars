### VPC Settings
vpc_tag_map = {
  "Name" = "Test-EKS-Network"
  "kubernetes.io/cluster/eks_cluster" = "shared"
}

k8s_subnet_tag_map = {
  "Name" = "Test-EKS-Network",
  "kubernetes.io/cluster/eks_cluster" = "shared"
}

default_tag = "Test-EKS-Network"
default_tag_map = {
  "Name" = "Test-EKS-Network",
}

