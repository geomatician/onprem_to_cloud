output "redshift_endpoint" {
  value = module.redshift.endpoint
}

output "redshift_role_arn" {
  value = module.iam.redshift_role_arn
}

output "bucket_name" {
  value = module.s3.bucket_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "glue_role_arn" {
  value = module.iam.glue_role_arn
}