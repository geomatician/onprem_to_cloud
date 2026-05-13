pipeline {
    agent any

    parameters {
        choice(
            name: 'ENV',
            choices: ['dev', 'prod'],
            description: 'Environment'
        )
    }

    environment {
        AWS_PROFILE = "terraform-${params.ENV}"
        AWS_DEFAULT_REGION = "us-east-1"
        AWS_SDK_LOAD_CONFIG = "1"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Test Local PostgreSQL') {
            steps {
                withCredentials([
                    string(credentialsId: 'postgres-password', variable: 'PGPASSWORD')
                ]) {
                    sh '''
                        set -e

                        export AWS_DEFAULT_REGION=us-east-1

                        echo "Testing PostgreSQL connectivity..."

                        chmod +x scripts/test_postgres.sh

                        ./scripts/test_postgres.sh

                        echo "PostgreSQL connection successful."
                    '''
                }
            }
        }

        // =====================================================
        // TERRAFORM
        // =====================================================
        stage('Terraform Init') {
            steps {
                sh """
                    set -e
                    terraform init \
                        -reconfigure \
                        -backend-config=backend/backend-${params.ENV}.hcl
                """
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    string(credentialsId: 'postgres-password', variable: 'PG_PASS'),
                    string(credentialsId: 'redshift-password', variable: 'RS_PASS')
                ]) {
                    sh """
                        set -e

                        export TF_VAR_postgres_password=$PG_PASS
                        export TF_VAR_redshift_password=$RS_PASS

                        terraform apply -auto-approve -var-file=${params.ENV}.tfvars
                    """
                }
            }
        }

        // =====================================================
        // UPLOAD S3 FILES
        // =====================================================
        stage('Upload CSV Files to S3') {
            steps {
                sh '''
                    set -e
                    chmod +x scripts/upload_to_s3.sh
                    ./scripts/upload_to_s3.sh
                '''
            }
        }

        stage('Upload Scripts to S3') {
            steps {
                sh '''
                    set -e

                    BUCKET=$(terraform output -raw bucket_name)

                    aws s3 cp $WORKSPACE/scripts/redshift_schema.sql \
                        s3://$BUCKET/glue/redshift_schema.sql

                    aws s3 cp $WORKSPACE/modules/glue/load_to_redshift.py \
                        s3://$BUCKET/glue/load_to_redshift.py

                    aws s3 cp $WORKSPACE/modules/glue/validate_redshift.sql \
                        s3://$BUCKET/glue/validate_redshift.sql
                '''
            }
        }

        // =====================================================
        // REDSHIFT DATA API - SCHEMA EXECUTION
        // =====================================================
        stage('Run Schema via Redshift Data API') {
            steps {
                sh '''
                    set -e

                    export AWS_PROFILE=$AWS_PROFILE
                    export AWS_DEFAULT_REGION=us-east-1

                    CLUSTER=$(terraform output -raw cluster_identifier)
                    BUCKET=$(terraform output -raw bucket_name)

                    echo "Downloading schema..."
                    aws s3 cp s3://$BUCKET/glue/redshift_schema.sql /tmp/schema.sql

                    echo "Executing schema statements..."

                    awk 'BEGIN {RS=";"} NF {gsub(/\\n/, " "); print $0}' /tmp/schema.sql > /tmp/statements.txt

                    while read -r stmt; do
                        CLEAN=$(echo "$stmt" | xargs)

                        if [ -n "$CLEAN" ]; then
                            echo "----------------------------------------"
                            echo "Executing:"
                            echo "$CLEAN"
                            echo "----------------------------------------"

                            STATEMENT_ID=$(aws redshift-data execute-statement \
                                --cluster-identifier $CLUSTER \
                                --database analytics \
                                --db-user admin \
                                --sql "$CLEAN" \
                                --query "Id" --output text)

                            echo "Statement ID: $STATEMENT_ID"

                            # Wait for completion
                            while true; do
                                STATUS=$(aws redshift-data describe-statement \
                                    --id $STATEMENT_ID \
                                    --query "Status" \
                                    --output text)

                                if [ "$STATUS" = "FINISHED" ]; then
                                    echo "Completed successfully"
                                    break
                                elif [ "$STATUS" = "FAILED" ]; then
                                    echo "FAILED:"
                                    aws redshift-data describe-statement --id $STATEMENT_ID
                                    exit 1
                                else
                                    echo "Status: $STATUS ... waiting"
                                    sleep 2
                                fi
                            done
                        fi
                    done < /tmp/statements.txt
                '''
            }
        }

        // =====================================================
        // GLUE LOAD JOB
        // =====================================================
        stage('Run Glue Load to Redshift') {
            steps {
                withCredentials([
                    string(credentialsId: 'redshift-password', variable: 'RS_PASS')
                ]) {
                    sh '''
                        set -e

                        BUCKET=$(terraform output -raw bucket_name)

                        RAW_ENDPOINT=$(terraform output -raw redshift_endpoint)
                        REDSHIFT_HOST=$(echo $RAW_ENDPOINT | cut -d':' -f1)

                        echo "Running Glue job with host: $REDSHIFT_HOST"

                        ARGS=$(printf '{\"--REDSHIFT_HOST\":\"%s\",\"--REDSHIFT_PASSWORD\":\"%s\",\"--S3_BUCKET\":\"%s\"}' \
                            "$REDSHIFT_HOST" \
                            "$RS_PASS" \
                            "$BUCKET")

                        aws glue start-job-run \
                            --job-name s3-to-redshift-$ENV \
                            --arguments "$ARGS"
                    '''
                }
            }
        }

        stage('Validate Redshift Load') {
            steps {
                sh '''
                    set -e

                    export AWS_DEFAULT_REGION=us-east-1

                    CLUSTER=$(terraform output -raw cluster_identifier)
                    BUCKET=$(terraform output -raw bucket_name)

                    echo "Downloading validation SQL..."

                    aws s3 cp \
                        s3://$BUCKET/glue/validate_redshift.sql \
                        /tmp/validate_redshift.sql

                    SQL=$(cat /tmp/validate_redshift.sql)

                    echo "Executing validation query..."

                    STATEMENT_ID=$(aws redshift-data execute-statement \
                        --cluster-identifier $CLUSTER \
                        --database analytics \
                        --db-user admin \
                        --sql "$SQL" \
                        --query "Id" \
                        --output text)

                    echo "Statement ID: $STATEMENT_ID"

                    # ----------------------------------------
                    # Wait for completion
                    # ----------------------------------------
                    while true; do

                        STATUS=$(aws redshift-data describe-statement \
                            --id $STATEMENT_ID \
                            --query "Status" \
                            --output text)

                        if [ "$STATUS" = "FINISHED" ]; then
                            echo "Validation completed."
                            break

                        elif [ "$STATUS" = "FAILED" ]; then
                            echo "Validation FAILED."

                            aws redshift-data describe-statement \
                                --id $STATEMENT_ID

                            exit 1

                        else
                            echo "Status: $STATUS ... waiting"
                            sleep 2
                        fi
                    done

                    echo "========================================"
                    echo "VALIDATION RESULTS"
                    echo "========================================"

                    aws redshift-data get-statement-result \
                        --id $STATEMENT_ID
                '''
            }
        }


    }

    post {
        success {
            echo "Pipeline succeeded"
        }
        failure {
            echo "Pipeline failed"
        }
    }
}