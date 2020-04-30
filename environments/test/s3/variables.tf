variable "aws_region" {
  type = string
  default = "us-west-2"
}

variable "cantaloupe_s3_cache_bucket" {
  type = string
  default = "cantaloupecachebucket"
}

variable "cantaloupe_s3_source_bucket" {
  type = string
  default = "cantaloupesourcebucket"
}

variable "fester_s3_source_bucket" {
  type = string
  default = "festersourcebucket"
}

variable "kakadu_converter_s3_tiff_source_bucket" {
  type = string
  default = "tiffconverterbucket"
}

variable "kakadu_converter_s3_tiff_source_bucket_region" {
  type = string
  default = "us-west-2"
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
  cantaloupe_s3_src_bucket = "${var.bucket_prefix}-cantaloupe-src" 
  cantaloupe_s3_cache_bucket = "${var.bucket_prefix}-cantaloupe-cache" 
  fester_s3_source_bucket = "${var.bucket_prefix}-fester-src" 
  kakadu_converter_s3_tiff_source_bucket = "${var.bucket_prefix}-kakaduconverter-tiff-src" 
}
