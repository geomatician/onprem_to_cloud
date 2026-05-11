environment = "prod"

vpc_cidr = "10.1.0.0/16"

bucket_name = "pg-redshift-staging"

# Production Postgres endpoint (could be RDS later)
postgres_endpoint = "host.docker.internal"
postgres_username = "postgres"

# Redshift (prod cluster)
redshift_username = "admin"
