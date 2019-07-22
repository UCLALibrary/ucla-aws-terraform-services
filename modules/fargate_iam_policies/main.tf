data "aws_iam_policy_document" "ecs_service_role" {
  statement {
    effect        = "Allow"
    actions       = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.app_name}-ecs-execution-role"
  assume_role_policy = "${file("policies/ecs-role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "iam_attach_docker_auth" {
  role       = "${aws_iam_role.ecs_execution_role.name}"
  policy_arn = "${var.dockerauth_arn}"
}

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
  name   = "${var.app_name}-ecs_execution_role_policy"
  policy = "${file("policies/ecs-execution-role-policy.json")}"
  role   = "${aws_iam_role.ecs_execution_role.id}"
}
