SELECT 'actor' AS table_name, COUNT(*) AS count
FROM pagila_staging.actor

UNION ALL

SELECT 'address', COUNT(*)
FROM pagila_staging.address

UNION ALL

SELECT 'category', COUNT(*)
FROM pagila_staging.category

UNION ALL

SELECT 'city', COUNT(*)
FROM pagila_staging.city

UNION ALL

SELECT 'country', COUNT(*)
FROM pagila_staging.country

UNION ALL

SELECT 'customer', COUNT(*)
FROM pagila_staging.customer

UNION ALL

SELECT 'film', COUNT(*)
FROM pagila_staging.film

UNION ALL

SELECT 'film_actor', COUNT(*)
FROM pagila_staging.film_actor

UNION ALL

SELECT 'film_category', COUNT(*)
FROM pagila_staging.film_category

UNION ALL

SELECT 'inventory', COUNT(*)
FROM pagila_staging.inventory

UNION ALL

SELECT 'language', COUNT(*)
FROM pagila_staging.language

UNION ALL

SELECT 'payment', COUNT(*)
FROM pagila_staging.payment

UNION ALL

SELECT 'rental', COUNT(*)
FROM pagila_staging.rental

UNION ALL

SELECT 'staff', COUNT(*)
FROM pagila_staging.staff

UNION ALL

SELECT 'store', COUNT(*)
FROM pagila_staging.store

ORDER BY table_name;