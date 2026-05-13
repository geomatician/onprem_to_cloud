output "redshift_role_arn" {
  value = aws_iam_role.redshift_role.arn
}

# output "glue_role_arn" {
#   value = aws_iam_role.glue_role.arn
# }