output "endpoint" {
  value = aws_redshift_cluster.this.endpoint
}

output "arn" {
  value = aws_redshift_cluster.this.arn
}

output "cluster_identifier" {
  value = aws_redshift_cluster.this.cluster_identifier
}