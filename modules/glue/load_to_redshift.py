import sys
import psycopg2

from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark.context import SparkContext

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

REDSHIFT_DB = "analytics"
REDSHIFT_USER = "admin"

# -----------------------------------------------------
# Initialize Spark / Glue
# -----------------------------------------------------
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# -----------------------------------------------------
# Create schema + tables in Redshift
# -----------------------------------------------------
print("Connecting to Redshift...")

conn = psycopg2.connect(
    host=REDSHIFT_HOST,
    port=5439,
    dbname=REDSHIFT_DB,
    user=REDSHIFT_USER,
    password=REDSHIFT_PASSWORD
)

conn.autocommit = True
cursor = conn.cursor()

print("Creating schema and tables...")

schema_sql = """

CREATE SCHEMA IF NOT EXISTS pagila_staging;

CREATE TABLE IF NOT EXISTS pagila_staging.actor (
    actor_id INTEGER,
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    last_update TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pagila_staging.address (
    address_id INTEGER,
    address VARCHAR(50),
    address2 VARCHAR(50),
    district VARCHAR(20),
    city_id INTEGER,
    postal_code VARCHAR(10),
    phone VARCHAR(20),
    last_update TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pagila_staging.category (
    category_id INTEGER,
    name VARCHAR(25),
    last_update TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pagila_staging.city (
    city_id INTEGER,
    city VARCHAR(50),
    country_id INTEGER,
    last_update TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pagila_staging.country (
    country_id INTEGER,
    country VARCHAR(50),
    last_update TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pagila_staging.customer (
    customer_id INTEGER,
    store_id INTEGER,
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    email VARCHAR(50),
    address_id INTEGER,
    activebool BOOLEAN,
    create_date DATE,
    last_update TIMESTAMP,
    active INTEGER
);

CREATE TABLE IF NOT EXISTS pagila_staging.film (
    film_id INTEGER,
    title VARCHAR(255),
    description VARCHAR(1000),
    release_year INTEGER,
    language_id INTEGER,
    rental_duration INTEGER,
    rental_rate NUMERIC(4,2),
    length INTEGER,
    replacement_cost NUMERIC(5,2),
    rating VARCHAR(10),
    last_update TIMESTAMP,
    special_features VARCHAR(255),
    fulltext VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS pagila_staging.film_actor (
    actor_id INTEGER,
    film_id INTEGER,
    last_update TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pagila_staging.film_category (
    film_id INTEGER,
    category_id INTEGER,
    last_update TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pagila_staging.inventory (
    inventory_id INTEGER,
    film_id INTEGER,
    store_id INTEGER,
    last_update TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pagila_staging.language (
    language_id INTEGER,
    name VARCHAR(20),
    last_update TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pagila_staging.payment (
    payment_id INTEGER,
    customer_id INTEGER,
    staff_id INTEGER,
    rental_id INTEGER,
    amount NUMERIC(5,2),
    payment_date TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pagila_staging.rental (
    rental_id INTEGER,
    rental_date TIMESTAMP,
    inventory_id INTEGER,
    customer_id INTEGER,
    return_date TIMESTAMP,
    staff_id INTEGER,
    last_update TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pagila_staging.staff (
    staff_id INTEGER,
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    address_id INTEGER,
    email VARCHAR(50),
    store_id INTEGER,
    active BOOLEAN,
    username VARCHAR(16),
    password VARCHAR(40),
    last_update TIMESTAMP,
    picture VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS pagila_staging.store (
    store_id INTEGER,
    manager_staff_id INTEGER,
    address_id INTEGER,
    last_update TIMESTAMP
);

"""

cursor.execute(schema_sql)

cursor.close()
conn.close()

print("Schema creation complete.")

# -----------------------------------------------------
# Tables to load from S3
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
# Load each CSV into Redshift
# -----------------------------------------------------
for table in tables:

    print(f"Loading table: {table}")

    s3_path = f"s3://{S3_BUCKET}/raw/{table}.csv"

    # Read CSV from S3
    dynamic_frame = glueContext.create_dynamic_frame.from_options(
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

    # Write into Redshift
    glueContext.write_dynamic_frame.from_options(
        frame=dynamic_frame,
        connection_type="redshift",
        connection_options={
            "url": f"jdbc:redshift://{REDSHIFT_HOST}:5439/{REDSHIFT_DB}",
            "dbtable": f"pagila_staging.{table}",
            "user": REDSHIFT_USER,
            "password": REDSHIFT_PASSWORD,
            "redshiftTmpDir": f"s3://{S3_BUCKET}/tmp/"
        }
    )

    print(f"Completed table: {table}")

print("All tables loaded successfully into Redshift.")