resource "aws_security_group" "allow_web" {
  name          = "${var.app_name}-allow_web"
  description   = "All public facing traffic to 80/443"
  vpc_id        = "${aws_vpc.main.id}"
  depends_on    = ["aws_vpc.main"]

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "cantaloupe_alb_ecs" {
  name          = "{var.app_name}-alb-access"
  description   = "Allow HTTP/HTTPS traffic to Cantaloupe Stable load balancers"
  vpc_id        = "${aws_vpc.main.id}"
  depends_on    = ["aws_vpc.main"]

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
  
resource "aws_security_group" "cantaloupe_container" {
  name          = "{$var.app_name}-container-access"
  description   = "Whitelist Cantaloupe ALB SG to access application port on container"
  vpc_id        = "${aws_vpc.main.id}"
  depends_on    = ["aws_security_group.cantaloupe_stable_alb_ecs", "aws_vpc.main"]

  ingress {
    from_port       = "${var.app_port}"
    to_port         = "${var.app_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.cantaloupe_alb_ecs.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "cantaloupe_stable_alb" {
  name            = "cantaloupetable-alb"
  internal        = false
  load_balancer_type = "application"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.cantaloupe_stable_alb_ecs.id}"]
}

resource "aws_lb_target_group" "cantaloupe_stable_tg" {
  name        = "cantaloupe-stable-tg"
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.main.id}"
  target_type = "ip"
  port        = 80
}

resource "aws_lb_listener" "cantaloupe_stable_fe" {
  load_balancer_arn = "${aws_lb.cantaloupe_stable_alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.cantaloupe_stable_tg.id}"
    type             = "forward"
  }
}

resource "aws_ecs_cluster" "cantaloupe_stable" {
  name = "cantaloupe-stable"
}

resource "aws_ecs_task_definition" "cantaloupe_stable" {
  family                   = "cantaloupe-stable"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 1024
  memory = 2048
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
  depends_on = [
    "aws_iam_role.ecs_execution_role",
    "aws_iam_role_policy.ecs_execution_role_policy"
  ]

  container_definitions = <<DEFINITION
[
  {
    "name": "cantaloupe-stable",
    "memory": 2048,
    "image": "${var.cantaloupe_stable_image}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.cantaloupe_stable_app_port},
        "hostPort": ${var.cantaloupe_stable_app_port}
      }
    ],
    "environment": [
      { "name" : "CANTALOUPE_ENDPOINT_ADMIN_ENABLED", "value" : "true" },
      { "name" : "CANTALOUPE_ENDPOINT_ADMIN_SECRET", "value" :  "secretpassword" }
    ]
  }
]
DEFINITION

}

#data "aws_iam_policy_document" "ecs_service_role" {
#  statement {
#    effect = "Allow"
#    actions = ["sts:AssumeRole"]
#    principals {
#      type = "Service"
#      identifiers = ["ecs.amazonaws.com"]
#    }
#  }
#}

resource "aws_iam_role" "ecs_execution_role" {
  name               = "ecs-execution-role"
  assume_role_policy = "${file("ecs-role-policy.json")}"
}

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
  name   = "ecs_execution_role_policy"
  policy = "${file("ecs-execution-role-policy.json")}"
  role   = "${aws_iam_role.ecs_execution_role.id}"
}

resource "aws_iam_service_linked_role" "AWSServiceRoleForECS" {
  aws_service_name = "ecs.amazonaws.com"
}

resource "aws_ecs_service" "cantaloupe_stable" {
  name            = "cantaloupe-stable"
  cluster         = "${aws_ecs_cluster.cantaloupe_stable.id}"
  task_definition = "${aws_ecs_task_definition.cantaloupe_stable.arn}"
  desired_count   = "${var.cantaloupe_stable_app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.cantaloupe_stable_container.id}"]
    subnets         = ["${aws_subnet.public.*.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.cantaloupe_stable_tg.id}"
    container_name   = "cantaloupe-stable"
    container_port   = "${var.cantaloupe_stable_app_port}"
  }

  depends_on = [
    "aws_lb_listener.cantaloupe_stable_fe",
    "aws_ecs_cluster.cantaloupe_stable",
    "aws_ecs_task_definition.cantaloupe_stable",
    "aws_iam_service_linked_role.AWSServiceRoleForECS"
  ]
}
