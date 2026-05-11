variable "environment" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
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

variable "s3_bucket_name" {
  type = string
}

variable "dms_role_arn" {
  type = string
}