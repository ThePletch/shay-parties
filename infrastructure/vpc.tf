data "aws_availability_zones" "all_azs" {
  state = "available"
}

resource "aws_vpc" "main" {
  # AWS still requires an IPv4 CIDR on the VPC even for IPv6-only workloads;
  # IPv6-only is enforced at the subnet layer via ipv6_native = true.
  cidr_block                       = var.vpc_cidr
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true
  enable_dns_support               = true

  tags = {
    Name = "partiesforall-${var.environment}"
  }
}

resource "aws_subnet" "public" {
  for_each = toset(data.aws_availability_zones.all_azs.names)
  vpc_id            = aws_vpc.main.id
  availability_zone = each.value
  ipv6_native = true
  ipv6_cidr_block = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, index(data.aws_availability_zones.all_azs.names, each.value))
  assign_ipv6_address_on_creation = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  enable_dns64 = true
  private_dns_hostname_type_on_launch = "resource-name"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "public_igw_ipv6" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
  destination_ipv6_cidr_block = "::/0"
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "http" {
  name   = "${var.name}-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port        = var.internal_port
    to_port          = var.internal_port
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
    cidr_blocks = ["0.0.0.0/0"]
  }
}