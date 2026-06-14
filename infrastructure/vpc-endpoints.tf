# IPv6-native subnets rely on VPC endpoints for AWS services that do not publish
# reachable IPv6 endpoints. Without an S3 gateway endpoint, Active Storage blocks
# request threads on synchronous S3 reads during direct-upload attachment.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.public.id]

  tags = {
    Name = "${var.name}-s3"
  }
}
