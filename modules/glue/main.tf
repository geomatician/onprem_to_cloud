resource "aws_glue_job" "this" {
  name     = "s3-to-redshift-${var.environment}"
  role_arn = aws_iam_role.glue_role.arn

  glue_version = "4.0"
  max_capacity = var.glue_max_capacity

  command {
    name            = "glueetl"
    script_location = "s3://${var.s3_bucket_name}/glue/s3_to_redshift.py"
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