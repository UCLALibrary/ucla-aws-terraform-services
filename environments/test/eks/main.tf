#### PUBLIC USED FOR LB AND NAT, PRIVATE USED FOR WORKER NODES
resource "aws_eks_cluster" "eks_cluster" {
  name = "${var.prefix_tag}_cluster"
  role_arn = data.terraform_remote_state.iam.outputs.test_eks_role_arn
  version = var.eks_version
  
  vpc_config {
    subnet_ids = concat(data.terraform_remote_state.vpc.outputs.eks_test_private_subnet_ids, data.terraform_remote_state.vpc.outputs.eks_test_public_subnet_ids)
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

resource "aws_eks_node_group" "main" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.prefix_tag}_main_nodegroup"
  node_role_arn = data.terraform_remote_state.iam.outputs.test_eks_nodegroup_role_arn
  subnet_ids = data.terraform_remote_state.vpc.outputs.eks_test_private_subnet_ids
  instance_types = var.nodegroup_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    max_size = var.node_max_size
    min_size = var.node_min_size
  }
}
