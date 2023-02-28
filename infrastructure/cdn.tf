locals {
  main_domain = "${var.main_subdomain}.${var.root_domain}"
  cdn_origin  = "PartiesServiceDiscovery"
}

# you need to use this one for the ACM cert because Cloudfront is xenophobic
provider "aws" {
  alias  = "northern_virginia"
  region = "us-east-1"
}

data "aws_route53_zone" "root_domain" {
  name = "${var.root_domain}."
}

module "certificate" {
  source = "git@github.com:ThePletch/infrastructure.git//modules/ssl-cert"
  providers = {
    aws = aws.northern_virginia
  }

  domain_name    = local.main_domain
  hosted_zone_id = data.aws_route53_zone.root_domain.zone_id
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled = true

  aliases = [local.main_domain]

  default_cache_behavior {
    # Managed "disable all caching" policy
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    # this is a read-write site, all methods allowed
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["HEAD", "GET", "OPTIONS"]
    target_origin_id       = local.cdn_origin
    viewer_protocol_policy = "allow-all"
  }

  origin {
    origin_id   = local.cdn_origin
    domain_name = "${local.service_discovery_service_name}.${var.root_domain}"

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = var.internal_port
      https_port             = var.internal_port
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = module.certificate.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}

resource "aws_route53_record" "cdn" {
  zone_id = data.aws_route53_zone.root_domain.zone_id
  name    = local.main_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}