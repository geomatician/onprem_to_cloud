module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}

module "security_groups" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
}

module "iam" {
  source = "./modules/iam"
  s3_bucket_arn = module.s3.bucket_arn
}

module "redshift" {
  source = "./modules/redshift"

  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.security_groups.redshift_sg]

  username = var.redshift_username
  password = var.redshift_password
  iam_role = module.iam.redshift_role_arn
}

module "dms" {
  source = "./modules/dms"

  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.security_groups.dms_sg]

  postgres_endpoint = var.postgres_endpoint
  postgres_username = var.postgres_username
  postgres_password = var.postgres_password

  redshift_endpoint = module.redshift.endpoint
  redshift_username  = var.redshift_username
  redshift_password  = var.redshift_password

  s3_bucket_name = module.s3.bucket_name
}