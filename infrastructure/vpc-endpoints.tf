# IPv6-native subnets rely on VPC endpoints for AWS services that do not publish
# reachable IPv6 endpoints. Without an S3 gateway endpoint, Active Storage blocks
# request threads on synchronous S3 reads during direct-upload attachment.
# Default ip_address_type is ipv4; dualstack is required so IPv6 routes/prefix lists
# are installed and dualstack S3 hostnames are steered through the endpoint.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  ip_address_type   = "dualstack"
  route_table_ids   = [aws_route_table.public.id]

  tags = {
    Name = "${var.name}-s3"
  }
}
