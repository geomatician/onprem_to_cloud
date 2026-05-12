resource "aws_dms_replication_subnet_group" "this" {
  replication_subnet_group_id          = "dms-subnet-${var.environment}"
  replication_subnet_group_description = "subnet group for DMS"
  subnet_ids                           = var.subnet_ids
}

resource "aws_dms_replication_instance" "this" {
  replication_instance_id    = "dms-${var.environment}"
  replication_instance_class = "dms.t3.medium"
  allocated_storage          = 50

  publicly_accessible         = false
  replication_subnet_group_id = aws_dms_replication_subnet_group.this.id
}

resource "aws_dms_endpoint" "source" {
  endpoint_id   = "source-pg-${var.environment}"
  endpoint_type = "source"
  engine_name   = "postgres"

  server_name   = var.postgres_endpoint
  port          = 5432
  username      = var.postgres_username
  password      = var.postgres_password
  database_name = "pagila"
}

resource "aws_dms_s3_endpoint" "target" {
  endpoint_id   = "s3-target-${var.environment}"
  endpoint_type = "target"
  bucket_name   = var.s3_bucket_name

  service_access_role_arn = var.dms_s3_role_arn

  csv_row_delimiter = "\n"
  csv_delimiter     = ","
}

resource "aws_dms_replication_task" "this" {
  replication_task_id      = "task-${var.environment}"
  replication_instance_arn = aws_dms_replication_instance.this.replication_instance_arn

  source_endpoint_arn = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn = aws_dms_s3_endpoint.target.endpoint_arn

  migration_type = "full-load"

  table_mappings = jsonencode({
    rules = [{
      rule-type = "selection"
      rule-id   = "1"
      rule-name = "all-tables"

      object-locator = {
        schema-name = "%"
        table-name  = "%"
      }

      rule-action = "include"
    }]
  })
}