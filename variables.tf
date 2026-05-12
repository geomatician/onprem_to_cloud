variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "postgres_endpoint" {
  type = string
}

variable "postgres_username" {
  type = string
}

variable "postgres_password" {
  type = string
}

variable "redshift_username" {
  type = string
}

variable "redshift_password" {
  type = string
}

variable "redshift_endpoint" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}