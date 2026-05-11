pipeline {
    agent any

    parameters {
        choice(
            name: 'ENV',
            choices: ['dev', 'prod'],
            description: 'Choose Terraform environment'
        )
    }

    environment {
        AWS_DEFAULT_REGION = "us-east-1"

        TF_VAR_postgres_password = credentials('postgres-password')
        TF_VAR_redshift_password = credentials('redshift-password')
    }

    stages {

        stage('Set AWS Profile') {
            steps {
                script {
                    env.AWS_PROFILE = "terraform-${params.ENV}"
                }
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Test Local PostgreSQL') {
            steps {
                sh 'chmod +x scripts/test_postgres.sh'
                sh './scripts/test_postgres.sh'
            }
        }

        stage('Terraform Init') {
            steps {
                sh """
                terraform init \
                  -reconfigure \
                  -backend-config=backend/backend-${params.ENV}.hcl
                """
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
                sh """
                terraform plan \
                  -var-file=${params.ENV}.tfvars
                """
            }
        }

        stage('Terraform Apply') {
            steps {
                sh """
                terraform apply \
                  -auto-approve \
                  -var-file=${params.ENV}.tfvars
                """
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
                echo 'Waiting for migration to complete...'
                sh 'sleep 180'
            }
        }

        stage('Validate Redshift Data') {
            steps {
                sh """
                export REDSHIFT_HOST=\$(terraform output -raw redshift_endpoint)

                PGPASSWORD=$TF_VAR_redshift_password psql \
                  -h \$REDSHIFT_HOST \
                  -U admin \
                  -d analytics \
                  -p 5439 \
                  -f scripts/validate_redshift.sql
                """
            }
        }
    }

    post {

        success {
            echo 'Pipeline completed successfully.'
        }

        failure {
            echo 'Pipeline failed.'
        }

    }
}