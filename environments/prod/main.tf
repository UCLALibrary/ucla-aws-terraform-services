terraform {
  backend "s3" {
    bucket = "softwaredev-services-terraform"
    key    = "test-cantaloupe/terraform.tfstate"
    region = "us-west-2"
    profile = "services"
  }
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
  app_port                                = "${var.iiif_app_port}"
  registry_url                            = "${var.cantaloupe_registry_url}"
  app_name                                = "${var.iiif_app_name}"
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
}

module "load_balancer_mapping" {
  source                        = "../../modules/load_balancer_mapping"
  cantaloupe_target_group_id    = "${module.cantaloupe.cantaloupe_target_group_id}"
  manifeststore_target_group_id = "${module.cantaloupe.cantaloupe_target_group_id}"
}

