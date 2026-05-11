variable "postgres_endpoint" {}
variable "postgres_username" {}
variable "postgres_password" {}

variable "redshift_endpoint" {}
variable "redshift_username" {}
variable "redshift_password" {}

variable "s3_bucket_name" {}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}