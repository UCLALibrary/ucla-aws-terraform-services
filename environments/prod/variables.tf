variable "tfstate_bucket_name" {
  default = "services-terraform"
}

variable "cred_file" {
  default = "~/.aws/credentials/"
}

variable "cred_profile" {
  default = "default"
}

variable "region" {
  default = "us-west-2"
}

variable "vpc_cidr_block" {
  default = "172.20.0.0/16"
}

variable "subnet_count" {
  default = 2
}

variable "subnet_int" {
  default = 30
}

variable "vpc_main_id" {
  default = null
}

variable "alb_main_sg_id" {
  default = null
}

##########################################
### Fargate DockerHub Auth             ###
##########################################

variable "dockerauth_arn" {
  default = "arn:aws:iam::0123456789:policy/dockerauth"
}

variable "dockerhubauth_credentials_arn" {
  default = "arn:aws:iam::0123456789:policy/dockerauth"
}

###########################
### CANTALOUPE SETTINGS ###
###########################
variable "cantaloupe_endpoint_secret" {
  default = "changethissecret"
}

variable "iiif_app_name" {
  default = "iiif"
}

variable "cantaloupe_app_port" {
  default = 8182
}

variable "cantaloupe_memory" {
  default = 2048
}

variable "cantaloupe_cpu" {
  default = 1024
}

variable "cantaloupe_registry_url" {
  default = "registry.hub.docker.com/uclalibrary/cantaloupe-ucla:4.1.1"
}

variable "cantaloupe_source_static" {
  default = "FilesystemSource"
}

variable "s3_cache_bucket" {
  default = ""
}

variable "s3_cache_access_key" {
  default = ""
}

variable "s3_cache_secret_key" {
  default = ""
}

variable "s3_cache_endpoint" {
  default = "s3.us-west-2.amazonaws.com"
}

variable "s3_source_bucket" {
  default = ""
}

variable "s3_source_access_key" {
  default = ""
}

variable "s3_source_secret_key" {
  default = ""
}

variable "s3_source_endpoint" {
  default = "s3.us-west-2.amazonaws.com"
}

variable "cantaloupe_heapsize" {
  default = "2g"
}

variable "cantaloupe_enable_admin" {
  default = "true"
}

variable "cantaloupe_admin_secret" {
  default = "secretpassword"
}

variable "cantaloupe_enable_cache_server" {
  default = "false"
}

variable "cantaloupe_cache_server_derivative" {
  default = ""
}

variable "cantaloupe_cache_server_derivative_ttl" {
  default = "2592000"
}

variable "cantaloupe_cache_server_purge_missing" {
  default = "false"
}

variable "cantaloupe_processor_selection_strategy" {
  default = "AutomaticSelectionStrategy"
}

variable "cantaloupe_manual_processor_jp2" {
  default = "KakaduNativeProcessor"
}

variable "s3_source_basiclookup_suffix" {
  default = ""
}

variable "cantaloupe_healthcheck_path" {
  default = "/ping"
}

##########################################
### Fargate DockerHub Auth             ###
##########################################

variable "manifeststore_memory" {
  default = 2048
}

variable "manifeststore_cpu" {
  default = 1024
}

variable "manifeststore_app_port" {
  default = "8888"
}

variable "manifeststore_registry_url" {
  default = "registry.hub.docker.com/uclalibrary/manifest-store:latest"
}

variable "manifeststore_http_callback" {
  default = "http://localhost:8888/test-callback"
}

variable "manifeststore_s3_bucket" {
  default = "manifeststore"
}

variable "manifeststore_s3_access_key" {
  default = "changeme"
}

variable "manifeststore_s3_secret_key" {
  default = "changeme"
}

variable "manifeststore_s3_region" {
  default = "us-west-2"
}

variable "manifeststore_healthcheck_path" {
  default = "/ping"
}

variable "manifeststore_openspec_path" {
  default = "manifeststore.yaml"
}

variable "ecs_execution_role_arn" {
  default = ""
}

variable "http_listener_arn" {
  default = ""
}

