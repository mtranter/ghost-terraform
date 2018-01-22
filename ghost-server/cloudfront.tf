
resource "aws_cloudfront_distribution" "ghost-blog" {
  origin {
    domain_name = "${aws_elb.ghost.dns_name}"
    origin_id   = "${var.name}-origin"

    custom_origin_config {
      http_port                 = 80
      https_port                = 443
      origin_protocol_policy    = "https-only"
      origin_ssl_protocols      = ["SSLv3"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "/"

  lifecycle {
    prevent_destroy = true
  }

  aliases = ["${var.domain_name}", "www.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods   = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods    = ["GET", "HEAD"]
    target_origin_id  = "${var.name}-origin"
    compress          = true

    forwarded_values {
      query_string  = true
      headers       = ["*"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  tags {
    Environment = "${var.name}-production"
  }

  restrictions {
    geo_restriction {
      restriction_type  = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${var.cloudfront_ssl_acm_arn}"
    ssl_support_method  = "sni-only"
  }
}
