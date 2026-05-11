output "redshift_endpoint" {
  value = module.redshift.endpoint
}

output "s3_bucket" {
  value = module.s3.bucket_name
}

output "dms_task_arn" {
  value = module.dms.replication_task_arn
}