-- =====================================================
-- Pagila Redshift Schema (Staging / Analytics Layer)
-- =====================================================

CREATE SCHEMA IF NOT EXISTS pagila;

SET search_path TO pagila;

-- =====================================================
-- DIMENSION TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS actor (
    actor_id     INTEGER,
    first_name   VARCHAR(45),
    last_name    VARCHAR(45),
    last_update  TIMESTAMP
);

CREATE TABLE IF NOT EXISTS address (
    address_id   INTEGER,
    address      VARCHAR(50),
    address2     VARCHAR(50),
    district     VARCHAR(20),
    city_id      INTEGER,
    postal_code  VARCHAR(10),
    phone        VARCHAR(20),
    last_update  TIMESTAMP
);

CREATE TABLE IF NOT EXISTS category (
    category_id  INTEGER,
    name         VARCHAR(25),
    last_update  TIMESTAMP
);

CREATE TABLE IF NOT EXISTS city (
    city_id      INTEGER,
    city         VARCHAR(50),
    country_id   INTEGER,
    last_update  TIMESTAMP
);

CREATE TABLE IF NOT EXISTS country (
    country_id   INTEGER,
    country      VARCHAR(50),
    last_update  TIMESTAMP
);

CREATE TABLE IF NOT EXISTS customer (
    customer_id  INTEGER,
    store_id     INTEGER,
    first_name   VARCHAR(45),
    last_name    VARCHAR(45),
    email        VARCHAR(50),
    address_id   INTEGER,
    activebool   BOOLEAN,
    create_date  DATE,
    last_update  TIMESTAMP,
    active       INTEGER
);

CREATE TABLE IF NOT EXISTS language (
    language_id  INTEGER,
    name         VARCHAR(20),
    last_update  TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staff (
    staff_id     INTEGER,
    first_name   VARCHAR(45),
    last_name    VARCHAR(45),
    address_id   INTEGER,
    email        VARCHAR(50),
    store_id     INTEGER,
    active       BOOLEAN,
    username     VARCHAR(16),
    password     VARCHAR(40),
    last_update  TIMESTAMP,
    picture      VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS store (
    store_id     INTEGER,
    manager_staff_id INTEGER,
    address_id   INTEGER,
    last_update  TIMESTAMP
);

-- =====================================================
-- FACT TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS film (
    film_id              INTEGER,
    title                VARCHAR(255),
    description          VARCHAR(1000),
    release_year         INTEGER,
    language_id          INTEGER,
    rental_duration      INTEGER,
    rental_rate          NUMERIC(4,2),
    length               INTEGER,
    replacement_cost     NUMERIC(5,2),
    rating               VARCHAR(10),
    last_update          TIMESTAMP,
    special_features     VARCHAR(255),
    fulltext             VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS film_actor (
    actor_id     INTEGER,
    film_id      INTEGER,
    last_update  TIMESTAMP
);

CREATE TABLE IF NOT EXISTS film_category (
    film_id      INTEGER,
    category_id  INTEGER,
    last_update  TIMESTAMP
);

CREATE TABLE IF NOT EXISTS inventory (
    inventory_id INTEGER,
    film_id      INTEGER,
    store_id     INTEGER,
    last_update  TIMESTAMP
);

CREATE TABLE IF NOT EXISTS rental (
    rental_id    INTEGER,
    rental_date  TIMESTAMP,
    inventory_id INTEGER,
    customer_id  INTEGER,
    return_date  TIMESTAMP,
    staff_id     INTEGER,
    last_update  TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payment (
    payment_id   INTEGER,
    customer_id  INTEGER,
    staff_id     INTEGER,
    rental_id    INTEGER,
    amount       NUMERIC(5,2),
    payment_date TIMESTAMP
);

-- =====================================================
-- NOTES
-- =====================================================
-- 1. No PRIMARY KEY / FOREIGN KEY constraints (Redshift does not enforce them)
-- 2. Designed for COPY from S3 CSV files
-- 3. Optimized for demo ETL pipelines, not OLTP correctness