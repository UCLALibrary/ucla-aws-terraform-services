# Create a shared AWS CodeBuild role to attach to all CodeBuild projects
resource "aws_iam_role" "shared_codebuild_role" {
  name = "${var.prefix_tag}_shared-codebuild"
  assume_role_policy = file("policies/codebuild-service-trust.json")
}


# Create default policy to grant CodeBuild role access to the following services:
# EC2
# SSM
# CloudWatch
resource "aws_iam_policy" "codebuild_default_policy" {
  name = "${var.prefix_tag}_codebuild-default-policy"
  policy = file("policies/codebuild-default-policy.json")
}

# Attach default policy to shared CodeBuild role
resource "aws_iam_role_policy_attachment" "attach_codebuild_default_policy" {
  role = aws_iam_role.shared_codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_default_policy.arn
}

# Create a shared AWS CodeBuild role to attach to all CodeBuild projects
resource "aws_iam_role" "eks_shared_codebuild_role" {
  name = "${var.prefix_tag}_eks_shared-codebuild"
  assume_role_policy = file("policies/codebuild-service-trust.json")
}

# Attach default policy to shared EKS CodeBuild role
resource "aws_iam_role_policy_attachment" "eks_attach_codebuild_default_policy" {
  role = aws_iam_role.eks_shared_codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_default_policy.arn
}

# Create IAM policy to allow CodeBuild to access EKS cluster information
resource "aws_iam_policy" "codebuild_allow_eks_cluster_get" {
  name = "${var.prefix_tag}_codebuild-get-eks-cluster-info"
  policy = file("policies/codebuild-allow-eks-get.json")
}

# Attach EKS list cluster information permission to shared CodeBuild role
resource "aws_iam_role_policy_attachment" "attach_eks_cluster_get_policy" {
  role = aws_iam_role.eks_shared_codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_allow_eks_cluster_get.arn
}
