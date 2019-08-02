terraform {
  backend "remote" {}
}

provider "aws" {
  shared_credentials_file = "${var.cred_file}"
  profile                 = "${var.cred_profile}"
  region                  = "${var.region}"
}

module "vpc" {
  source            = "../../modules/vpc"
  vpc_cidr_block    = "${var.vpc_cidr_block}"
  subnet_count      = "${var.subnet_count}"
  subnet_int        = "${var.subnet_int}"
}

module "alb" {
  source         = "../../modules/alb"
  app_name       = "${var.iiif_app_name}"
  vpc_main_id    = "${module.vpc.vpc_main_id}"
  vpc_subnet_ids = "${module.vpc.vpc_subnet_ids}"

### Not available yet ###
#  depends_on = [
#  "vpc"
#  ]
}

module "fargate_iam_policies" {
  source         = "../../modules/fargate_iam_policies"
  dockerauth_arn = "${var.dockerauth_arn}"
  app_name       = "${var.iiif_app_name}"
}

module "cantaloupe" {
  source                                  = "../../modules/cantaloupe"
  vpc_main_id                             = "${module.vpc.vpc_main_id}"
  vpc_subnet_ids                          = "${module.vpc.vpc_subnet_ids}"
  alb_main_id                             = "${module.alb.alb_main_id}"
  alb_main_sg_id                          = "${module.alb.alb_main_sg_id}"
  app_port                                = "${var.cantaloupe_app_port}"
  registry_url                            = "${var.cantaloupe_registry_url}"
  app_name                                = "${var.iiif_app_name}"
  app_ssl_certificate_arn                 = "${var.iiif_app_ssl_cert_arn}"
  cantaloupe_cpu                          = "${var.cantaloupe_cpu}"
  cantaloupe_memory                       = "${var.cantaloupe_memory}"
  ecs_execution_role_arn                  = "${module.fargate_iam_policies.ecs_execution_role_arn}"
  dockerhubauth_credentials_arn           = "${var.dockerhubauth_credentials_arn}"
  cantaloupe_processor_selection_strategy = "${var.cantaloupe_processor_selection_strategy}"
  cantaloupe_manual_processor_jp2         = "${var.cantaloupe_manual_processor_jp2}"
  cantaloupe_enable_admin                 = "${var.cantaloupe_enable_admin}"
  cantaloupe_admin_secret                 = "${var.cantaloupe_admin_secret}"
  s3_source_basiclookup_suffix            = "${var.s3_source_basiclookup_suffix}"
  cantaloupe_heapsize                     = "${var.cantaloupe_heapsize}"
  cantaloupe_enable_cache_server          = "${var.cantaloupe_enable_cache_server}"
  cantaloupe_cache_server_derivative      = "${var.cantaloupe_cache_server_derivative}"
  cantaloupe_cache_server_derivative_ttl  = "${var.cantaloupe_cache_server_derivative_ttl}"
  cantaloupe_cache_server_purge_missing   = "${var.cantaloupe_cache_server_purge_missing}"
  s3_cache_access_key                     = "${var.s3_cache_access_key}"
  s3_cache_secret_key                     = "${var.s3_cache_secret_key}"
  s3_cache_bucket                         = "${var.s3_cache_bucket}"
  s3_cache_endpoint                       = "${var.s3_cache_endpoint}"
  cantaloupe_source_static                = "${var.cantaloupe_source_static}"
  s3_source_access_key                    = "${var.s3_source_access_key}"
  s3_source_secret_key                    = "${var.s3_source_secret_key}"
  s3_source_bucket                        = "${var.s3_source_bucket}"
  s3_source_endpoint                      = "${var.s3_source_endpoint}"

### Not available yet ###
#  depends_on = [
#  "module.vpc",
#  "module.alb",
#  "module.fargate_iam_policies"
#  ]
}

module "manifeststore" {
  source                           = "../../modules/manifeststore"
  vpc_main_id                      = "${module.vpc.vpc_main_id}"
  vpc_subnet_ids                   = "${module.vpc.vpc_subnet_ids}"
  alb_main_id                      = "${module.alb.alb_main_id}"
  alb_main_sg_id                   = "${module.alb.alb_main_sg_id}"
  app_port                         = "${var.manifeststore_app_port}"
  registry_url                     = "${var.manifeststore_registry_url}"
  app_name                         = "${var.iiif_app_name}"
  manifeststore_cpu                = "${var.manifeststore_cpu}"
  manifeststore_memory             = "${var.manifeststore_memory}"
  manifeststore_s3_bucket          = "${var.manifeststore_s3_bucket}"
  manifeststore_s3_access_key      = "${var.manifeststore_s3_access_key}"
  manifeststore_s3_secret_key      = "${var.manifeststore_s3_secret_key}"
  manifeststore_s3_region          = "${var.manifeststore_s3_region}"
  ecs_execution_role_arn           = "${module.fargate_iam_policies.ecs_execution_role_arn}"
  dockerhubauth_credentials_arn    = "${var.dockerhubauth_credentials_arn}"
  http_listener_arn                = "${module.cantaloupe.https_listener_arn}"

### Not available yet ###
#  depends_on = [
#  "module.vpc",
#  "module.alb",
#  "module.fargate_iam_policies",
#  "module.cantaloupe"
#  ]
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
}

module "iiif_cloudfront" {
  source                  = "git::https://github.com/UCLALibrary/aws_terraform_cloudfront_module.git?ref=IIIF-325"
  app_origin_dns_name     = "${var.iiif_alb_dns_name}"
  app_public_dns_names    = "${var.iiif_public_dns_names}"
  app_origin_id           = "ALBOrigin-${var.iiif_alb_dns_name}"
  app_ssl_certificate_arn = "${var.iiif_cloudfront_ssl_certificate_arn}"
  app_path_pattern        = "${var.iiif_thumbnail_path_pattern}"
  app_price_class         = "${var.iiif_cloudfront_price_class}"
}

