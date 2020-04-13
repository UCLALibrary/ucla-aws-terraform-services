# Create a default k8s robot role account for k8s deployments
resource "aws_iam_role" "k8s_robot" {
  name               = "${var.prefix_tag}_${var.eks_deployment_robot_name}"
  assume_role_policy = templatefile("policies/codebuild-assume.json.template", { CODEBUILD_SERVICE_ROLE_ARN = aws_iam_role.shared_codebuild_role.arn })
}
