resource "aws_security_group" "manifeststore_container_vpc_access" {
  name          = "${var.app_name}-container-access"
  description   = "Whitelist manifeststore ALB SG to access application port on container"
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

resource "aws_lb_target_group" "manifeststore_tg" {
  name        = "${var.app_name}-tg"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_main_id}"
  target_type = "ip"
  port        = 80
}

resource "aws_lb_listener" "manifeststore_listener" {
  load_balancer_arn = "${var.alb_main_id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.manifeststore_tg.id}"
    type             = "forward"
  }
}

resource "aws_ecs_cluster" "manifeststore" {
  name = "${var.app_name}-manifeststore"
}

resource "aws_ecs_task_definition" "manifeststore_definition" {
  family                   = "${var.app_name}-manifeststore"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.manifeststore_cpu}"
  memory                   = "${var.manifeststore_memory}"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
  depends_on               = [
    "aws_iam_role.ecs_execution_role",
    "aws_iam_role_policy.ecs_execution_role_policy"
  ]

  container_definitions = <<DEFINITION
[
  {
    "name": "${var.app_name}-manifeststore",
    "repositoryCredentials": { "credentialsParameter": "${var.dockerhubauth_credentials_arn}" },
    "memory": ${var.manifeststore_memory},
    "image": "${var.registry_url}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ],
    "environment": [
      { "name" : "manifeststore_ENDPOINT_ADMIN_ENABLED", "value" : "${var.manifeststore_enable_admin}" },
      { "name" : "manifeststore_ENDPOINT_ADMIN_SECRET", "value" :  "${var.manifeststore_admin_secret}" },
      { "name" : "manifeststore_CACHE_SERVER_DERIVATIVE_ENABLED", "value" : "${var.manifeststore_enable_cache_server}" },
      { "name" : "manifeststore_CACHE_SERVER_DERIVATIVE", "value" : "${var.manifeststore_cache_server_derivative}" },
      { "name" : "manifeststore_CACHE_SERVER_DERIVATIVE_TTL_SECONDS", "value" : "${var.manifeststore_cache_server_derivative_ttl}" },
      { "name" : "manifeststore_CACHE_SERVER_PURGE_MISSING", "value" : "${var.manifeststore_cache_server_purge_missing}" },
      { "name" : "manifeststore_PROCESSOR_SELECTION_STRATEGY", "value" : "${var.manifeststore_processor_selection_strategy}" },
      { "name" : "manifeststore_MANUAL_PROCESSOR_JP2", "value" : "${var.manifeststore_manual_processor_jp2}" },
      { "name" : "manifeststore_S3CACHE_ACCESS_KEY_ID", "value" : "${var.s3_cache_access_key}" },
      { "name" : "manifeststore_S3CACHE_SECRET_KEY", "value" : "${var.s3_cache_secret_key}" },
      { "name" : "manifeststore_S3CACHE_ENDPOINT", "value" : "${var.s3_cache_endpoint}" },
      { "name" : "manifeststore_S3CACHE_BUCKET_NAME", "value" : "${var.s3_cache_bucket}" },
      { "name" : "manifeststore_S3SOURCE_ACCESS_KEY_ID", "value" : "${var.s3_source_access_key}" },
      { "name" : "manifeststore_S3SOURCE_SECRET_KEY", "value" : "${var.s3_source_secret_key}" },
      { "name" : "manifeststore_S3SOURCE_ENDPOINT", "value" : "${var.s3_source_endpoint}" },
      { "name" : "manifeststore_S3SOURCE_BASICLOOKUPSTRATEGY_BUCKET_NAME", "value" : "${var.s3_source_bucket}" },
      { "name" : "manifeststore_S3SOURCE_BASICLOOKUPSTRATEGY_PATH_SUFFIX", "value" : "${var.s3_source_basiclookup_suffix}" },
      { "name" : "manifeststore_SOURCE_STATIC", "value" : "${var.manifeststore_source_static}" },
      { "name" : "JAVA_HEAP_SIZE", "value" : "${var.manifeststore_heapsize}" }
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

resource "aws_ecs_service" "manifeststore" {
  name            = "${var.app_name}-manifeststore-service"
  cluster         = "${aws_ecs_cluster.manifeststore.id}"
  task_definition = "${aws_ecs_task_definition.manifeststore_definition.arn}"
  desired_count   = "${var.container_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.manifeststore_container_vpc_access.id}"]
    subnets         = "${var.vpc_subnet_ids}"
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.manifeststore_tg.id}"
    container_name   = "${var.app_name}-manifeststore"
    container_port   = "${var.app_port}"
  }

  depends_on = [
    "aws_lb_listener.manifeststore_listener",
    "aws_ecs_cluster.manifeststore",
    "aws_ecs_task_definition.manifeststore_definition"
  ]
}
