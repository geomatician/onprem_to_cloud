import sys
import psycopg2

from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark.context import SparkContext

# -----------------------------------------------------
# Arguments from Jenkins
# -----------------------------------------------------
args = getResolvedOptions(sys.argv, [
    "REDSHIFT_HOST",
    "REDSHIFT_PASSWORD",
    "S3_BUCKET"
])

REDSHIFT_HOST = args["REDSHIFT_HOST"]
REDSHIFT_PASSWORD = args["REDSHIFT_PASSWORD"]
S3_BUCKET = args["S3_BUCKET"]

REDSHIFT_DB = "analytics"
REDSHIFT_USER = "admin"

# -----------------------------------------------------
# Create schema/tables in Redshift
# -----------------------------------------------------
conn = psycopg2.connect(
    host=REDSHIFT_HOST,
    port=5439,
    dbname=REDSHIFT_DB,
    user=REDSHIFT_USER,
    password=REDSHIFT_PASSWORD
)

conn.autocommit = True
cursor = conn.cursor()

schema_sql = """

CREATE SCHEMA IF NOT EXISTS pagila_staging;

CREATE TABLE IF NOT EXISTS pagila_staging.actor (
    actor_id INTEGER,
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    last_update TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pagila_staging.category (
    category_id INTEGER,
    name VARCHAR(25),
    last_update TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pagila_staging.country (
    country_id INTEGER,
    country VARCHAR(50),
    last_update TIMESTAMP
);

"""

cursor.execute(schema_sql)

print("Schema and tables created.")

cursor.close()
conn.close()

# -----------------------------------------------------
# Initialize Glue
# -----------------------------------------------------
sc = SparkContext()
glueContext = GlueContext(sc)

# -----------------------------------------------------
# Tables
# -----------------------------------------------------
tables = [
    "actor",
    "category",
    "country"
]

# -----------------------------------------------------
# Load CSVs into Redshift
# -----------------------------------------------------
for table in tables:

    print(f"Loading {table}")

    s3_path = f"s3://{S3_BUCKET}/raw/{table}.csv"

    df = glueContext.create_dynamic_frame.from_options(
        connection_type="s3",
        format="csv",
        connection_options={
            "paths": [s3_path]
        },
        format_options={
            "withHeader": True
        }
    )

    glueContext.write_dynamic_frame.from_options(
        frame=df,
        connection_type="redshift",
        connection_options={
            "url": f"jdbc:redshift://{REDSHIFT_HOST}:5439/{REDSHIFT_DB}",
            "dbtable": f"pagila_staging.{table}",
            "user": REDSHIFT_USER,
            "password": REDSHIFT_PASSWORD,
            "redshiftTmpDir": f"s3://{S3_BUCKET}/tmp/"
        }
    )

    print(f"Finished {table}")

print("Glue load complete.")