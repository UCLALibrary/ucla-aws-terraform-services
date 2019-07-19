variable "manifeststore_memory" {
  default = 2048
}

variable "manifeststore_cpu" {
  default = 1024
}

variable "manifeststore_app_port" {
  default = "8888"
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

variable "container_count" {
  default = 1
}

variable "alb_main_id" {
  default = null
}

variable "app_port" {
  default = 8888
}

variable "vpc_main_id" {
  default = null
}

variable "vpc_subnet_ids" {
  default = null
}

variable "app_name" {
  default = "manifeststore"
}

variable "registry_url" {
  default = "registry.hub.docker.com/uclalibrary/manifest-store:latest"
}

variable "alb_main_sg_id" {
  default = null
}

variable "ecs_execution_role_arn" {
  default = ""
}

variable "dockerhubauth_credentials_arn" {
  default = "arn:aws:iam::0123456789:policy/dockerhubauthcredentials"
}

variable "http_listener_arn" {
  default = ""
}

