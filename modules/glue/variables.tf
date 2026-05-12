variable "environment" {
  type = string
}

variable "glue_role_arn" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "glue_max_capacity" {
  type    = number
  default = 2
}

variable "redshift_host" {
  type = string
}

variable "redshift_username" {
  type = string
}

variable "redshift_password" {
  type      = string
  sensitive = true
}

variable "availability_zone" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "redshift_security_group_id" {
  type = string
}

variable "glue_security_group_id" {
  type = string
}