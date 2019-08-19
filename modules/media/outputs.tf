output "bucket_arn" {
  value = "${aws_s3_bucket.media.arn}"
}

output "cloudfront_domain_name" {
  value = "${aws_cloudfront_distribution.media_cfdist.domain_name}"
}
