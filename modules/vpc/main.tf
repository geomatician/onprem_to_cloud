resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.this.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 1)
}