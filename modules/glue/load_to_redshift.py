import sys
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark.context import SparkContext

# -----------------------------------------------------
# Read arguments from Jenkins / Glue
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
REDSHIFT_PORT = "5439"

# -----------------------------------------------------
# Initialize Glue
# -----------------------------------------------------
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# -----------------------------------------------------
# Tables to load
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
# Redshift JDBC URL
# -----------------------------------------------------
jdbc_url = f"jdbc:redshift://{REDSHIFT_HOST}:{REDSHIFT_PORT}/{REDSHIFT_DB}"

# -----------------------------------------------------
# Load each table from S3 → Redshift
# -----------------------------------------------------
for table in tables:

    print(f"Loading table: {table}")

    s3_path = f"s3://{S3_BUCKET}/raw/{table}.csv"

    # Read from S3
    dyf = glueContext.create_dynamic_frame.from_options(
        connection_type="s3",
        format="csv",
        connection_options={"paths": [s3_path]},
        format_options={
            "withHeader": True,
            "separator": ","
        }
    )

    # Write to Redshift
    glueContext.write_dynamic_frame.from_options(
        frame=dyf,
        connection_type="jdbc",
        connection_options={
            "url": jdbc_url,
            "dbtable": f"pagila_staging.{table}",
            "user": REDSHIFT_USER,
            "password": REDSHIFT_PASSWORD,
            "driver": "com.amazon.redshift.jdbc.Driver"
        }
    )

    print(f"Completed table: {table}")

print("All tables loaded successfully into Redshift.")