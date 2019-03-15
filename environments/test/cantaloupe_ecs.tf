resource "aws_ecs_cluster" "cantaloupe_41_test" {
  name = "cantaloupe-41-test"
}

resource "aws_ecs_task_definition" "cantaloupe_41_test" {
  family                   = "cantaloupe-41-test"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": 1
    "image": "${var.cantaloupe_latest_image}",
    "memory": 2048
    "name": "cantaloupe-41-test",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.cantaloupe_app_port},
        "hostPort": ${var.cantaloupe_app_port}
      }
    ],
    "environment": [
      {
        "CANTALOUPE_CACHE_SERVER_DERIVATIVE" = "S3Cache",
        "CANTALOUPE_CACHE_SERVER_DERIVATIVE_ENABLED" = "true",
        "CANTALOUPE_CACHE_SERVER_DERIVATIVE_TTL_SECONDS" = 86400,
        "CANTALOUPE_ENDPOINT_ADMIN_ENABLED" = "true",
        "CANTALOUPE_ENDPOINT_ADMIN_SECRET" = "${var.cantaloupe_endpoint_secret}",
        "CANTALOUPE_OPENJPEGPROCESSOR_PATH_TO_BINARIES" = "/usr/bin",
        "CANTALOUPE_PROCESSOR_JP2" = "OpenJpegProcessor",
        "CANTALOUPE_S3CACHE_ACCESS_KEY_ID" = "${var.cantaloupe_s3cache_access_key}",
        "CANTALOUPE_S3CACHE_BUCKET_NAME" = "${var.cantaloupe_s3cache_bucket_name}",
        "CANTALOUPE_S3CACHE_ENDPOINT" = "${var.cantaloupe_s3cache_endpoint}",
        "CANTALOUPE_S3CACHE_SECRET_KEY" = "${var.cantaloupe_s3cache_secret_key}",
        "CANTALOUPE_S3SOURCE_ACCESS_KEY_ID" = "${var.cantaloupe_s3source_access_key}",
        "CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_BUCKET_NAME" = "${var.cantaloupe_s3source_bucket_name}",
        "CANTALOUPE_S3SOURCE_ENDPOINT" = "${var.cantaloupe_s3source_endpoint}",
        "CANTALOUPE_S3SOURCE_SECRET_KEY" = "${var.cantaloupe_s3source_secret_key}",
        "CANTALOUPE_SOURCE_STATIC" = "${var.cantaloupe_source_static}"
      }
  }
]
DEFINITION
}

resource "aws_ecs_service" "cantaloupe_41_test" {
  name            = "cantaloupe-41-test"
  cluster         = "${aws_ecs_cluster.cantaloupe_41_test.id}"
  task_definition = "${aws_ecs_task_definition.cantaloupe_41_test.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.cantaloupe_container.id}"]
    subnets         = ["${aws_subnet.public.*.id}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.cantaloupe-tg.id}"
    container_name   = "cantaloupe-41-test"
    container_port   = "${var.cantaloupe_app_port}"
  }

  depends_on = [
    "aws_alb_listener.cantaloupe-fe",
  ]
}