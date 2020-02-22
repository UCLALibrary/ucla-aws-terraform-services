output "eks_nodegroup_role_arn" {
  value = "${aws_iam_role.iam_for_eks_node_group.arn}"
}

output "eks_role_arn" {
  value = "${aws_iam_role.iam_for_eks.arn}"
}

