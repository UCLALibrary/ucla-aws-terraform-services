terraform {
  backend "s3" {
    bucket = "softwaredev-services-terraform"
    key    = "test-cantaloupe/terraform.tfstate"
    region = "us-west-2"
    shared_credentials_file = "awscredfile"
    profile = "services"
  }
}

provider "aws" {
  shared_credentials_file = "${var.cred_file}"
  profile                 = "${var.cred_profile}"
  region                  = "${var.region}"
}

# Populate state file with AZ info.

data "aws_availability_zones" "available" {}

#############################################################################################################
# Create VPC network 172.20.0.0/16
#############################################################################################################
resource "aws_vpc" "main" {
  cidr_block = "172.20.0.0/16"
}

#############################################################################################################
# Create public subnet to attach Internet Gateway route
# 172.20.30.0/24
#############################################################################################################
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 30 + count.index)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  

  tags = {
    Name = "public_network"
  }
}

#############################################################################################################
# Attach internet gateway to created VPC
#############################################################################################################
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
}

#############################################################################################################
# Set main route table for VPC to Internet Gateway
#############################################################################################################
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}resource "aws_security_group" "allow_web" {
  name          = "allow_web"
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

resource "aws_security_group" "allow_restricted_ssh" {
  name          = "allow_restricted_ssh"
  description   = "Allow restricted subnets to SSH into systems"
  vpc_id        = "${aws_vpc.main.id}"
  depends_on    = ["aws_vpc.main"]

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["164.67.152.0/24", "164.67.40.0/24", "165.227.26.38/32"]
  }
}

resource "aws_security_group" "cantaloupe_stable_alb_ecs" {
  name = "cantaloupe-stable-alb-ecs"
  description = "Allow HTTP/HTTPS traffic to Cantaloupe Stable load balancers"
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
  
resource "aws_security_group" "cantaloupe_stable_container" {
  name = "cantaloupe-stable-container"
  description = "Whitelist Cantaloupe ALB SG to access application port on container"
  vpc_id        = "${aws_vpc.main.id}"
  depends_on    = ["aws_security_group.cantaloupe_stable_alb_ecs", "aws_vpc.main"]

  ingress {
    from_port   = "${var.cantaloupe_stable_app_port}"
    to_port     = "${var.cantaloupe_stable_app_port}"
    protocol    = "tcp"
    security_groups = ["${aws_security_group.cantaloupe_stable_alb_ecs.id}"]
  }
}

resource "aws_lb" "cantaloupe_stable_alb" {
  name            = "cantaloupe-stable-alb"
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

  container_definitions = <<DEFINITION
[
  {
    "name": "cantaloupe-stable",
    "cpu": 1,
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

resource "aws_iam_role" "ecs_role" {
  name               = "ecs_role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_service_role.json}"
}

data "aws_iam_policy_document" "ecs_service_policy" {
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = [
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "ec2:Describe*",
      "ec2:AuthorizeSecurityGroupIngress"
    ]
  }
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "ecs_service_role_policy"
  policy = "${data.aws_iam_policy_document.ecs_service_policy.json}"
  role   = "${aws_iam_role.ecs_role.id}"
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
    "aws_iam_role_policy.ecs_service_role_policy"

  ]
}