environment = "dev"

vpc_cidr = "10.0.0.0/16"

bucket_name = "pg-redshift-staging"

# Local Postgres (your laptop via Docker Jenkins)
postgres_endpoint = "host.docker.internal"
postgres_username = "dms_user"

# Redshift (dev cluster)
redshift_username = "admin"
