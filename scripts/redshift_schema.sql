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

CREATE TABLE IF NOT EXISTS pagila_staging.language (
    language_id INTEGER,
    name VARCHAR(20),
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

CREATE TABLE IF NOT EXISTS pagila_staging.rental (
    rental_id INTEGER,
    rental_date TIMESTAMP,
    inventory_id INTEGER,
    customer_id INTEGER,
    return_date TIMESTAMP,
    staff_id INTEGER,
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