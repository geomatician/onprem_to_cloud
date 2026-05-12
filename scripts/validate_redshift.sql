SELECT 'actor' AS table_name, COUNT(*) FROM actor
UNION ALL
SELECT 'address', COUNT(*) FROM address
UNION ALL
SELECT 'category', COUNT(*) FROM category
UNION ALL
SELECT 'city', COUNT(*) FROM city
UNION ALL
SELECT 'country', COUNT(*) FROM country
UNION ALL
SELECT 'customer', COUNT(*) FROM customer
UNION ALL
SELECT 'film', COUNT(*) FROM film
UNION ALL
SELECT 'film_actor', COUNT(*) FROM film_actor
UNION ALL
SELECT 'film_category', COUNT(*) FROM film_category
UNION ALL
SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL
SELECT 'language', COUNT(*) FROM language
UNION ALL
SELECT 'payment', COUNT(*) FROM payment
UNION ALL
SELECT 'rental', COUNT(*) FROM rental
UNION ALL
SELECT 'staff', COUNT(*) FROM staff
UNION ALL
SELECT 'store', COUNT(*) FROM store
ORDER BY table_name;