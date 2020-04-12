output "iiif_k8s_robot_arn" {
  value = "${aws_iam_role.k8s_robot.arn}"
}

output "iiif_k8s_robot_name" {
  value = "${aws_iam_role.k8s_robot.name}"
}

output "shared_codebuild_robot_arn" {
  value = "${aws_iam_role.shared_codebuild_role.arn}"
}

output "shared_codebuild_robot_name" {
  value = "${aws_iam_role.shared_codebuild_role.name}"
}

output "eks_shared_codebuild_robot_arn" {
  value = "${aws_iam_role.shared_eks_codebuild_role.arn}"
}

output "eks_shared_codebuild_robot_name" {
  value = "${aws_iam_role.shared_eks_codebuild_role.name}"
}
