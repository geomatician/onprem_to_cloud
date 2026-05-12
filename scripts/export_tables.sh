#!/bin/bash

set -e

mkdir -p export

echo "Starting PostgreSQL table exports..."

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

for TABLE in $TABLES
do
  echo "Exporting $TABLE..."

  psql \
    -h host.docker.internal \
    -U dms_user \
    -d pagila \
    -c "\copy (SELECT * FROM public.$TABLE) TO STDOUT WITH CSV HEADER" \
    > exports/${TABLE}.csv

  echo "$TABLE export complete."

done

echo "All table exports completed successfully."