provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "redshift-migration"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "Neeraj Sirdeshmukh"
    }
  }
}