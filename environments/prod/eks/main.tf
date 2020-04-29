#### PUBLIC USED FOR LB AND NAT, PRIVATE USED FOR WORKER NODES
resource "aws_eks_cluster" "eks_cluster" {
  name = "${var.prefix_tag}_cluster"
  role_arn = data.terraform_remote_state.iam.outputs.prod_eks_role_arn
  version = var.eks_version
  
  vpc_config {
    subnet_ids = concat(data.terraform_remote_state.vpc.outputs.eks_prod_private_subnet_ids, data.terraform_remote_state.vpc.outputs.eks_prod_public_subnet_ids)
  }

  depends_on = [aws_cloudwatch_log_group.control_plane]
}

resource "aws_cloudwatch_log_group" "control_plane" {
  name = "/aws/eks/${var.prefix_tag}_cluster/cluster"
  retention_in_days = 30
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
  node_role_arn = data.terraform_remote_state.iam.outputs.prod_eks_nodegroup_role_arn
  subnet_ids = data.terraform_remote_state.vpc.outputs.eks_prod_private_subnet_ids
  instance_types = var.nodegroup_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    max_size = var.node_max_size
    min_size = var.node_min_size
  }
}

resource "aws_iam_policy" "alb_ingress_policy" {
  name = "ucla-terraform_ALBIngressController"
  policy = file("policies/ALBIngressController.json")
}

resource "aws_iam_role" "alb_ingress_role" {
  name = "${var.prefix_tag}_ALBIngressRole"
  assume_role_policy =  templatefile("policies/oidc_assume_role_policy.json.template", { OIDC_ARN = aws_iam_openid_connect_provider.eks_openid_connect.arn, OIDC_URL = replace(aws_iam_openid_connect_provider.eks_openid_connect.url, "https://", ""), NAMESPACE = "kube-system", SA_NAME = "alb-ingress-controller" })
}

resource "aws_iam_role_policy_attachment" "iam_attach_alb_ingress" {
  policy_arn = aws_iam_policy.alb_ingress_policy.arn
  role       = aws_iam_role.alb_ingress_role.name
}
