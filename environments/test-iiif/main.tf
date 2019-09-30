terraform {
  backend "remote" {}
}

provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.region}"
}

### Configuration to retrieve VPC and subnets to provision to
data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    hostname = "${var.terraform_remote_hostname}"
    token = "${var.terraform_remote_token}"
    organization = "${var.terraform_remote_organization}"
    workspaces = {
      name = "${var.terraform_remote_networking_workspace}"
    }
  }
}

### Import IAM policy that grants the created ECS IAM role access to dockerhub credentials
data "template_file" "ecs_iam_init" {
  template      = "${file("policies/secrets-manager-dockerhub-auth.json.tpl")}"
  vars          = {
    secrets_arn = "${var.dockerhub_credentials_secrets_arn}"
  }
}

### Create an IAM role that allows for ECS execution
module "iiif_fargate_ecs_iam_role" {
  source                     = "git::https://github.com/UCLALibrary/aws_terraform_module_iam_role.git"
  iam_role_name              = "${local.fargate_ecs_role_name}"
  iam_assume_policy_document = "${file("policies/assume-role-policy.json")}"
}

### Create IAM policy with template from previous step
resource "aws_iam_policy" "fargate_ecs_access_dockerhub_registry_policy" {
  name   = "${local.fargate_ecs_role_name}-dockerhub-credentials-access"
  policy = "${data.template_file.ecs_iam_init.rendered}"
}

### Attach AWS provided ECS execution policy to created IAM role
resource "aws_iam_policy_attachment" "fargate_ecs_execution_role_policy_attachment" {
  name       = "${local.fargate_ecs_role_name}-attach-ecs-execution-privs"
  roles      = ["${module.iiif_fargate_ecs_iam_role.iam_role_name}"]
  policy_arn = "${var.fargate_ecs_task_execution_role_arn}"
}

### Attach IAM policy that grants access to secrets manager from imported dockerhub t emplate
resource "aws_iam_policy_attachment" "fargate_credentials_secrets_privilege" {
  name       = "${local.fargate_ecs_role_name}-attach-secrets-privs"
  roles      = ["${module.iiif_fargate_ecs_iam_role.iam_role_name}"]
  policy_arn = "${aws_iam_policy.fargate_ecs_access_dockerhub_registry_policy.arn}"
}

### Create a cantaloupe source bucket
module "cantaloupe_src_bucket" {
  source             = "git::https://github.com/UCLALibrary/aws_terraform_s3_module.git"
  bucket_name        = "${var.cantaloupe_s3_source_bucket != "" ? var.cantaloupe_s3_source_bucket : local.cantaloupe_s3_src_bucket}"
  bucket_region      = "${var.region}"
  force_destroy_flag = "${var.force_destroy_src_bucket}"
}

### Create a manifeststore source bucket
module "manifeststore_bucket" {
  source             = "git::https://github.com/UCLALibrary/aws_terraform_s3_module.git"
  bucket_name        = "${var.manifeststore_s3_bucket}"
  bucket_region      = "${var.region}"
  force_destroy_flag = "${var.force_destroy_src_bucket}"
}


### Create a security group that allows 80/443 access to the AWS Load Balancers
resource "aws_security_group" "allow_alb_web" {
  name          = "${var.iiif_app_name}-alb-allow-web"
  description   = "Allow HTTP/HTTPS traffic to load balancers"
  vpc_id        = data.terraform_remote_state.vpc.outputs.vpc_main_id

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

### Create a security group that allows the AWS Load Balancer to connect to the container ports
resource "aws_security_group" "allow_alb_listening_port" {
  name          = "${var.iiif_app_name}-alb-allow-listening-port"
  description   = "Whitelist IIIF ALB to access application port on container"
  vpc_id        = data.terraform_remote_state.vpc.outputs.vpc_main_id

  ingress {
    from_port       = "${var.cantaloupe_listening_port}"
    to_port         = "${var.cantaloupe_listening_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.allow_alb_web.id}"]
  }

  ingress {
    from_port       = "${var.manifeststore_listening_port}"
    to_port         = "${var.manifeststore_listening_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.allow_alb_web.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

### Create an AWS Load Balancer
module "alb" {
  source         = "git::https://github.com/UCLALibrary/aws_terraform_module_alb.git"
  alb_name       = "${var.iiif_app_name}-alb"

  vpc_subnet_ids = data.terraform_remote_state.vpc.outputs.vpc_public_subnet_ids
  alb_security_groups = ["${aws_security_group.allow_alb_web.id}"]
}


### Create a target group pointing to Cantaloupe on the IIIF cluster
resource "aws_lb_target_group" "cantaloupe_tg" {
  name        = "${var.iiif_app_name}-cantaloupe-tg"
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_main_id
  target_type = "ip"
  port        = "${var.cantaloupe_listening_port}"

  health_check {
    path = "${var.cantaloupe_healthcheck_path}"
    port = "${var.cantaloupe_listening_port}"
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 5
    interval = 15
    matcher = "200"
  }
}

### Create a target group pointing to Manifeststore on the IIIF cluster
resource "aws_lb_target_group" "manifeststore_tg" {
  name        = "${var.iiif_app_name}-manifeststore-tg"
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_main_id
  target_type = "ip"
  port        = "${var.manifeststore_listening_port}"

  health_check {
    path = "${var.manifeststore_healthcheck_path}"
    port = "${var.manifeststore_listening_port}"
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 5
    interval = 15
    matcher = "200"
  }
}

### Create a listener that redirects all HTTP traffic to HTTPS
resource "aws_lb_listener" "iiif_http_listener" {
  load_balancer_arn = "${module.alb.alb_main_id}"
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

  depends_on = ["module.alb"]
}

### Create a listener to answer on HTTPS and set the default route to Cantaloupe's target group
resource "aws_lb_listener" "iiif_https_listener" {
  load_balancer_arn = "${module.alb.alb_main_id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.iiif_app_ssl_cert_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.cantaloupe_tg.arn}"
    type             = "forward"
  }

  depends_on = ["module.alb"]
}

resource "aws_lb_listener_rule" "manifeststore_docs" {
  listener_arn = "${aws_lb_listener.iiif_https_listener.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.manifeststore_tg.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/docs/manifest-store*"]
  }
}

resource "aws_lb_listener_rule" "manifeststore_collection" {
  listener_arn = "${aws_lb_listener.iiif_https_listener.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.manifeststore_tg.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/collection/*"]
  }
}

resource "aws_lb_listener_rule" "manifeststore_manifest" {
  listener_arn = "${aws_lb_listener.iiif_https_listener.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.manifeststore_tg.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/*/manifest"]
  }
}

data "template_file" "fargate_iiif_definition" {
  template = "${file("templates/env_vars.properties.tpl")}"
  vars          = {
    fargate_definition_name                 = "${local.fargate_definition_name}"
    registry_auth_arn                       = "${var.dockerhub_credentials_secrets_arn}"
    cantaloupe_memory                       = "${var.cantaloupe_memory}"
    cantaloupe_cpu                          = "${var.cantaloupe_cpu}"
    cantaloupe_image_url                    = "${var.cantaloupe_image_url}"
    cantaloupe_listening_port               = "${var.cantaloupe_listening_port}"
    cantaloupe_enable_admin                 = "${var.cantaloupe_enable_admin}"
    cantaloupe_admin_secret                 = "${var.cantaloupe_admin_secret}"
    cantaloupe_enable_cache_server          = "${var.cantaloupe_enable_cache_server}"
    cantaloupe_cache_server_derivative      = "${var.cantaloupe_cache_server_derivative}"
    cantaloupe_cache_server_derivative_ttl  = "${var.cantaloupe_cache_server_derivative_ttl}"
    cantaloupe_cache_server_purge_missing   = "${var.cantaloupe_cache_server_purge_missing}"
    cantaloupe_processor_selection_strategy = "${var.cantaloupe_processor_selection_strategy}"
    cantaloupe_manual_processor_jp2         = "${var.cantaloupe_manual_processor_jp2}"
    cantaloupe_s3_cache_access_key          = "${var.cantaloupe_s3_cache_access_key}"
    cantaloupe_s3_cache_secret_key          = "${var.cantaloupe_s3_cache_secret_key}"
    cantaloupe_s3_cache_endpoint            = "${var.cantaloupe_s3_cache_endpoint}"
    cantaloupe_s3_cache_bucket              = "${var.cantaloupe_s3_cache_bucket}"
    cantaloupe_s3_source_access_key         = "${var.cantaloupe_s3_source_access_key}"
    cantaloupe_s3_source_secret_key         = "${var.cantaloupe_s3_source_secret_key}"
    cantaloupe_s3_source_endpoint           = "${var.cantaloupe_s3_source_endpoint}"
    cantaloupe_s3_source_bucket             = "${var.cantaloupe_s3_source_bucket != "" ? var.cantaloupe_s3_source_bucket : local.cantaloupe_s3_src_bucket}"
    cantaloupe_s3_source_basiclookup_suffix = "${var.cantaloupe_s3_source_basiclookup_suffix}"
    cantaloupe_source_static                = "${var.cantaloupe_source_static}"
    cantaloupe_heapsize                     = "${var.cantaloupe_heapsize}"
    manifeststore_listening_port            = "${var.manifeststore_listening_port}"
    manifeststore_s3_access_key             = "${var.manifeststore_s3_access_key}"
    manifeststore_s3_secret_key             = "${var.manifeststore_s3_secret_key}"
    manifeststore_s3_region                 = "${var.manifeststore_s3_region}"
    manifeststore_s3_bucket                 = "${var.manifeststore_s3_bucket}"
    manifeststore_memory                    = "${var.manifeststore_memory}"
    manifeststore_cpu                       = "${var.manifeststore_cpu}"
    manifeststore_image_url                 = "${var.manifeststore_image_url}"
  }
}

module "iiif_fargate" {
  source                  = "git::https://github.com/UCLALibrary/aws_terraform_module_fargate.git?ref=IIIF-418"
  memory                  = "${var.container_host_memory}"
  cpu                     = "${var.container_host_cpu}"
  execution_role_arn      = "${module.iiif_fargate_ecs_iam_role.iam_role_arn}"
  registry_auth_arn       = "${var.dockerhub_credentials_secrets_arn}"
  enable_load_balancer    = "${var.enable_load_balancer}"
  fargate_cluster_name    = "${local.fargate_cluster_name}"
  fargate_service_name    = "${local.fargate_service_name}"
  fargate_definition_name = "${local.fargate_definition_name}"
  sg_id                   = "${aws_security_group.allow_alb_listening_port.id}"
  vpc_subnet_ids          = data.terraform_remote_state.vpc.outputs.vpc_public_subnet_ids
  container_definitions   = "${data.template_file.fargate_iiif_definition.rendered}"
  target_groups           = "${local.fargate_associate_tg}"
}

module "kakadu_converter_s3_tiff" {
  source        = "git::https://github.com/UCLALibrary/aws_terraform_s3_module.git"
  bucket_name   = "${var.kakadu_converter_s3_tiff_bucket}"
  bucket_region = "${var.kakadu_converter_s3_tiff_bucket_region}"
}

module "kakadu_converter_lambda_tiff" {
  source = "git::https://github.com/UCLALibrary/aws_terraform_lambda_module.git"

  ## KakaduConverter lambda role setup
  cloudwatch_iam_allowed_actions = "${var.kakadu_converter_cloudwatch_permissions}"
  s3_iam_allowed_actions         = "${var.kakadu_converter_s3_permissions}"
  s3_iam_allowed_resources       = "${var.kakadu_converter_s3_buckets}"

  ## KakaduConverter lambda function specification
  app_artifact      = "${var.kakadu_converter_artifact}"
  app_name          = "${var.kakadu_converter_app_name}"
  app_layers        = "${var.kakadu_converter_layers}"
  app_handler       = "${var.kakadu_converter_handler}"
  app_filter_suffix = "${var.kakadu_converter_filter_suffix}"
  app_runtime       = "${var.kakadu_converter_runtime}"
  app_memory_size   = "${var.kakadu_converter_memory_size}"
  app_timeout       = "${var.kakadu_converter_timeout}"
  app_environment_variables = "${var.kakadu_converter_environment_variables}"

  ## KakaduConverter S3 bucket notification settings
  bucket_event = "${var.kakadu_converter_bucket_event}"
  trigger_s3_bucket_id = "${module.kakadu_converter_s3_tiff.bucket_id}"
  trigger_s3_bucket_arn = "${module.kakadu_converter_s3_tiff.bucket_arn}"


  subnet_ids         = data.terraform_remote_state.vpc.outputs.vpc_private_subnet_ids
  security_group_ids = [data.terraform_remote_state.vpc.outputs.sg_egress_id]
}

module "iiif_cloudfront" {
  source                  = "git::https://github.com/UCLALibrary/aws_terraform_cloudfront_module.git"
  app_origin_dns_name     = "${var.iiif_alb_dns_name}"
  app_public_dns_names    = "${var.iiif_public_dns_names}"
  app_origin_id           = "ALBOrigin-${var.iiif_alb_dns_name}"
  app_ssl_certificate_arn = "${var.iiif_cloudfront_ssl_certificate_arn}"
  app_path_pattern        = "${var.iiif_jpg_path_pattern}"
  app_price_class         = "${var.iiif_cloudfront_price_class}"
  default_ttl             = "${var.iiif_jpg_default_ttl}"
  max_ttl                 = "${var.iiif_jpg_max_ttl}"
}

