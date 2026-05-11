resource "aws_dms_replication_instance" "this" {
  replication_instance_class = "dms.t3.medium"
  allocated_storage          = 50
  publicly_accessible        = true
}

resource "aws_dms_endpoint" "source" {
  endpoint_id   = "source-postgres"
  endpoint_type = "source"
  engine_name   = "postgres"

  server_name   = var.postgres_endpoint
  port          = 5432
  username      = var.postgres_username
  password      = var.postgres_password
  database_name = "pagila"
}

resource "aws_dms_endpoint" "target" {
  endpoint_id   = "target-redshift"
  endpoint_type = "target"
  engine_name   = "redshift"

  server_name   = var.redshift_endpoint
  port          = 5439
  username      = var.redshift_username
  password      = var.redshift_password
  database_name = "analytics"
}