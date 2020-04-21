# Create a shared AWS CodeBuild role to attach to all CodeBuild projects
resource "aws_iam_role" "shared_codebuild_role" {
  name               = "${var.prefix_tag}_shared-codebuild"
  assume_role_policy = file("policies/codebuild-service-trust.json")
  path               = "/service-role/"
}


# Create default policy to grant CodeBuild role access to the following services:
# EC2
# SSM
# CloudWatch
resource "aws_iam_policy" "codebuild_default_policy" {
  name   = "${var.prefix_tag}_codebuild-default-policy"
  policy = file("policies/codebuild-default-policy.json")
}

# Attach default policy to shared CodeBuild role
resource "aws_iam_role_policy_attachment" "attach_codebuild_default_policy" {
  role       = aws_iam_role.shared_codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_default_policy.arn
}

# Create a shared AWS CodeBuild role to attach to all CodeBuild projects
resource "aws_iam_role" "eks_shared_codebuild_role" {
  name               = "${var.prefix_tag}_eks-shared-codebuild"
  assume_role_policy = file("policies/codebuild-service-trust.json")
  path               = "/service-role/"
}

# Attach default policy to shared EKS CodeBuild role
resource "aws_iam_role_policy_attachment" "eks_attach_codebuild_default_policy" {
  role       = aws_iam_role.eks_shared_codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_default_policy.arn
}

# Create IAM policy to allow EKS CodeBuild role to access EKS cluster information
resource "aws_iam_policy" "codebuild_allow_eks_cluster_get" {
  name   = "${var.prefix_tag}_codebuild-get-eks-cluster-info"
  policy = file("policies/codebuild-allow-eks-get.json")
}

# Attach EKS list cluster information permission to shared EKS CodeBuild role
resource "aws_iam_role_policy_attachment" "attach_eks_cluster_get_policy" {
  role       = aws_iam_role.eks_shared_codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_allow_eks_cluster_get.arn
}

# Create IAM Policy for EKS CodeBuild role to access Terraform S3 backend
resource "aws_iam_policy" "eks_access_s3_backend" {
  name   = "${var.prefix_tag}_codebuild-access-s3-backend"
  policy = templatefile("policies/codebuild-access-terraform-state-bucket.json.template", { TERRAFORM_STATE_BUCKET = var.terraform_state_bucket, TERRAFORM_LOCK_TABLE_DYNAMODB = var.terraform_state_lock_table })
}

# Attach Terraform S3 backend state permissions to EKS CodeBuild role
resource "aws_iam_role_policy_attachment" "attach_eks_access_s3_backend" {
  role       = aws_iam_role.eks_shared_codebuild_role.name
  policy_arn = aws_iam_policy.eks_access_s3_backend.arn
}
