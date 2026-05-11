output "redshift_endpoint" {
  value = module.redshift.endpoint
}

output "s3_bucket" {
  value = module.s3.bucket_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "dms_task_arn" {
  value = module.dms.task_arn
}