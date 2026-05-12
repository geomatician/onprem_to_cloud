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
  }

  tags = {
    Environment = var.environment
  }
}