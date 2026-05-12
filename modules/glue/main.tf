resource "aws_glue_job" "this" {
  name     = "s3-to-redshift-${var.environment}"
  role_arn = var.glue_role_arn

  glue_version = "4.0"
  max_capacity = var.glue_max_capacity

  command {
    name            = "glueetl"
    script_location = "s3://${var.s3_bucket_name}/glue/load_to_redshift.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"   = "python"
    "--enable-metrics" = ""
    "--TempDir"        = "s3://${var.s3_bucket_name}/tmp/"

    # install psycopg2 at Glue runtime
    "--extra-py-files" = "s3://${var.s3_bucket_name}/glue/psycopg2_binary-2.9.12-cp310-cp310-macosx_11_0_arm64.whl"
  }

  connections = [
    aws_glue_connection.redshift.name
  ]

  tags = {
    Environment = var.environment
  }
}

resource "aws_glue_connection" "redshift" {
  name = "redshift-connection-${var.environment}"

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:redshift://${var.redshift_host}:5439/analytics"
    USERNAME            = var.redshift_username
    PASSWORD            = var.redshift_password
  }

  physical_connection_requirements {
    availability_zone      = var.availability_zone
    subnet_id              = var.subnet_id
    security_group_id_list = [var.glue_security_group_id]
  }
}