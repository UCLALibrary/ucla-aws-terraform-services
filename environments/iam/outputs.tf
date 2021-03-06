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
