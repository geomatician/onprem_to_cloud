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