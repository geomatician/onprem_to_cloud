bucket         = "pg-redshift-tf-state-dev"
key            = "redshift-migration/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "tf-locks-dev"
encrypt        = true