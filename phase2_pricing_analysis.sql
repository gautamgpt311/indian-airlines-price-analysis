-- Phase 2 - Pricing Analysis --

-- Which airline is cheapest and most expensive on average — show separately for Economy and Business class. --
SELECT
	REPLACE(airline, '_', ' ') AS airline_name,
    class,
    ROUND(AVG(price), 2) AS avg_price,
    MIN(price) as min_price,
    MAX(price) AS max_price,
    MAX(price) - MIN(price) AS price_range
FROM flights
GROUP BY class, airline
ORDER BY class, avg_price DESC;
 
-- How does the number of stops affect ticket price? Are connecting flights actually more expensive than direct flights? --
SELECT
	stops,
    COUNT(*) AS total_flights,
    ROUND(AVG(price), 2) AS avg_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    ROUND((AVG(price) - (SELECT AVG(price) FROM flights WHERE stops = 'zero')) * 100
		/ (SELECT AVG(price) FROM flights WHERE stops = 'zero'), 2) AS pct_more_than_nonstop
FROM flights
GROUP BY stops;

-- What is the price difference between Business and Economy class for each route? How many times more expensive is Business? --
WITH avg_class AS (
	SELECT
		source_city,
		destination_city,
		ROUND(AVG(CASE WHEN class = 'Economy' THEN price END), 2) AS eco_avg_price,
		ROUND(AVG(CASE WHEN class = 'Business' THEN price END), 2) AS bus_avg_price
	FROM flights
	GROUP BY source_city, destination_city
)
SELECT 
	source_city,
    destination_city,
    eco_avg_price,
    bus_avg_price,
    ROUND(bus_avg_price - eco_avg_price, 2) AS price_difference,
    ROUND(bus_avg_price / eco_avg_price, 2) AS business_times_costlier,
    ROUND((bus_avg_price - eco_avg_price) * 100.0 / eco_avg_price, 2) AS pct_avg_price
FROM avg_class
ORDER BY price_difference DESC;

-- How does booking in advance affect ticket price? Compare prices for last minute, short notice, advanced and early bird bookings. --
SELECT
    CASE 
        WHEN days_left BETWEEN 1 AND 7 THEN 'Last Minute'
        WHEN days_left BETWEEN 8 AND 30 THEN 'Short Notice'
        WHEN days_left BETWEEN 31 AND 60 THEN 'Advanced'
        ELSE 'Early Bird'
    END AS booking_window,
    COUNT(*) AS total_flights,
    ROUND(AVG(CASE WHEN class = 'Economy' THEN price END), 2) AS eco_avg_price,
    ROUND(AVG(CASE WHEN class = 'Business' THEN price END), 2) AS bus_avg_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM flights
GROUP BY booking_window
ORDER BY booking_window;
    
-- Which departure time slot has cheapest and most expensive average prices? Rank them. --
SELECT
	departure_time,
    COUNT(*) AS total_flights,
    ROUND(AVG(CASE WHEN class = 'Economy' THEN price END), 2) AS eco_avg_price,
    ROUND(AVG(CASE WHEN class = 'Business' THEN price END), 2) AS bus_avg_price,
    ROUND(AVG(price), 2) AS avg_price,
    RANK() OVER (ORDER BY AVG(price)) AS rank_departure
FROM flights
GROUP BY departure_time;

-- Which are the 5 most expensive and 5 cheapest routes in the dataset? --
(SELECT
    CONCAT(source_city, ' → ', destination_city) AS route,
    COUNT(*) AS total_flights,
    ROUND(AVG(price), 2) AS avg_price,
    'Most Expensive' AS category
FROM flights
GROUP BY source_city, destination_city
ORDER BY avg_price DESC
LIMIT 5)

UNION ALL

-- Top 5 cheapest routes
(SELECT
    CONCAT(source_city, ' → ', destination_city)     AS route,
    COUNT(*) AS total_flights,
    ROUND(AVG(price), 2) AS avg_price,
    'Cheapest' AS category
FROM flights
GROUP BY source_city, destination_city
ORDER BY avg_price ASC
LIMIT 5)

ORDER BY category, avg_price DESC;

-- Which airline has the most consistent pricing — lowest variation — on each route? --
WITH price_consistency AS (
    SELECT
        REPLACE(airline, '_', ' ')           AS airline_name,
        CONCAT(source_city,' → ',destination_city) AS route,
        COUNT(*)                             AS total_flights,
        ROUND(AVG(price), 2)                 AS avg_price,
        ROUND(STDDEV(price), 2)              AS std_dev,
        ROUND(STDDEV(price) / AVG(price) * 100, 2) AS coeff_variation
    FROM flights
    GROUP BY airline, source_city, destination_city
)
SELECT
    airline_name,
    route,
    total_flights,
    avg_price,
    std_dev,
    coeff_variation,
    RANK() OVER(ORDER BY coeff_variation) AS consistency_rank
FROM price_consistency
WHERE total_flights >= 100
ORDER BY consistency_rank
LIMIT 15;

-- Find all routes that exist in Economy class but have no Business class option. --
SELECT 
	DISTINCT e.source_city,
	e.destination_city,
    CONCAT(e.source_city, ' → ', e.destination_city) AS route,
    'Economy Only' AS availability
FROM flights e
LEFT JOIN flights b 
    ON e.source_city = b.source_city
    AND e.destination_city = b.destination_city
    AND b.class = 'Business'
WHERE e.class = 'Economy'
AND b.source_city IS NULL
ORDER BY e.source_city;