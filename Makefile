ENV ?= dev

TFVARS = $(ENV).tfvars

.PHONY: init fmt validate plan apply destroy output

init:
	terraform init

fmt:
	terraform fmt -recursive

validate:
	terraform validate

plan:
	terraform plan -var-file=$(TFVARS)

apply:
	terraform apply -auto-approve -var-file=$(TFVARS)

destroy:
	terraform destroy -auto-approve -var-file=$(TFVARS)

output:
	terraform output

test-postgres:
	chmod +x scripts/test_postgres.sh
	./scripts/test_postgres.sh

run-migration:
	chmod +x scripts/run_migration.sh
	./scripts/run_migration.sh

validate-redshift:
	psql \
	-h $$REDSHIFT_HOST \
	-U $$REDSHIFT_USER \
	-d analytics \
	-f scripts/validate_redshift.sql