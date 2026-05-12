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
                    aws sts get-caller-identity --profile $AWS_PROFILE
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

        stage('Export PostgreSQL Schema') {
            steps {
                withCredentials([
                    string(credentialsId: 'postgres-password', variable: 'PGPASSWORD')
                ]) {
                    sh '''
                        chmod +x scripts/export_schema.sh

                        ./scripts/export_schema.sh
                    '''
                }
            }
        }

        stage('Export PostgreSQL Tables') {
            steps {
                withCredentials([
                    string(credentialsId: 'postgres-password', variable: 'PGPASSWORD')
                ]) {
                    sh '''
                        set -e

                        chmod +x scripts/export_tables.sh

                        ./scripts/export_tables.sh
                    '''
                }
            }
        }

        stage('Upload Files To S3') {
            steps {
                sh '''
                    set -e

                    chmod +x scripts/upload_to_s3.sh

                    ./scripts/upload_to_s3.sh
                '''
            }
        }

        stage('Upload Glue Script') {
            steps {
                sh '''
                    set -e

                    BUCKET=$(terraform output -raw bucket_name)

                    aws s3 cp $WORKSPACE/modules/glue/load_to_redshift.py s3://$BUCKET/glue/load_to_redshift.py
                '''
            }
        }

        stage('Run Glue Load to Redshift') {
            steps {
                withCredentials([
                    string(credentialsId: 'redshift-password', variable: 'RS_PASS')
                ]) {
                    sh '''
                        set -e

                        BUCKET=$(terraform output -raw bucket_name)

                        RAW_ENDPOINT=$(terraform output -raw redshift_endpoint)

                        # remove :5439 if present
                        REDSHIFT_HOST=$(echo $RAW_ENDPOINT | cut -d':' -f1)

                        echo "Bucket: $BUCKET"
                        echo "Redshift Host: $REDSHIFT_HOST"

                        aws glue start-job-run \
                            --job-name s3-to-redshift-${ENV} \
                            --arguments '{
                                "--REDSHIFT_HOST":"'"$REDSHIFT_HOST"'",
                                "--REDSHIFT_PASSWORD":"'"$RS_PASS"'",
                                "--S3_BUCKET":"'"$BUCKET"'"
                            }'
                    '''
                }
            }
        }

        stage('Wait for Glue Job') {
            steps {
                sh '''
                    sleep 180
                '''
            }
        }

        stage('Validate Redshift Data') {
            steps {
                withCredentials([
                    string(credentialsId: 'redshift-password', variable: 'PGPASSWORD')
                ]) {
                    sh '''
                        set -e

                        export REDSHIFT_HOST=$(terraform output -raw redshift_endpoint)

                        psql \
                          -h $REDSHIFT_HOST \
                          -U admin \
                          -d analytics \
                          -p 5439 \
                          -f scripts/validate_redshift.sql
                    '''
                }
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