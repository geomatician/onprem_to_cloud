output "redshift_sg" {
  value = aws_security_group.redshift.id
}

output "dms_sg" {
  value = aws_security_group.dms.id
}