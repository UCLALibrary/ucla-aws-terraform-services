output "cantaloupe_source_bucket_arn" {
  value = aws_s3_bucket.cantaloupe_source_bucket.arn
}

output "cantaloupe_source_bucket_id" {
  value = aws_s3_bucket.cantaloupe_source_bucket.id
}

output "cantaloupe_cache_bucket_arn" {
  value = aws_s3_bucket.cantaloupe_cache_bucket.arn
}

output "cantaloupe_cache_bucket_id" {
  value = aws_s3_bucket.cantaloupe_cache_bucket.id
}

output "fester_source_bucket_arn" {
  value = aws_s3_bucket.fester_source_bucket.arn
}

output "fester_source_bucket_id" {
  value = aws_s3_bucket.fester_source_bucket.id
}

output "kakadu_converter_tiff_source_bucket_arn" {
  value = aws_s3_bucket.kakadu_converter_tiff_source_bucket.arn
}

output "kakadu_converter_tiff_source_bucket_id" {
  value = aws_s3_bucket.kakadu_converter_tiff_source_bucket.id
}
