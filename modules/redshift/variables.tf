variable "username" {}
variable "password" {}
variable "security_group_ids" {
  type = list(string)
}
variable "iam_role" {}