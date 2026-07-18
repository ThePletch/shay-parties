locals {
  service_discovery_domain = "sdtest.${var.main_subdomain}.${var.root_domain}"
}
data "aws_iam_policy_document" "discovery_hook_policy" {
  statement {
    actions = [
      "ec2:DescribeNetworkInterfaces",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = [
      data.aws_route53_zone.root_domain.arn,
    ]
  }
}

resource "aws_service_discovery_public_dns_namespace" "public_ipv6" {
  name = local.service_discovery_domain
}

data "aws_route53_zone" "service_discovery_namespace" {
  zone_id = aws_service_discovery_public_dns_namespace.public_ipv6.hosted_zone
}

// route subdomain traffic to the SD namespace instead
resource "aws_route53_record" "subdomain_routing" {
  zone_id = data.aws_route53_zone.root_domain.zone_id
  type = "NS"
  name = local.service_discovery_domain
  ttl = 172800
  records = data.aws_route53_zone.service_discovery_namespace.name_servers
}

resource "aws_service_discovery_service" "public" {
  name = var.service_discovery_subdomain

  dns_config {
    namespace_id = aws_service_discovery_public_dns_namespace.public_ipv6.id

    dns_records {
      ttl = 30
      type = "AAAA"
    }
  }
}