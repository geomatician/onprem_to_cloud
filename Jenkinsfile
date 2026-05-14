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

        stage('Test Local PostgreSQL Connection') {
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

        stage('Data Integrity Suite (Postgres Source)') {
            steps {
                withCredentials([
                    string(credentialsId: 'postgres-password', variable: 'PGPASSWORD')
                ]) {
                    sh '''
                        set -e

                        echo "========================================"
                        echo "POSTGRES SOURCE DATA INTEGRITY CHECKS"
                        echo "========================================"

                        DB_HOST=host.docker.internal
                        DB_NAME=pagila
                        DB_USER=dms_user
                        DB_PORT=5432

                        run_sql () {
                            NAME=$1
                            SQL=$2

                            echo ""
                            echo "----------------------------------------"
                            echo "CHECK: $NAME"
                            echo "----------------------------------------"

                            psql \
                                -h $DB_HOST \
                                -U $DB_USER \
                                -d $DB_NAME \
                                -p $DB_PORT \
                                -v ON_ERROR_STOP=1 \
                                -c "$SQL"
                        }

                        # =====================================================
                        # 1. ROW COUNT CHECKS (ALL TABLES)
                        # =====================================================

                        run_sql "actor_count" "SELECT 'actor' AS table_name, COUNT(*) FROM public.actor;"
                        run_sql "address_count" "SELECT 'address', COUNT(*) FROM public.address;"
                        run_sql "category_count" "SELECT 'category', COUNT(*) FROM public.category;"
                        run_sql "city_count" "SELECT 'city', COUNT(*) FROM public.city;"
                        run_sql "country_count" "SELECT 'country', COUNT(*) FROM public.country;"
                        run_sql "customer_count" "SELECT 'customer', COUNT(*) FROM public.customer;"
                        run_sql "film_count" "SELECT 'film', COUNT(*) FROM public.film;"
                        run_sql "film_actor_count" "SELECT 'film_actor', COUNT(*) FROM public.film_actor;"
                        run_sql "film_category_count" "SELECT 'film_category', COUNT(*) FROM public.film_category;"
                        run_sql "inventory_count" "SELECT 'inventory', COUNT(*) FROM public.inventory;"
                        run_sql "language_count" "SELECT 'language', COUNT(*) FROM public.language;"
                        run_sql "payment_count" "SELECT 'payment', COUNT(*) FROM public.payment;"
                        run_sql "rental_count" "SELECT 'rental', COUNT(*) FROM public.rental;"
                        run_sql "staff_count" "SELECT 'staff', COUNT(*) FROM public.staff;"
                        run_sql "store_count" "SELECT 'store', COUNT(*) FROM public.store;"

                        # =====================================================
                        # 2. PRIMARY KEY CHECKS
                        # =====================================================

                        run_sql "film_pk" "
                            SELECT film_id, COUNT(*)
                            FROM public.film
                            GROUP BY film_id
                            HAVING COUNT(*) > 1;
                        "

                        run_sql "customer_pk" "
                            SELECT customer_id, COUNT(*)
                            FROM public.customer
                            GROUP BY customer_id
                            HAVING COUNT(*) > 1;
                        "

                        run_sql "rental_pk" "
                            SELECT rental_id, COUNT(*)
                            FROM public.rental
                            GROUP BY rental_id
                            HAVING COUNT(*) > 1;
                        "

                        run_sql "payment_pk" "
                            SELECT payment_id, COUNT(*)
                            FROM public.payment
                            GROUP BY payment_id
                            HAVING COUNT(*) > 1;
                        "

                        # =====================================================
                        # 3. FOREIGN KEY VALIDATION
                        # =====================================================

                        run_sql "film_actor_fk" "
                            SELECT COUNT(*)
                            FROM public.film_actor fa
                            LEFT JOIN public.film f
                            ON fa.film_id = f.film_id
                            WHERE f.film_id IS NULL;
                        "

                        run_sql "rental_fk_customer" "
                            SELECT COUNT(*)
                            FROM public.rental r
                            LEFT JOIN public.customer c
                            ON r.customer_id = c.customer_id
                            WHERE c.customer_id IS NULL;
                        "

                        run_sql "payment_fk_rental" "
                            SELECT COUNT(*)
                            FROM public.payment p
                            LEFT JOIN public.rental r
                            ON p.rental_id = r.rental_id
                            WHERE r.rental_id IS NULL;
                        "

                        run_sql "inventory_fk_film" "
                            SELECT COUNT(*)
                            FROM public.inventory i
                            LEFT JOIN public.film f
                            ON i.film_id = f.film_id
                            WHERE f.film_id IS NULL;
                        "

                        # =====================================================
                        # 4. NULL CHECKS
                        # =====================================================

                        run_sql "film_nulls" "
                            SELECT COUNT(*)
                            FROM public.film
                            WHERE film_id IS NULL OR title IS NULL;
                        "

                        run_sql "customer_nulls" "
                            SELECT COUNT(*)
                            FROM public.customer
                            WHERE customer_id IS NULL OR first_name IS NULL;
                        "

                        run_sql "payment_nulls" "
                            SELECT COUNT(*)
                            FROM public.payment
                            WHERE payment_id IS NULL OR amount IS NULL;
                        "

                        echo ""
                        echo "========================================"
                        echo "✅ POSTGRES INTEGRITY CHECKS PASSED"
                        echo "========================================"
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

        stage('Export PostgreSQL Tables to local CSV') {
            steps {
                withCredentials([
                    string(credentialsId: 'postgres-password', variable: 'PGPASSWORD')
                ]) {
                    sh '''
                        set -e

                        echo "========================================"
                        echo "EXPORTING POSTGRES TABLES TO CSV"
                        echo "========================================"

                        chmod +x scripts/export_tables.sh

                        ./scripts/export_tables.sh

                        echo ""
                        echo "Export complete"

                        echo ""
                        echo "Generated CSV files:"
                        ls -lh exports/
                    '''
                }
            }
        }

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
                        s3://$BUCKET/sql/redshift_schema.sql

                    aws s3 cp $WORKSPACE/scripts/validate_redshift.sql \
                        s3://$BUCKET/sql/validate_redshift.sql
                '''
            }
        }

        // =====================================================
        // REDSHIFT DATA API - SCHEMA EXECUTION
        // =====================================================
        stage('Create Schema via Redshift Data API') {
            steps {
                sh '''
                    set -e

                    export AWS_PROFILE=$AWS_PROFILE
                    export AWS_DEFAULT_REGION=us-east-1

                    CLUSTER=$(terraform output -raw cluster_identifier)
                    BUCKET=$(terraform output -raw bucket_name)

                    echo "Downloading schema..."
                    aws s3 cp s3://$BUCKET/sql/redshift_schema.sql /tmp/schema.sql

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

        stage('Load Data via Redshift COPY (S3 → Redshift)') {
            steps {
                sh '''
                    set -e

                    CLUSTER=$(terraform output -raw cluster_identifier)
                    BUCKET=$(terraform output -raw bucket_name)
                    IAM_ROLE=$(terraform output -raw redshift_role_arn)

                    echo "========================================"
                    echo "STARTING REDSHIFT COPY LOAD"
                    echo "========================================"

                    run_copy () {
                        TABLE=$1

                        echo ""
                        echo "----------------------------------------"
                        echo "Loading table: $TABLE"
                        echo "----------------------------------------"

                        SQL="
                        TRUNCATE TABLE pagila_staging.$TABLE;

                        COPY pagila_staging.$TABLE
                        FROM 's3://$BUCKET/raw/$TABLE'
                        IAM_ROLE '$IAM_ROLE'
                        FORMAT AS CSV
                        IGNOREHEADER 1
                        QUOTE '"'
                        ESCAPE
                        TRIMBLANKS
                        EMPTYASNULL
                        BLANKSASNULL
                        ACCEPTINVCHARS
                        TIMEFORMAT 'auto';
                        "

                        echo "$SQL"

                        STATEMENT_ID=$(aws redshift-data execute-statement \
                            --cluster-identifier $CLUSTER \
                            --database analytics \
                            --db-user admin \
                            --sql "$SQL" \
                            --query Id \
                            --output text)

                        echo "Statement ID: $STATEMENT_ID"

                        # Wait for execution
                        while true; do
                            STATUS=$(aws redshift-data describe-statement \
                                --id $STATEMENT_ID \
                                --query Status \
                                --output text)

                            echo "$TABLE status: $STATUS"

                            if [ "$STATUS" = "FINISHED" ]; then
                                break
                            fi

                            if [ "$STATUS" = "FAILED" ]; then
                                echo "❌ COPY FAILED for table: $TABLE"
                                aws redshift-data describe-statement --id $STATEMENT_ID
                                exit 1
                            fi

                            sleep 3
                        done

                        echo "✔ Completed: $TABLE"
                    }

                    # =====================================================
                    # RUN ALL TABLES
                    # =====================================================
                    run_copy actor
                    run_copy address
                    run_copy category
                    run_copy city
                    run_copy country
                    run_copy customer
                    run_copy film
                    run_copy film_actor
                    run_copy film_category
                    run_copy inventory
                    run_copy language
                    run_copy payment
                    run_copy rental
                    run_copy staff
                    run_copy store

                    echo ""
                    echo "========================================"
                    echo "ALL TABLES LOADED SUCCESSFULLY VIA COPY"
                    echo "========================================"
                '''
            }
        }

        stage('Validate Postgres Counts') {
            steps {
                withCredentials([
                    string(credentialsId: 'postgres-password', variable: 'PGPASSWORD')
                ]) {
                    sh '''
                        set -e

                        echo "Running Postgres validation..."

                        psql \
                        -h host.docker.internal \
                        -U dms_user \
                        -d pagila \
                        -p 5432 \
                        -f scripts/validate_postgres.sql \
                        -F '|' \
                        --no-align \
                        > /tmp/pg_counts.txt

                        cat /tmp/pg_counts.txt
                    '''
                }
            }
        }

        stage('Validate Redshift Counts') {
            steps {
                sh '''
                    set -e

                    echo "========================================"
                    echo "Running Redshift validation..."
                    echo "========================================"

                    CLUSTER=$(terraform output -raw cluster_identifier)
                    BUCKET=$(terraform output -raw bucket_name)

                    # Download validation SQL
                    aws s3 cp \
                        s3://$BUCKET/sql/validate_redshift.sql \
                        /tmp/rs.sql

                    SQL=$(cat /tmp/rs.sql)

                    echo ""
                    echo "Executing validation query..."
                    echo ""

                    STATEMENT_ID=$(aws redshift-data execute-statement \
                        --cluster-identifier $CLUSTER \
                        --database analytics \
                        --db-user admin \
                        --sql "$SQL" \
                        --query Id \
                        --output text)

                    echo "Statement ID: $STATEMENT_ID"

                    # Wait for completion
                    while true; do

                        STATUS=$(aws redshift-data describe-statement \
                            --id $STATEMENT_ID \
                            --query Status \
                            --output text)

                        echo "Status: $STATUS"

                        if [ "$STATUS" = "FINISHED" ]; then
                            break
                        fi

                        if [ "$STATUS" = "FAILED" ]; then
                            echo "Validation failed"

                            aws redshift-data describe-statement \
                                --id $STATEMENT_ID

                            exit 1
                        fi

                        sleep 2
                    done

                    echo ""
                    echo "========================================"
                    echo "REDSHIFT TABLE COUNTS"
                    echo "========================================"

                    # Save Redshift result JSON
                    aws redshift-data get-statement-result \
                        --id $STATEMENT_ID \
                        --output json > /tmp/result.json

# Convert JSON results into psql-style output
python3 - <<'EOF' > /tmp/rs_counts.txt
import json

with open('/tmp/result.json') as f:
    data = json.load(f)

print("table name|count")

for row in data["Records"]:
    table = row[0]["stringValue"]
    count = row[1]["longValue"]
    print(f"{table}|{count}")

print("\\n(15 rows)")
EOF
                    # Print formatted output
                    cat /tmp/rs_counts.txt
                '''
            }
        }

        stage('Compare Source vs Target') {
            steps {
                sh '''
                    set -e

                    echo "Comparing datasets..."

                    python3 $WORKSPACE/scripts/compare_counts.py \
                        /tmp/pg_counts.txt \
                        /tmp/rs_counts.txt
                '''
            }
        }

        stage('Data Integrity Suite (Redshift)') {
            steps {
                sh '''
                    set -e

                    CLUSTER=$(terraform output -raw cluster_identifier)

                    echo "========================================"
                    echo "STARTING FULL DATA INTEGRITY SUITE"
                    echo "========================================"

                    run_sql () {
                        NAME=$1
                        SQL=$2

                        echo ""
                        echo "----------------------------------------"
                        echo "CHECK: $NAME"
                        echo "----------------------------------------"
                        echo "$SQL"

                        ID=$(aws redshift-data execute-statement \
                            --cluster-identifier $CLUSTER \
                            --database analytics \
                            --db-user admin \
                            --sql "$SQL" \
                            --query Id \
                            --output text)

                        while true; do
                            STATUS=$(aws redshift-data describe-statement \
                                --id $ID \
                                --query Status \
                                --output text)

                            echo "$NAME status: $STATUS"

                            if [ "$STATUS" = "FINISHED" ]; then
                                break
                            fi

                            if [ "$STATUS" = "FAILED" ]; then
                                echo " FAILED: $NAME"
                                aws redshift-data describe-statement --id $ID
                                exit 1
                            fi

                            sleep 2
                        done

                        aws redshift-data get-statement-result --id $ID
                    }

                    # =====================================================
                    # 1. ROW COUNT CHECKS (ALL TABLES)
                    # =====================================================
                    run_sql "actor_count" "SELECT 'actor' AS table_name, COUNT(*) FROM pagila_staging.actor"
                    run_sql "address_count" "SELECT 'address', COUNT(*) FROM pagila_staging.address"
                    run_sql "category_count" "SELECT 'category', COUNT(*) FROM pagila_staging.category"
                    run_sql "city_count" "SELECT 'city', COUNT(*) FROM pagila_staging.city"
                    run_sql "country_count" "SELECT 'country', COUNT(*) FROM pagila_staging.country"
                    run_sql "customer_count" "SELECT 'customer', COUNT(*) FROM pagila_staging.customer"
                    run_sql "film_count" "SELECT 'film', COUNT(*) FROM pagila_staging.film"
                    run_sql "film_actor_count" "SELECT 'film_actor', COUNT(*) FROM pagila_staging.film_actor"
                    run_sql "film_category_count" "SELECT 'film_category', COUNT(*) FROM pagila_staging.film_category"
                    run_sql "inventory_count" "SELECT 'inventory', COUNT(*) FROM pagila_staging.inventory"
                    run_sql "language_count" "SELECT 'language', COUNT(*) FROM pagila_staging.language"
                    run_sql "payment_count" "SELECT 'payment', COUNT(*) FROM pagila_staging.payment"
                    run_sql "rental_count" "SELECT 'rental', COUNT(*) FROM pagila_staging.rental"
                    run_sql "staff_count" "SELECT 'staff', COUNT(*) FROM pagila_staging.staff"
                    run_sql "store_count" "SELECT 'store', COUNT(*) FROM pagila_staging.store"

                    # =====================================================
                    # 2. PRIMARY KEY VALIDATION (CORE TABLES)
                    # =====================================================
                    run_sql "film_pk" "
                        SELECT film_id, COUNT(*)
                        FROM pagila_staging.film
                        GROUP BY film_id
                        HAVING COUNT(*) > 1
                    "

                    run_sql "customer_pk" "
                        SELECT customer_id, COUNT(*)
                        FROM pagila_staging.customer
                        GROUP BY customer_id
                        HAVING COUNT(*) > 1
                    "

                    run_sql "rental_pk" "
                        SELECT rental_id, COUNT(*)
                        FROM pagila_staging.rental
                        GROUP BY rental_id
                        HAVING COUNT(*) > 1
                    "

                    run_sql "payment_pk" "
                        SELECT payment_id, COUNT(*)
                        FROM pagila_staging.payment
                        GROUP BY payment_id
                        HAVING COUNT(*) > 1
                    "

                    # =====================================================
                    # 3. FOREIGN KEY INTEGRITY CHECKS
                    # =====================================================

                    run_sql "film_actor_fk" "
                        SELECT COUNT(*)
                        FROM pagila_staging.film_actor fa
                        LEFT JOIN pagila_staging.film f
                        ON fa.film_id = f.film_id
                        WHERE f.film_id IS NULL
                    "

                    run_sql "rental_fk_customer" "
                        SELECT COUNT(*)
                        FROM pagila_staging.rental r
                        LEFT JOIN pagila_staging.customer c
                        ON r.customer_id = c.customer_id
                        WHERE c.customer_id IS NULL
                    "

                    run_sql "payment_fk_rental" "
                        SELECT COUNT(*)
                        FROM pagila_staging.payment p
                        LEFT JOIN pagila_staging.rental r
                        ON p.rental_id = r.rental_id
                        WHERE r.rental_id IS NULL
                    "

                    run_sql "inventory_fk_film" "
                        SELECT COUNT(*)
                        FROM pagila_staging.inventory i
                        LEFT JOIN pagila_staging.film f
                        ON i.film_id = f.film_id
                        WHERE f.film_id IS NULL
                    "

                    # =====================================================
                    # 4. NULL CHECKS (CRITICAL COLUMNS)
                    # =====================================================

                    run_sql "film_nulls" "
                        SELECT COUNT(*)
                        FROM pagila_staging.film
                        WHERE film_id IS NULL OR title IS NULL
                    "

                    run_sql "customer_nulls" "
                        SELECT COUNT(*)
                        FROM pagila_staging.customer
                        WHERE customer_id IS NULL OR first_name IS NULL
                    "

                    run_sql "payment_nulls" "
                        SELECT COUNT(*)
                        FROM pagila_staging.payment
                        WHERE payment_id IS NULL OR amount IS NULL
                    "

                    echo ""
                    echo "========================================"
                    echo "ALL DATA INTEGRITY CHECKS PASSED"
                    echo "========================================"
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