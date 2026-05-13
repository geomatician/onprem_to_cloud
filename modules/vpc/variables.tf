variable "vpc_id" {
  type = string
}

variable "region" {
  type = string
}

variable "private_route_table_ids" {
  type = list(string)
}