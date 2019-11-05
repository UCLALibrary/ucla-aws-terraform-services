# AWS Setup
variable "region" { default = "us-west-2" }
variable "aws_profile" { default = "default" }

# Needed to reference remote state VPC networks
variable "terraform_remote_hostname" {}
variable "terraform_remote_token" {}
variable "terraform_remote_organization" {}
variable "terraform_remote_networking_workspace" {}

### Name schemes and ARNS
variable "iiif_app_name" {}
variable "iiif_app_ssl_cert_arn" {}

# Fargate ECS IAM Configurations(required)
variable "dockerhub_credentials_secrets_arn" { default = "" }
variable "fargate_ecs_task_execution_role_arn" { default = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy" }

# Flag to destroy src buckets
variable "force_destroy_src_bucket" { default = "false" }
variable "force_destroy_cache_bucket" { default = "false" }

# Fargate IIIF Settings
variable "container_host_memory" { default = "2048" }
variable "container_host_cpu" { default = "1024" }
variable "disable_load_balancer" { default = 0 }
variable "enable_load_balancer" { default = 0 }
variable "container_count" { default = 1 }
variable "assign_public_ip" { default = true }
variable "target_group_arn" { default = null }

# Cantaloupe Environment Variables
variable "cantaloupe_memory" { default = "2048" }
variable "cantaloupe_cpu" { default = "1024" }
variable "cantaloupe_listening_port" { default = 8182 }
variable "cantaloupe_image_url" { default = "registry.hub.docker.com/uclalibrary/cantaloupe:4.1.3" }
variable "cantaloupe_enable_admin" { default = "true" }
variable "cantaloupe_admin_secret" { default = "secretpassword" }
variable "cantaloupe_enable_cache_server" { default = "false" }
variable "cantaloupe_cache_server_derivative" { default = "S3Cache" }
variable "cantaloupe_cache_server_derivative_ttl" { default = "0" }
variable "cantaloupe_cache_server_purge_missing" { default = "true" }
variable "cantaloupe_processor_selection_strategy" { default = "ManualSelectionStrategy" }
variable "cantaloupe_manual_processor_jp2" { default = "KakaduNativeProcessor" }
variable "cantaloupe_s3_cache_access_key" { default = "something" }
variable "cantaloupe_s3_cache_secret_key" { default = "something" }
variable "cantaloupe_s3_cache_endpoint" { default = "us-west-2" }
variable "cantaloupe_s3_cache_bucket" { default = "something" }
variable "cantaloupe_s3_source_access_key" { default = "something" }
variable "cantaloupe_s3_source_secret_key" { default = "something" }
variable "cantaloupe_s3_source_endpoint" { default = "us-west-2" }
variable "cantaloupe_s3_source_bucket" { default = "" }
variable "cantaloupe_s3_source_basiclookup_suffix" { default = ".jpx" }
variable "cantaloupe_source_static" { default = "S3Source" }
variable "cantaloupe_heapsize" { default = "2g" }
variable "cantaloupe_healthcheck_path" { default = "/iiif/2" }
variable "cantaloupe_delegate_path" { default = "/usr/local/cantaloupe/delegates.rb" }
variable "cantaloupe_delegate_enabled" { default = "true" }
variable "cantaloupe_source_delegate" { default = "true" }
variable "delegate_url" { default = "https://raw.githubusercontent.com/UCLALibrary/cantaloupe-delegate/master/lib/delegates.rb" }
variable "cipher_text" { default = "text" }
variable "cipher_key" { default = "key" }

# Manifeststore environment variables
variable "manifeststore_memory" { default = "1024" }
variable "manifeststore_cpu" { default = "1024" }
variable "manifeststore_listening_port" { default = 8183 }
variable "manifeststore_image_url" { default = "registry.hub.docker.com/uclalibrary/manifest-store:latest" }
variable "manifeststore_healthcheck_path" { default = "/status/manifest-store" }
variable "manifeststore_s3_bucket" { default = "" }
variable "manifeststore_s3_access_key" { default = "" }
variable "manifeststore_s3_secret_key" { default = "" }
variable "manifeststore_s3_region" { default = "" }

## KakaduConverter Variables
variable kakadu_converter_s3_tiff_bucket {}
variable kakadu_converter_s3_tiff_bucket_region { default = "us-west-2"}
variable kakadu_converter_artifact {}
variable kakadu_converter_app_name {}
variable kakadu_converter_layers {}
variable kakadu_converter_handler {}
variable kakadu_converter_filter_suffix {}
variable kakadu_converter_runtime {}
variable kakadu_converter_memory_size { default = "1024"}
variable kakadu_converter_timeout { default = "600" }
variable kakadu_converter_environment_variables {
  type = "map"
  default = {
    hello = "world",
    hello2 = "world2"
  }
}
variable kakadu_converter_cloudwatch_permissions {}
variable kakadu_converter_s3_permissions {}
variable kakadu_converter_s3_buckets {}
variable kakadu_converter_bucket_event {} 

# CloudFront Settings
variable iiif_alb_dns_name {}
variable iiif_public_dns_names {}
variable iiif_jpg_path_pattern {}
variable iiif_cloudfront_ssl_certificate_arn {}
variable iiif_cloudfront_price_class {}
variable iiif_jpg_default_ttl {}
variable iiif_jpg_max_ttl {}

# VPN IPs
variable "vpn_ips" {
  default = [
    "128.97.224.0/24",
    "128.97.228.0/24",
    "128.97.232.0/24",
    "128.97.234.0/24",
    "128.97.244.0/23",
    "128.97.247.0/24",
    "128.97.248.0/24",
    "149.142.26.0/24",
    "149.142.224.0/23",
    "164.67.62.0/27",
    "164.67.62.80/28",
    "164.67.62.96/28",
    "169.232.224.0/23",
    "164.67.152.0/24"
  ]
}

locals {
  fargate_ecs_role_name    = "${var.iiif_app_name}-fargate-ecs-role"
  fargate_cluster_name     = "${var.iiif_app_name}-fargate-cluster"
  fargate_service_name     = "${var.iiif_app_name}-fargate-service"
  fargate_definition_name  = "${var.iiif_app_name}-fargate-definition"
  cantaloupe_s3_src_bucket = "${var.iiif_app_name}-src-bucket"
  sg_name                  = "${var.iiif_app_name}-security-group"
  fargate_associate_tg     = [
    {
      arn = "${aws_lb_target_group.cantaloupe_tg.arn}"
      container_name = "${local.fargate_definition_name}-cantaloupe"
      container_port = "${var.cantaloupe_listening_port}"
    },
    {
      arn = "${aws_lb_target_group.manifeststore_tg.arn}"
      container_name = "${local.fargate_definition_name}-manifeststore"
      container_port = "${var.manifeststore_listening_port}"
    }
  ]
}

