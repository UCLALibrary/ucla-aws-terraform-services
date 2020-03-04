### VPC Settings
vpc_tag_map = {
  "Name" = "Test-EKS-Network"
  "kubernetes.io/cluster/test-eks-cluster" = "shared"
}

k8s_subnet_tag_map = {
  "Name" = "Test-EKS-Network",
  "kubernetes.io/cluster/test-eks-cluster" = "shared",
  "kubernetes.io/role/elb" = "1"
}

default_tag = "Test-EKS-Network"
default_tag_map = {
  "Name" = "Test-EKS-Network",
}

