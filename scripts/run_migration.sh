#!/bin/bash

TASK_ARN=$(terraform output -raw dms_task_arn)

echo "Starting DMS migration task..."

aws dms start-replication-task \
  --replication-task-arn $TASK_ARN \
  --start-replication-task-type start-replication