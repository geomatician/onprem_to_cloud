#!/bin/bash

set -e

mkdir -p exports/schema

echo "Exporting PostgreSQL schema..."

pg_dump \
  -h host.docker.internal \
  -U dms_user \
  -d pagila \
  --schema-only \
  --no-owner \
  --no-privileges \
  > exports/schema/schema.sql

echo "Schema export complete."