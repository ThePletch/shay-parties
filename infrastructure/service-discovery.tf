resource "aws_service_discovery_public_dns_namespace" "main" {
  name = "sd.${var.root_domain}"
  description = "Service Discovery namespace for Parties for All"
}

resource "aws_service_discovery_service" "main" {
  name = "partiesforall"

  dns_config {
    namespace_id = aws_service_discovery_public_dns_namespace.main.id

    dns_records {
      ttl = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
}