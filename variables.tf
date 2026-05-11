variable "aws_region" {
  default = "us-east-1"
}

variable "aws_profile" {}

variable "environment" {}

variable "vpc_cidr" {}

variable "bucket_name" {}

variable "postgres_endpoint" {}
variable "postgres_username" {}
variable "postgres_password" {}

variable "redshift_username" {}
variable "redshift_password" {}