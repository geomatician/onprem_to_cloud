module "vpc" {
  source      = "./modules/vpc"
  vpc_cidr    = var.vpc_cidr
  environment = var.environment
}

module "security_groups" {
  source      = "./modules/security-groups"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  environment = var.environment
}

module "iam" {
  source        = "./modules/iam"
  environment   = var.environment
  s3_bucket_arn = module.s3.bucket_arn
}

module "redshift" {
  source = "./modules/redshift"

  environment        = var.environment
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.redshift_sg]

  username = var.redshift_username
  password = var.redshift_password

  iam_role_arn = module.iam.redshift_role_arn
}

module "dms" {
  source = "./modules/dms"

  environment = var.environment

  subnet_ids = module.vpc.private_subnet_ids

  postgres_endpoint = var.postgres_endpoint
  postgres_username = var.postgres_username
  postgres_password = var.postgres_password

  s3_bucket_name  = module.s3.bucket_name
  dms_s3_role_arn = module.iam.dms_s3_role_arn
}