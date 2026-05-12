import sys
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark.context import SparkContext
from awsglue.dynamicframe import DynamicFrame

# -----------------------------------------------------
# Read arguments passed from Jenkins
# -----------------------------------------------------
args = getResolvedOptions(sys.argv, [
    "REDSHIFT_HOST",
    "REDSHIFT_PASSWORD",
    "S3_BUCKET"
])

REDSHIFT_HOST = args["REDSHIFT_HOST"]
REDSHIFT_PASSWORD = args["REDSHIFT_PASSWORD"]
S3_BUCKET = args["S3_BUCKET"]

REDSHIFT_JDBC_URL = f"jdbc:redshift://{REDSHIFT_HOST}:5439/dev"

REDSHIFT_USER = "admin"  # or move to Jenkins if you want fully dynamic

# -----------------------------------------------------
# Initialize Glue
# -----------------------------------------------------
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# -----------------------------------------------------
# Tables to load from S3
# (1 CSV per table)
# -----------------------------------------------------
tables = [
    "actor",
    "address",
    "category",
    "city",
    "country",
    "customer",
    "film",
    "film_actor",
    "film_category",
    "inventory",
    "language",
    "payment",
    "rental",
    "staff",
    "store"
]

# -----------------------------------------------------
# Load each table from S3 → Redshift
# -----------------------------------------------------
for table in tables:

    print(f"Loading table: {table}")

    s3_path = f"s3://{S3_BUCKET}/raw/{table}.csv"

    # Read CSV from S3
    df = glueContext.create_dynamic_frame.from_options(
        connection_type="s3",
        format="csv",
        connection_options={
            "paths": [s3_path]
        },
        format_options={
            "withHeader": True,
            "separator": ","
        }
    )

    # Write into Redshift staging schema
    glueContext.write_dynamic_frame.from_options(
        frame=df,
        connection_type="jdbc",
        connection_options={
            "url": REDSHIFT_JDBC_URL,
            "dbtable": f"pagila_staging.{table}",
            "user": REDSHIFT_USER,
            "password": REDSHIFT_PASSWORD,
            "driver": "com.amazon.redshift.jdbc.Driver"
        }
    )

    print(f"Completed: {table}")

print("All tables loaded successfully into Redshift staging.")