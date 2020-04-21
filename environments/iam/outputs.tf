output "iiif_k8s_robot_arn" {
  value = aws_iam_role.k8s_robot.arn
}

output "iiif_k8s_robot_name" {
  value = aws_iam_role.k8s_robot.name
}

output "shared_codebuild_robot_arn" {
  value = aws_iam_role.shared_codebuild_role.arn
}

output "shared_codebuild_robot_name" {
  value = aws_iam_role.shared_codebuild_role.name
}

output "eks_shared_codebuild_robot_arn" {
  value = aws_iam_role.eks_shared_codebuild_role.arn
}

output "eks_shared_codebuild_robot_name" {
  value = aws_iam_role.eks_shared_codebuild_role.name
}

output "access_s3_state_iam_policy_name" {
  value = aws_iam_policy.eks_access_s3_backend.name
}

output "access_s3_state_iam_policy_arn" {
  value = aws_iam_policy.eks_access_s3_backend.arn
}

output "test_eks_role_arn" {
  value = aws_iam_role.test_eks.arn
}

output "test_eks_role_id" {
  value = aws_iam_role.test_eks.id
}

output "test_eks_role_name" {
  value = aws_iam_role.test_eks.name
}

output "test_eks_nodegroup_role_arn" {
  value = aws_iam_role.test_eks_nodegroup.arn
}

output "prod_eks_role_arn" {
  value = aws_iam_role.prod_eks.arn
}

output "prod_eks_role_id" {
  value = aws_iam_role.prod_eks.id
}

output "prod_eks_role_name" {
  value = aws_iam_role.prod_eks.name
}

output "prod_eks_nodegroup_role_arn" {
  value = aws_iam_role.prod_eks_nodegroup.arn
}

output "alb_ingress_policy_arn" {
  value = aws_iam_policy.alb_ingress_policy.arn
}

output "alb_ingress_policy_id" {
  value = aws_iam_policy.alb_ingress_policy.id
}
