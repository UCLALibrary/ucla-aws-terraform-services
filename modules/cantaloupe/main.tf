resource "aws_security_group" "cantaloupe_container_vpc_access" {
  name          = "${var.app_name}-container-access"
  description   = "Whitelist Cantaloupe ALB SG to access application port on container"
  vpc_id        = "${var.vpc_main_id}"

  ingress {
    from_port       = "${var.app_port}"
    to_port         = "${var.app_port}"
    protocol        = "tcp"
    security_groups = ["${var.alb_main_sg_id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


resource "aws_lb_target_group" "cantaloupe_tg" {
  name        = "${var.app_name}-tg"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_main_id}"
  target_type = "ip"
  port        = 80
}

resource "aws_lb_listener" "cantaloupe_listener" {
  load_balancer_arn = "${var.alb_main_id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.cantaloupe_tg.id}"
    type             = "forward"
  }
}

resource "aws_ecs_cluster" "cantaloupe" {
  name = "${var.app_name}-cantaloupe"
}

resource "aws_ecs_task_definition" "cantaloupe_definition" {
  family                   = "${var.app_name}-cantaloupe"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.cantaloupe_cpu}"
  memory                   = "${var.cantaloupe_memory}"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
  depends_on               = [
    "aws_iam_role.ecs_execution_role",
    "aws_iam_role_policy.ecs_execution_role_policy"
  ]

  container_definitions = <<DEFINITION
[
  {
    "name": "${var.app_name}-cantaloupe",
    "memory": ${var.cantaloupe_memory},
    "image": "${var.registry_url}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ],
    "environment": [
      { "name" : "CANTALOUPE_ENDPOINT_ADMIN_ENABLED", "value" : "true" },
      { "name" : "CANTALOUPE_ENDPOINT_ADMIN_SECRET", "value" :  "secretpassword" },
      { "name" : "CANTALOUPE_CACHE_SERVER_DERIVATIVE_ENABLED", "value" : "true" },
      { "name" : "CANTALOUPE_CACHE_SERVER_DERIVATIVE", "value" : "S3Cache" },
      { "name" : "CANTALOUPE_CACHE_SERVER_DERIVATIVE_TTL_SECONDS", "value" : "0" },
      { "name" : "CANTALOUPE_CACHE_SERVER_PURGE_MISSING", "value" : "true" },
      { "name" : "CANTALOUPE_PROCESSOR_SELECTION_STRATEGY", "value" : "ManualSelectionStrategy" },
      { "name" : "CANTALOUPE_MANUAL_PROCESSOR_JP2", "value" : "KakaduNativeProcessor" },
      { "name" : "CANTALOUPE_S3CACHE_ACCESS_KEY_ID", "value" : "${var.s3_cache_access_key}" },
      { "name" : "CANTALOUPE_S3CACHE_SECRET_KEY", "value" : "${var.s3_cache_secret_key}" },
      { "name" : "CANTALOUPE_S3CACHE_ENDPOINT", "value" : "${var.s3_cache_endpoint}" },
      { "name" : "CANTALOUPE_S3CACHE_BUCKET_NAME", "value" : "${var.s3_cache_bucket}" },
      { "name" : "CANTALOUPE_S3SOURCE_ACCESS_KEY_ID", "value" : "${var.s3_source_access_key}" },
      { "name" : "CANTALOUPE_S3SOURCE_SECRET_KEY", "value" : "${var.s3_source_secret_key}" },
      { "name" : "CANTALOUPE_S3SOURCE_ENDPOINT", "value" : "${var.s3_source_endpoint}" },
      { "name" : "CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_BUCKET_NAME", "value" : "${var.s3_source_bucket}" },
      { "name" : "CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_PATH_SUFFIX", "value" : ".jpx" },
      { "name" : "CANTALOUPE_SOURCE_STATIC", "value" : "S3Source" },
      { "name" : "JAVA_HEAP_SIZE", "value" : "${var.cantaloupe_heapsize}" }
    ]
  }
]
DEFINITION

}

data "aws_iam_policy_document" "ecs_service_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
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

#resource "aws_iam_service_linked_role" "AWSServiceRoleForECS" {
#  aws_service_name = "ecs.amazonaws.com"
#}

resource "aws_ecs_service" "cantaloupe" {
  name            = "${var.app_name}-cantaloupe-service"
  cluster         = "${aws_ecs_cluster.cantaloupe.id}"
  task_definition = "${aws_ecs_task_definition.cantaloupe_definition.arn}"
  desired_count   = "${var.container_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.cantaloupe_container_vpc_access.id}"]
    subnets         = "${var.vpc_subnet_ids}"
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.cantaloupe_tg.id}"
    container_name   = "${var.app_name}-cantaloupe"
    container_port   = "${var.app_port}"
  }

  depends_on = [
    "aws_lb_listener.cantaloupe_listener",
    "aws_ecs_cluster.cantaloupe",
    "aws_ecs_task_definition.cantaloupe_definition"
#    "aws_iam_service_linked_role.AWSServiceRoleForECS"
  ]
}
