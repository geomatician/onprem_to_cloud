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
        AWS_PROFILE = "terraform-${params.ENV}"
        AWS_DEFAULT_REGION = "us-east-1"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Set AWS Profile') {
            steps {
                script {
                    env.AWS_PROFILE = "terraform-${params.ENV}"
                }
            }
        }

        stage('Test Tools') {
            steps {
                sh '''
                    git --version
                    terraform version
                    aws --version
                    aws sts get-caller-identity --profile $AWS_PROFILE --no-cli-pager
                '''
            }
        }

        stage('Test Local PostgreSQL') {
            steps {
                sh '''
                    chmod +x scripts/test_postgres.sh
                    ./scripts/test_postgres.sh
                '''
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
                withCredentials([
                    string(credentialsId: 'postgres-password', variable: 'PG_PASS'),
                    string(credentialsId: 'redshift-password', variable: 'RS_PASS')
                ]) {
                    sh """
                        export TF_VAR_postgres_password=$PG_PASS
                        export TF_VAR_redshift_password=$RS_PASS

                        terraform plan -var-file=${params.ENV}.tfvars
                    """
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    string(credentialsId: 'postgres-password', variable: 'PG_PASS'),
                    string(credentialsId: 'redshift-password', variable: 'RS_PASS')
                ]) {
                    sh """
                        export TF_VAR_postgres_password=$PG_PASS
                        export TF_VAR_redshift_password=$RS_PASS

                        terraform apply -auto-approve -var-file=${params.ENV}.tfvars
                    """
                }
            }
        }

        stage('Export Postgres Tables to S3') {
            steps {
                sh '''
                set -e

                BUCKET=$(terraform output -raw bucket_name)

                echo "Using bucket: $BUCKET"

                mkdir -p export

                TABLES="actor address category city country customer film film_actor film_category inventory language payment rental staff store"

                for TABLE in $TABLES
                do
                echo "Exporting $TABLE..."

                psql \
                    -h host.docker.internal \
                    -U postgres \
                    -d pagila \
                    -c "\\copy public.$TABLE TO STDOUT WITH CSV HEADER" \
                > export/${TABLE}.csv

                aws s3 cp export/${TABLE}.csv s3://$BUCKET/raw/$TABLE.csv

                done
                '''
            }
        }

        stage('Wait For Migration') {
            steps {
                echo 'Waiting for DMS migration to complete...'
                sh 'sleep 180'
            }
        }

        stage('Validate Redshift Data') {
            steps {
                sh '''
                    export REDSHIFT_HOST=$(terraform output -raw redshift_endpoint)

                    PGPASSWORD=$RS_PASS psql \
                        -h $REDSHIFT_HOST \
                        -U admin \
                        -d analytics \
                        -p 5439 \
                        -f scripts/validate_redshift.sql
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline succeeded.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}