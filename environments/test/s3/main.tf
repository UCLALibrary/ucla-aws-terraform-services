resource "aws_s3_bucket" "cantaloupe_source_bucket" {
  bucket = var.cantaloupe_s3_source_bucket != "" ? var.cantaloupe_s3_source_bucket : local.cantaloupe_s3_src_bucket
  region = var.aws_region
  force_destroy = var.force_destroy_src_bucket
  acl = "private"
}

resource "aws_s3_bucket" "cantaloupe_cache_bucket" {
  bucket = var.cantaloupe_s3_cache_bucket != "" ? var.cantaloupe_s3_cache_bucket : local.cantaloupe_s3_cache_bucket
  region = var.aws_region
  force_destroy = var.force_destroy_cache_bucket
  acl = "private"
}

resource "aws_s3_bucket" "fester_source_bucket" {
  bucket = var.fester_s3_source_bucket != "" ? var.fester_s3_source_bucket : local.fester_s3_source_bucket
  region = var.aws_region
  force_destroy = var.force_destroy_src_bucket
  acl = "private"
}

resource "aws_s3_bucket" "kakadu_converter_tiff_source_bucket" {
  bucket = var.kakadu_converter_s3_tiff_source_bucket != "" ? var.kakadu_converter_s3_tiff_source_bucket : local.kakadu_converter_s3_tiff_source_bucket
  region = var.kakadu_converter_s3_tiff_source_bucket_region
  acl = "private"
}
