resource "aws_s3_bucket" "prod-iiif_cantaloupe_source_bucket" {
  bucket = var.prod-iiif_cantaloupe_s3_source_bucket != "" ? var.prod-iiif_cantaloupe_s3_source_bucket : local.prod-iiif_cantaloupe_s3_src_bucket
  region = var.aws_region
  force_destroy = var.force_destroy_src_bucket
  acl = "private"
}

resource "aws_s3_bucket" "prod-iiif_cantaloupe_cache_bucket" {
  bucket = var.prod-iiif_cantaloupe_s3_cache_bucket != "" ? var.prod-iiif_cantaloupe_s3_cache_bucket : local.prod-iiif_cantaloupe_s3_cache_bucket
  region = var.aws_region
  force_destroy = var.force_destroy_cache_bucket
  acl = "private"
}

resource "aws_s3_bucket" "prod-iiif_fester_source_bucket" {
  bucket = var.prod-iiif_fester_s3_source_bucket != "" ? var.prod-iiif_fester_s3_source_bucket : local.prod-iiif_fester_s3_source_bucket
  region = var.aws_region
  force_destroy = var.force_destroy_src_bucket
  acl = "private"
}

resource "aws_s3_bucket" "prod-sinai-iiif_cantaloupe_source_bucket" {
  bucket = var.prod-sinai-iiif_cantaloupe_s3_source_bucket != "" ? var.prod-sinai-iiif_cantaloupe_s3_source_bucket : local.prod-sinai-iiif_cantaloupe_s3_src_bucket
  region = var.aws_region
  force_destroy = var.force_destroy_src_bucket
  acl = "private"
}

resource "aws_s3_bucket" "prod-sinai-iiif_cantaloupe_cache_bucket" {
  bucket = var.prod-sinai-iiif_cantaloupe_s3_cache_bucket != "" ? var.prod-sinai-iiif_cantaloupe_s3_cache_bucket : local.prod-sinai-iiif_cantaloupe_s3_cache_bucket
  region = var.aws_region
  force_destroy = var.force_destroy_cache_bucket
  acl = "private"
}

resource "aws_s3_bucket" "kakadu_converter_tiff_source_bucket" {
  bucket = var.kakadu_converter_s3_tiff_source_bucket != "" ? var.kakadu_converter_s3_tiff_source_bucket : local.kakadu_converter_s3_tiff_source_bucket
  region = var.kakadu_converter_s3_tiff_source_bucket_region
  acl = "private"
}
