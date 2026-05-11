resource "aws_redshift_cluster" "this" {
  cluster_identifier = "demo-redshift"

  database_name   = "analytics"
  master_username = var.username
  master_password = var.password

  node_type    = "ra3.large"
  cluster_type  = "single-node"

  publicly_accessible = true

  vpc_security_group_ids = var.security_group_ids

  iam_roles = [var.iam_role]
}