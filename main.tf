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

  environment = var.environment

  glue_role_arn  = module.iam.glue_role_arn
  s3_bucket_name = module.s3.bucket_name

  redshift_host     = split(":", module.redshift.endpoint)[0]
  redshift_username = var.redshift_username
  redshift_password = var.redshift_password

  vpc_id = data.aws_vpc.default.id

  subnet_id = data.aws_subnets.default.ids[0]

  availability_zone = data.aws_subnet.glue_subnet.availability_zone

  redshift_security_group_id = module.security_groups.redshift_sg
  glue_security_group_id     = module.security_groups.glue_sg
}