#!/bin/bash

set -e

REDSHIFT_ENDPOINT=$(terraform output -raw redshift_endpoint)

# Split host and port
REDSHIFT_HOST=$(echo $REDSHIFT_ENDPOINT | cut -d: -f1)
REDSHIFT_PORT=$(echo $REDSHIFT_ENDPOINT | cut -d: -f2)

echo "Host: $REDSHIFT_HOST"
echo "Port: $REDSHIFT_PORT"

BUCKET=$(terraform output -raw bucket_name)
IAM_ROLE=$(terraform output -raw redshift_role_arn)

TABLES="
actor
address
category
city
country
customer
film
film_actor
film_category
inventory
language
payment
rental
staff
store
"

echo "Creating Redshift schema..."

psql \
  -h $REDSHIFT_HOST \
  -U admin \
  -d analytics \
  -p 5439 \
  -f scripts/redshift_schema.sql

echo "Loading CSV data into Redshift..."

for TABLE in $TABLES
do
  echo "Loading $TABLE..."

  psql \
    -h $REDSHIFT_HOST \
    -U admin \
    -d analytics \
    -p 5439 \
    -c "
    COPY public.$TABLE
    FROM 's3://$BUCKET/raw/$TABLE.csv'
    IAM_ROLE '$IAM_ROLE'
    CSV
    IGNOREHEADER 1;
    "
done

echo "Redshift load complete."