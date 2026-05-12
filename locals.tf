locals {
  redshift_host = split(":", module.redshift.endpoint)[0]
}