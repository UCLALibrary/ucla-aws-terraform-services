variable "alb_main_id" {
  default = null
}

variable "app_port" {
  default = 8182
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

variable "container_count" {
  default = 1
}

variable "manifeststore_cpu" {
  default = 1024
}

variable "manifeststore_memory" {
  default = 2048
}

variable "manifeststore_source_static" {
  default = "FilesystemSource"
}

variable "s3_source_endpoint" {
  default = "s3.us-west-2.amazonaws.com"
}

variable "s3_cache_endpoint" {
  default = "s3.us-west-2.amazonaws.com"
}

variable "s3_cache_access_key" {
  default = ""
}

variable "s3_cache_secret_key" {
  default = ""
}

variable "s3_source_access_key" {
  default = ""
}
variable "s3_source_secret_key" {
  default = ""
}

variable "s3_source_bucket" {
  default = ""
}

variable "s3_cache_bucket" {
  default = ""
}

variable "manifeststore_heapsize" {
  default = "2g"
}

variable "manifeststore_enable_admin" {
  default = "true"
}

variable "manifeststore_admin_secret" {
  default = "secretpassword"
}

variable "manifeststore_enable_cache_server" {
  default = "false"
}

variable "manifeststore_cache_server_derivative" {
  default = ""
}

variable "manifeststore_cache_server_derivative_ttl" {
  default = "2592000"
}

variable "manifeststore_cache_server_purge_missing" {
  default = "false"
}

variable "manifeststore_processor_selection_strategy" {
  default = "AutomaticSelectionStrategy"
}

variable "manifeststore_manual_processor_jp2" {
  default = "KakaduNativeProcessor"
}

variable "s3_source_basiclookup_suffix" {
  default = ""
}

variable "alb_main_sg_id" {
  default = null
}

variable "dockerauth_arn" {
  default = "arn:aws:iam::0123456789:policy/dockerhubauth"
}

variable "dockerhubauth_credentials_arn" {
  default = "arn:aws:iam::0123456789:policy/dockerhubauthcredentials"
}
