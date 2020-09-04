/* Query & Slide 1 - Family Friendly Movie Quartiles */

SELECT category, quartile, COUNT(title)
FROM
(SELECT f.title title, 
		c.name category, 
        f.rental_duration duration,
        NTILE(4) OVER (ORDER BY f.rental_duration) quartile
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON fc.category_id = c.category_id
WHERE c.name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
ORDER BY 3) tb1
GROUP BY 1,2
ORDER BY 1,2;

/* Query & Slide 2 -  Store Comparison: Rentals per month & year */

SELECT 
    DATE_PART('month', r.rental_date) Rental_month,
    DATE_PART('year', r.rental_date) Rental_year,
    s.store_id Store_ID,
    COUNT(r.rental_id) Count_rentals
FROM
    store s
        JOIN
    staff st ON st.store_id = s.store_id
        JOIN
    rental r ON st.staff_id = r.staff_id
GROUP BY 1 , 2 , 3
ORDER BY store_id , rental_year , rental_month , Count_rentals DESC;

/* Query & Slide 3 -  Difference in Payment by Our Top 10 Customers */

WITH top_10 AS (SELECT CONCAT(c.first_name, ' ', c.last_name) fullname, SUM(p.amount) pay_amount
FROM customer c 
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY 1
ORDER BY 2 desc
LIMIT 10),

top_10_info AS (SELECT 
DATE_TRUNC('month', p.payment_date) payment_month,
CONCAT(c.first_name, ' ', c.last_name) fullname,
SUM(p.amount) pay_amount,
COUNT(p.amount) pay_countpermonth
FROM customer c
JOIN payment p 
ON c.customer_id = p.customer_id
WHERE CONCAT(c.first_name, ' ', c.last_name) IN (SELECT fullname FROM top_10)
GROUP BY 1,2
ORDER BY 2, 1, 3 DESC),

top_10_lag AS (SELECT payment_month, fullname, pay_amount, LAG(pay_amount) OVER (ORDER BY fullname,payment_month) AS lag
FROM top_10_info)

SELECT payment_month, fullname, pay_amount, pay_amount - lag AS diff
FROM top_10_lag
ORDER BY 4 DESC NULLS LAST;


/* Query & Slide 4 - Average Customer Spending Per Rental */

SELECT 
    COUNT(c.customer_id) AS customers,
    co.country,
    SUM(p.amount),
    SUM(p.amount) / COUNT(c.customer_id) AS per_country
FROM
    customer c
        JOIN
    address a ON c.address_id = a.address_id
        JOIN
    city ci ON ci.city_id = a.city_id
        JOIN
    country co ON co.country_id = ci.country_id
        JOIN
    payment p ON c.customer_id = p.customer_id
GROUP BY 2
ORDER BY 4 DESC

