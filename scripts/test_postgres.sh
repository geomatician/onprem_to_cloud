#!/bin/bash
psql -h host.docker.internal -U postgres -p 5432 -d pagila -c "SELECT COUNT(*) FROM customer;"