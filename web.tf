provider "aws" {
  region = "eu-west-1"
  // Profile configuration in ~/.aws/credentials
  profile = "my.kotless.user"
}

data "aws_iam_policy_document" "bucket_policy_site" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
    principals {
      identifiers = ["*"]
      type = "AWS"
    }
  }
}


resource "aws_s3_bucket" "frontend" {
  bucket = var.bucket_name
  acl = "public-read"
  policy = data.aws_iam_policy_document.bucket_policy_site.json

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

//resource "aws_s3_bucket_object" "index_file" {
//  depends_on = [aws_s3_bucket.frontend]
//  bucket = var.bucket_name
//  key    = "index.html"
//  source = "${path.module}/app/index.html"
//  content_type = "text/html"
//}

resource "aws_s3_bucket_object" "test" {
  for_each = fileset("${path.module}/app", "**/*")

  bucket = var.bucket_name
  key    = each.value
  source = "${path.module}/app/${each.value}"
  // content_type = "text/html"
}


resource "aws_cloudfront_distribution" "frontend" {
  depends_on = [aws_s3_bucket_object.test ]
  origin {
    domain_name = aws_s3_bucket.frontend.bucket_domain_name
    origin_id   = var.bucket_name
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.bucket_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    compress = true
    viewer_protocol_policy = "redirect-to-https"
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


output "fileset-results" {
  value = fileset("${path.module}/app", "**/*")
}

output "bucket_domain" {
  value = aws_s3_bucket.frontend.bucket_domain_name
}


