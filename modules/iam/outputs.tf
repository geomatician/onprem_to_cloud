output "dms_role_arn" {
  value = aws_iam_role.dms_role.arn
}

output "redshift_role_arn" {
  value = aws_iam_role.redshift_role.arn
}

output "dms_s3_role_arn" {
  value = aws_iam_role.dms_s3_role.arn
}