#!/bin/bash

set -e

BUCKET=$(terraform output -raw bucket_name)

echo "Uploading schema..."

aws s3 cp \
  exports/schema/schema.sql \
  s3://$BUCKET/schema/schema.sql

echo "Uploading CSV files..."

for FILE in exports/data/*.csv
do
  BASENAME=$(basename $FILE)

  echo "Uploading $BASENAME..."

  aws s3 cp \
    $FILE \
    s3://$BUCKET/raw/$BASENAME
done

echo "S3 uploads complete."