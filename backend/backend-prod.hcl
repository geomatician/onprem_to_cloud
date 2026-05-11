bucket         = "pg-redshift-tf-state-prod"
key            = "redshift-migration/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "tf-locks-prod"
encrypt        = true