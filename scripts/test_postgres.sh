#!/bin/bash
psql -h localhost -U postgres -d pagila -c "SELECT COUNT(*) FROM customer;"