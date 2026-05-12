module "vpc" {
  source = "./modules/vpc"
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

  environment = var.environment

  subnet_ids = data.aws_subnets.default.ids

  security_group_ids = [module.security_groups.redshift_sg]

  username = var.redshift_username
  password = var.redshift_password

  iam_role_arn = module.iam.redshift_role_arn
}

module "glue" {
  source = "./modules/glue"

  environment       = var.environment
  s3_bucket_name    = module.s3.bucket_name
  s3_bucket_arn     = module.s3.bucket_arn
  glue_max_capacity = 2
  glue_role_arn     = module.iam.glue_role_arn
}