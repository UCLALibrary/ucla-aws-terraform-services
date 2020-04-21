##### Create Production EKS IAM Role to attach to Production EKS Cluster
resource "aws_iam_role" "prod_eks" {
  name = "${var.prefix_tag}_prod_eks_cluster_role"
  assume_role_policy = file("policies/eks-service-trust.json")
  path = "/service-role/"
} 

resource "aws_iam_role_policy_attachment" "prod_eks_attach_service_policy" {
  role = aws_iam_role.prod_eks.name
  policy_arn = var.eks_iam_policy_attachment_service_policy_arn
}

resource "aws_iam_role_policy_attachment" "prod_eks_attach_cluster_policy" {
  role = aws_iam_role.prod_eks.name
  policy_arn = var.eks_iam_policy_attachment_cluster_policy_arn
}

##### Create Test EKS IAM Role to attach to Test EKS Cluster
resource "aws_iam_role" "test_eks" {
  name = "${var.prefix_tag}_test_eks_cluster_role"
  assume_role_policy = file("policies/eks-service-trust.json")
  path = "/service-role/"
} 

resource "aws_iam_role_policy_attachment" "test_eks_attach_service_policy" {
  role = aws_iam_role.test_eks.name
  policy_arn = var.eks_iam_policy_attachment_service_policy_arn
}

resource "aws_iam_role_policy_attachment" "test_eks_attach_cluster_policy" {
  role = aws_iam_role.test_eks.name
  policy_arn = var.eks_iam_policy_attachment_cluster_policy_arn
}

##### Create Production EKS NodeGroup IAM Role to attach to Production EKS Cluster
resource "aws_iam_role" "prod_eks_nodegroup" {
  name = "${var.prefix_tag}_prod_eks_nodegroup_role"
  assume_role_policy = file("policies/ec2-service-trust.json")
  path = "/service-role/"
}

resource "aws_iam_role_policy_attachment" "prod_eks_nodegroup_attach_workernode_policy" {
  policy_arn = var.eks_nodegroup_iam_policy_attachment_workernode_policy_arn
  role       = aws_iam_role.prod_eks_nodegroup.name
}

resource "aws_iam_role_policy_attachment" "prod_eks_nodegroup_attach_cni_policy" {
  policy_arn = var.eks_nodegroup_iam_policy_attachment_cni_policy_arn
  role       = aws_iam_role.prod_eks_nodegroup.name
}

resource "aws_iam_role_policy_attachment" "prod_eks_nodegroup_attach_ecr_policy" {
  policy_arn = var.eks_nodegroup_iam_policy_attachment_ecr_policy
  role       = aws_iam_role.prod_eks_nodegroup.name
}

##### Create Test EKS NodeGroup IAM Role to attach to Test EKS Cluster
resource "aws_iam_role" "test_eks_nodegroup" {
  name = "${var.prefix_tag}_test_eks_nodegroup_role"
  assume_role_policy = file("policies/ec2-service-trust.json")
  path = "/service-role/"
}

resource "aws_iam_role_policy_attachment" "test_eks_nodegroup_attach_workernode_policy" {
  policy_arn = var.eks_nodegroup_iam_policy_attachment_workernode_policy_arn
  role       = aws_iam_role.test_eks_nodegroup.name
}

resource "aws_iam_role_policy_attachment" "test_eks_nodegroup_attach_cni_policy" {
  policy_arn = var.eks_nodegroup_iam_policy_attachment_cni_policy_arn
  role       = aws_iam_role.test_eks_nodegroup.name
}

resource "aws_iam_role_policy_attachment" "test_eks_nodegroup_attach_ecr_policy" {
  policy_arn = var.eks_nodegroup_iam_policy_attachment_ecr_policy
  role       = aws_iam_role.test_eks_nodegroup.name
}

##### Create EKS ALB Ingress Policy for service roles to attach
resource "aws_iam_policy" "alb_ingress_policy" {
  name = "${var.prefix_tag}_alb_ingress_policy"
  policy = file("policies/eks-alb-ingress-controller.json")
}
