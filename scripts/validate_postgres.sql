SELECT 'actor' AS "table name", COUNT(*) AS "count"
FROM public.actor

UNION ALL

SELECT 'address', COUNT(*)
FROM public.address

UNION ALL

SELECT 'category', COUNT(*)
FROM public.category

UNION ALL

SELECT 'city', COUNT(*)
FROM public.city

UNION ALL

SELECT 'country', COUNT(*)
FROM public.country

UNION ALL

SELECT 'customer', COUNT(*)
FROM public.customer

UNION ALL

SELECT 'film', COUNT(*)
FROM public.film

UNION ALL

SELECT 'film_actor', COUNT(*)
FROM public.film_actor

UNION ALL

SELECT 'film_category', COUNT(*)
FROM public.film_category

UNION ALL

SELECT 'inventory', COUNT(*)
FROM public.inventory

UNION ALL

SELECT 'language', COUNT(*)
FROM public.language

UNION ALL

SELECT 'payment', COUNT(*)
FROM public.payment

UNION ALL

SELECT 'rental', COUNT(*)
FROM public.rental

UNION ALL

SELECT 'staff', COUNT(*)
FROM public.staff

UNION ALL

SELECT 'store', COUNT(*)
FROM public.store

ORDER BY "table name";