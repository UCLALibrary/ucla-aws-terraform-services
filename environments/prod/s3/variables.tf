variable "aws_region" {
  type = string
  default = "us-west-2"
}

variable "prod-iiif_cantaloupe_s3_cache_bucket" {
  type = string
  default = "cantaloupecachebucket"
}

variable "prod-iiif_cantaloupe_s3_source_bucket" {
  type = string
  default = "cantaloupesourcebucket"
}

variable "prod-iiif_fester_s3_source_bucket" {
  type = string
  default = "festersourcebucket"
}

variable "prod-sinai-iiif_cantaloupe_s3_cache_bucket" {
  type = string
  default = "cantaloupecachebucket"
}

variable "prod-sinai-iiif_cantaloupe_s3_source_bucket" {
  type = string
  default = "cantaloupesourcebucket"
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
  prod-iiif_cantaloupe_s3_src_bucket = "${var.bucket_prefix}-prod-cantaloupe-src" 
  prod-iiif_cantaloupe_s3_cache_bucket = "${var.bucket_prefix}-prod-cantaloupe-cache" 
  prod-iiif_fester_s3_source_bucket = "${var.bucket_prefix}-prod-fester-src" 
  prod-sinai-iiif_cantaloupe_s3_src_bucket = "${var.bucket_prefix}-sinai-cantaloupe-src" 
  prod-sinai-iiif_cantaloupe_s3_cache_bucket = "${var.bucket_prefix}-sinai-cantaloupe-cache" 
  kakadu_converter_s3_tiff_source_bucket = "${var.bucket_prefix}-kakaduconverter-tiff-src" 
}
