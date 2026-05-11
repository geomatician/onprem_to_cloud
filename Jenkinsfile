pipeline {
    agent any

    parameters {
        choice(
            name: 'ENV',
            choices: ['dev', 'prod', 'demo'],
            description: 'Choose Terraform environment'
        )
    }

    environment {
        TF_VAR_FILE = "${params.ENV}.tfvars"
    }

    stages {

        stage('Test Local PostgreSQL') {
            steps {
                sh 'chmod +x scripts/test_postgres.sh'
                sh './scripts/test_postgres.sh'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Format Check') {
            steps {
                sh 'terraform fmt -check'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh "terraform plan -var-file=${TF_VAR_FILE}"
            }
        }

        stage('Terraform Apply') {
            steps {
                sh "terraform apply -auto-approve -var-file=${TF_VAR_FILE}"
            }
        }

        stage('Start DMS Migration') {
            steps {
                sh 'chmod +x scripts/run_migration.sh'
                sh './scripts/run_migration.sh'
            }
        }

        stage('Wait For Migration') {
            steps {
                echo 'Waiting for migration...'
                sh 'sleep 60'
            }
        }

        stage('Validate Redshift Data') {
            steps {
                sh """
                PGPASSWORD=$REDSHIFT_PASSWORD psql \
                  -h $REDSHIFT_HOST \
                  -U $REDSHIFT_USER \
                  -d analytics \
                  -f scripts/validate_redshift.sql
                """
            }
        }
    }
}