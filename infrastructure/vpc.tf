data "aws_availability_zones" "all_azs" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public" {
  count             = length(data.aws_availability_zones.all_azs.names)
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.all_azs.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index)
}