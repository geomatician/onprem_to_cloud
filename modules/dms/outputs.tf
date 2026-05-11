output "replication_instance_arn" {
  value = aws_dms_replication_instance.this.replication_instance_arn
}

output "task_arn" {
  value = aws_dms_replication_task.this.replication_task_arn
}