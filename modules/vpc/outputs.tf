output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "subnet_ids" {
  value = data.aws_subnets.default.ids
}

output "s3_vpc_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}