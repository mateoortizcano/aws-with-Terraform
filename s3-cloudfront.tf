provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_s3_bucket" "bucket-web-content" {
  bucket = "proteccion-web-profilling"
  acl    = "public-read"
  versioning {
    enabled = true
  }
  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 1
    }
  }
  website {
    index_document = "index.html"
  }
}

locals {
  s3_origin_id = "s3Profilling"
}

resource "aws_cloudfront_distribution" "profilling-distribution" {
  origin {
    domain_name = "${aws_s3_bucket.bucket-web-content.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"
  }
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
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
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "CO"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
