resource "aws_s3_bucket" "stage-iiif_cantaloupe_cache_bucket" {
  bucket = var.stage-iiif_cantaloupe_s3_cache_bucket != "" ? var.stage-iiif_cantaloupe_s3_cache_bucket : local.stage-iiif_cantaloupe_s3_cache_bucket
  region = var.aws_region
  force_destroy = var.force_destroy_cache_bucket
  acl = "private"
}

resource "aws_s3_bucket" "stage-iiif_fester_source_bucket" {
  bucket = var.stage-iiif_fester_s3_source_bucket != "" ? var.stage-iiif_fester_s3_source_bucket : local.stage-iiif_fester_s3_source_bucket
  region = var.aws_region
  force_destroy = var.force_destroy_src_bucket
  acl = "private"
}
