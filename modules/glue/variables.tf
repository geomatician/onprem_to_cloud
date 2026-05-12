variable "environment" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "s3_bucket_arn" {
  type = string
}

variable "glue_max_capacity" {
  type    = number
  default = 2
}

variable "glue_role_arn" {
  type = string
}