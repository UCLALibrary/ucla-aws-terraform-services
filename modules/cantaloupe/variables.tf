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
  default = "cantaloupe"
}

variable "registry_url" {
  default = "registry.hub.docker.com/uclalibrary/cantaloupe:latest"
}

variable "container_count" {
  default = 1
}

variable "cantaloupe_cpu" {
  default = 1024
}

variable "cantaloupe_memory" {
  default = 2048
}

variable "s3_source_endpoint" {
  default = "us-west-2"
}

variable "s3_cache_endpoint" {
  default = "us-west-2"
}

variable "s3_cache_access_key" {
  default = "dummyval"
}

variable "s3_cache_secret_key" {
  default = "dummyval"
}

variable "s3_source_access_key" {
  default = "dummyval"
}
variable "s3_source_secret_key" {
  default = "dummyval"
}

variable "s3_source_bucket" {
  default = "dummy-cantaloupe-source-bucket"
}

variable "s3_cache_bucket" {
  default = "dummy-cantaloupe-cache-bucket"
}

variable "cantaloupe_heapsize" {
  default = "2g"
}

variable "alb_main_sg_id" {
  default = null
}
