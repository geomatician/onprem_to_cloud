output "dms_sg" {
  value = aws_security_group.dms_sg.id
}

output "redshift_sg" {
  value = aws_security_group.redshift_sg.id
}