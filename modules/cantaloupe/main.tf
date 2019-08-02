resource "aws_security_group" "cantaloupe_container_vpc_access" {
  name          = "${var.app_name}-cantaloupe-container-access"
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
  name        = "${var.app_name}-cantaloupe-tg"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_main_id}"
  target_type = "ip"
  port        = "${var.app_port}"
}

resource "aws_lb_listener" "cantaloupe_listener" {
  load_balancer_arn = "${var.alb_main_id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"    
    }
  }
}

resource "aws_lb_listener" "cantaloupe_listener_https" {
  load_balancer_arn = "${var.alb_main_id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.app_ssl_certificate_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.cantaloupe_tg.arn}"
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
  execution_role_arn       = "${var.ecs_execution_role_arn}"
  task_role_arn            = "${var.ecs_execution_role_arn}"

  container_definitions = <<DEFINITION
[
  {
    "name": "${var.app_name}-cantaloupe",
    "repositoryCredentials": { "credentialsParameter": "${var.dockerhubauth_credentials_arn}" },
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
      { "name" : "CANTALOUPE_ENDPOINT_ADMIN_ENABLED", "value" : "${var.cantaloupe_enable_admin}" },
      { "name" : "CANTALOUPE_ENDPOINT_ADMIN_SECRET", "value" :  "${var.cantaloupe_admin_secret}" },
      { "name" : "CANTALOUPE_CACHE_SERVER_DERIVATIVE_ENABLED", "value" : "${var.cantaloupe_enable_cache_server}" },
      { "name" : "CANTALOUPE_CACHE_SERVER_DERIVATIVE", "value" : "${var.cantaloupe_cache_server_derivative}" },
      { "name" : "CANTALOUPE_CACHE_SERVER_DERIVATIVE_TTL_SECONDS", "value" : "${var.cantaloupe_cache_server_derivative_ttl}" },
      { "name" : "CANTALOUPE_CACHE_SERVER_PURGE_MISSING", "value" : "${var.cantaloupe_cache_server_purge_missing}" },
      { "name" : "CANTALOUPE_PROCESSOR_SELECTION_STRATEGY", "value" : "${var.cantaloupe_processor_selection_strategy}" },
      { "name" : "CANTALOUPE_MANUAL_PROCESSOR_JP2", "value" : "${var.cantaloupe_manual_processor_jp2}" },
      { "name" : "CANTALOUPE_S3CACHE_ACCESS_KEY_ID", "value" : "${var.s3_cache_access_key}" },
      { "name" : "CANTALOUPE_S3CACHE_SECRET_KEY", "value" : "${var.s3_cache_secret_key}" },
      { "name" : "CANTALOUPE_S3CACHE_ENDPOINT", "value" : "${var.s3_cache_endpoint}" },
      { "name" : "CANTALOUPE_S3CACHE_BUCKET_NAME", "value" : "${var.s3_cache_bucket}" },
      { "name" : "CANTALOUPE_S3SOURCE_ACCESS_KEY_ID", "value" : "${var.s3_source_access_key}" },
      { "name" : "CANTALOUPE_S3SOURCE_SECRET_KEY", "value" : "${var.s3_source_secret_key}" },
      { "name" : "CANTALOUPE_S3SOURCE_ENDPOINT", "value" : "${var.s3_source_endpoint}" },
      { "name" : "CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_BUCKET_NAME", "value" : "${var.s3_source_bucket}" },
      { "name" : "CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_PATH_SUFFIX", "value" : "${var.s3_source_basiclookup_suffix}" },
      { "name" : "CANTALOUPE_SOURCE_STATIC", "value" : "${var.cantaloupe_source_static}" },
      { "name" : "JAVA_HEAP_SIZE", "value" : "${var.cantaloupe_heapsize}" }
    ]
  }
]
DEFINITION

}

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
    target_group_arn = "${aws_lb_target_group.cantaloupe_tg.arn}"
    container_name   = "${var.app_name}-cantaloupe"
    container_port   = "${var.app_port}"
  }

  depends_on = [
    "aws_lb_listener.cantaloupe_listener",
    "aws_ecs_cluster.cantaloupe",
    "aws_ecs_task_definition.cantaloupe_definition"
  ]
}
