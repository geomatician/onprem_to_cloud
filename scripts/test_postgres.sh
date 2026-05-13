#!/bin/bash
psql -h host.docker.internal -U dms_user -p 5432 -d pagila -c "SELECT COUNT(*) FROM customer;"