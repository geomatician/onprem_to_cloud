resource "aws_redshift_subnet_group" "this" {
  name       = "redshift-subnet-${var.environment}"
  subnet_ids = var.subnet_ids
}

resource "aws_redshift_cluster" "this" {
  cluster_identifier = "redshift-${var.environment}"
  database_name      = "analytics"
  master_username    = var.username
  master_password    = var.password

  node_type    = "dc2.large"
  cluster_type = "single-node"

  iam_roles = [var.iam_role_arn]

  vpc_security_group_ids = var.security_group_ids

  skip_final_snapshot = true
}