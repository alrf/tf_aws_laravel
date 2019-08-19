resource "aws_s3_bucket" "media" {
  bucket        = "${var.bucket_name}"
  acl           = "private"
  force_destroy = true

  tags = {
    Name        = "${var.app_name} Media Bucket"
    Environment = "${var.environment_name}"
  }
}

resource "aws_s3_bucket_object" "content" {
  bucket       = "${aws_s3_bucket.media.bucket}"
  acl          = "private"
  key          = "content/"
  source       = "/dev/null"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "hello" {
  bucket = "${aws_s3_bucket.media.bucket}"
  key    = "content/Hello.txt"
  source = "app/storage/app/public/images/Hello.txt"
  etag   = "${filemd5("app/storage/app/public/images/Hello.txt")}"
}

resource "aws_s3_bucket_object" "logo" {
  bucket = "${aws_s3_bucket.media.bucket}"
  key    = "content/logo.jpg"
  source = "app/storage/app/public/images/logo.jpg"
  acl    = "public-read"
  etag   = "${filemd5("app/storage/app/public/images/logo.jpg")}"
}

locals {
  s3_origin_id = "primaryS3origin"
}

resource "aws_cloudfront_distribution" "media_cfdist" {
  origin {
    domain_name = "${aws_s3_bucket.media.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"
  }

  enabled = true

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  tags = {
    Environment = "${var.environment_name}"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
