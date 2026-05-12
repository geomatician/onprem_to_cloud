output "redshift_sg" {
  value = aws_security_group.redshift_sg.id
}

output "glue_sg" {
  value = aws_security_group.glue_sg.id
}