locals {
  main_domain = var.main_subdomain == "" ? var.root_domain : "${var.main_subdomain}.${var.root_domain}"
  cdn_origin  = "PartiesServiceDiscovery"
  aliases = concat([for alias in var.alias_subdomains : "${alias}.${var.root_domain}"], var.include_root_domain_alias ? [var.root_domain] : [])
  aliases_with_main        = concat([local.main_domain], local.aliases)
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
  aliases        = local.aliases_with_main
  hosted_zone_id = data.aws_route53_zone.root_domain.zone_id
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled = true
  is_ipv6_enabled = true
  http_version = "http2and3"
  price_class = "PriceClass_100"

  aliases = local.aliases_with_main

  default_cache_behavior {
    # Managed "disable all caching" policy
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    # this is a read-write site, all methods allowed
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = local.cdn_origin
    viewer_protocol_policy = "redirect-to-https"
    # Managed "forward all parameters" policy
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  }

  origin {
    origin_id   = local.cdn_origin
    domain_name = "${var.service_discovery_subdomain}.${local.service_discovery_domain}"

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = var.internal_port
      https_port             = 443
      origin_ssl_protocols   = ["SSLv3","TLSv1","TLSv1.1","TLSv1.2"]
      ip_address_type = "ipv6"
    }
  }

  viewer_certificate {
    acm_certificate_arn = module.certificate.arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.3_2025"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}

resource "aws_route53_record" "cdn_aliases" {
  for_each = toset(local.aliases_with_main)
  zone_id = data.aws_route53_zone.root_domain.zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}