resource "aws_security_group" "manifeststore_container_vpc_access" {
  name          = "${var.app_name}-manifeststore-container-access"
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
  name        = "${var.app_name}-manifeststore-tg"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_main_id}"
  target_type = "ip"
  port        = "${var.app_port}"

  health_check {
    path = "${var.manifeststore_healthcheck_path}"
    port = "${var.app_port}"
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 5
    interval = 15
    matcher = "200"
  }
}

resource "aws_lb_listener_rule" "docs" {
  listener_arn = "${var.http_listener_arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.manifeststore_tg.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/docs/manifest-store*"]
  }
}

resource "aws_lb_listener_rule" "collection" {
  listener_arn = "${var.http_listener_arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.manifeststore_tg.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/collection/*"]
  }
}

resource "aws_lb_listener_rule" "manifest" {
  listener_arn = "${var.http_listener_arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.manifeststore_tg.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/*/manifest"]
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
  execution_role_arn       = "${var.ecs_execution_role_arn}"
  task_role_arn            = "${var.ecs_execution_role_arn}"

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
      { "name" : "MANIFESTSTORE_S3_BUCKET", "value" : "${var.manifeststore_s3_bucket}" },
      { "name" : "MANIFESTSTORE_S3_ACCESS_KEY", "value" :  "${var.manifeststore_s3_access_key}" },
      { "name" : "MANIFESTSTORE_S3_SECRET_KEY", "value" : "${var.manifeststore_s3_secret_key}" },
      { "name" : "MANIFESTSTORE_S3_REGION", "value" : "${var.manifeststore_s3_region}" },
      { "name" : "MANIFESTSTORE_HTTP_CALLBACK", "value" : "${var.manifeststore_http_callback}" },
      { "name" : "HTTP_PORT", "value" : "${var.manifeststore_app_port}" },
      { "name" : "OPENAPI_SPEC_PATH", "value" : "${var.manifeststore_openspec_path}" }
    ]
  }
]
DEFINITION

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
    target_group_arn = "${aws_lb_target_group.manifeststore_tg.arn}"
    container_name   = "${var.app_name}-manifeststore"
    container_port   = "${var.app_port}"
  }

  depends_on = [
    "aws_lb_listener_rule.docs",
    "aws_ecs_cluster.manifeststore",
    "aws_ecs_task_definition.manifeststore_definition"
  ]
}
