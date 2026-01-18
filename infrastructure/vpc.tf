data "aws_availability_zones" "all_azs" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "partiesforall-${var.environment}"
  }
}

resource "aws_subnet" "public" {
  for_each = toset(data.aws_availability_zones.all_azs.names)
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, index(data.aws_availability_zones.all_azs.names, each.key))
  ipv6_cidr_block = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, index(data.aws_availability_zones.all_azs.names, each.key))
  assign_ipv6_address_on_creation = true
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
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}