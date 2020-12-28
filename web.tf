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

locals {
  src_dir      = "${path.module}/app"
  content_type_map = {
    html        = "text/html",
    js          = "application/javascript",
    css         = "text/css",
    svg         = "image/svg+xml",
    jpg         = "image/jpeg",
    ico         = "image/x-icon",
    png         = "image/png",
    gif         = "image/gif",
    pdf         = "application/pdf"
  }
}

resource "aws_s3_bucket_object" "web_s3_upload" {
  depends_on = [aws_s3_bucket.frontend]
  for_each = fileset(local.src_dir, "**/*")

  bucket = var.bucket_name
  key    = each.value
  source = "${path.module}/app/${each.value}"
  etag = filemd5("${path.module}/app/${each.value}")
  // content_type = "text/html"
  content_type  = lookup(local.content_type_map, regex("\\.(?P<extension>[A-Za-z0-9]+)$", each.value).extension, "application/octet-stream")
}


resource "aws_cloudfront_distribution" "frontend" {
  depends_on = [aws_s3_bucket_object.web_s3_upload]
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

output "static_web" {
  value = aws_cloudfront_distribution.frontend.domain_name
}


