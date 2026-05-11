provider "aws" {
  region  = var.aws_region
  profile = var.environment

  default_tags {
    tags = {
      Project     = "redshift-migration"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "Neeraj Sirdeshmukh"
    }
  }
}