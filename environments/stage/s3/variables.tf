variable "aws_region" {
  type = string
  default = "us-west-2"
}

variable "stage-iiif_cantaloupe_s3_cache_bucket" {
  type = string
  default = "cantaloupecachebucket"
}

variable "stage-iiif_cantaloupe_s3_source_bucket" {
  type = string
  default = "cantaloupesourcebucket"
}

variable "stage-iiif_fester_s3_source_bucket" {
  type = string
  default = "festersourcebucket"
}

variable "force_destroy_src_bucket" {
  type = string
  default = "false"
}

variable "force_destroy_cache_bucket" {
  type = string
  default = "false"
}

variable "bucket_prefix" {
  type = string
  default = "your-app"
}

locals {
  stage-iiif_cantaloupe_s3_src_bucket = "${var.bucket_prefix}-stage-cantaloupe-src" 
  stage-iiif_cantaloupe_s3_cache_bucket = "${var.bucket_prefix}-stage-cantaloupe-cache" 
  stage-iiif_fester_s3_source_bucket = "${var.bucket_prefix}-stage-fester-src" 
}
