variable "environment" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "iam_role_arn" {
  type = string
}