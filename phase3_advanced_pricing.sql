-- Phase 3 - Advanced Pricing --

-- Track how average Economy ticket price changes day by day as the departure date approaches. Is it getting more expensive closer to departure? --
WITH daily_avg AS (
	SELECT 
		days_left,
		ROUND(AVG(price), 2) AS avg_price
	FROM flights
    WHERE class = 'Economy'
	GROUP BY days_left
),
with_lags AS (
	SELECT
		days_left,
        avg_price,
        LAG(avg_price) OVER(ORDER BY days_left DESC) AS prev_day_price
	FROM daily_avg
)
SELECT 
	days_left,
    avg_price,
    prev_day_price,
    ROUND(avg_price - prev_day_price, 2) AS price_change,
    ROUND((avg_price - prev_day_price) * 100.0 / prev_day_price, 2) AS pct_change
FROM with_lags
ORDER BY days_left DESC;
    
-- For each flight on a route, identify the next cheaper alternative available on the same route. --
WITH airline_details AS (
	SELECT 
		REPLACE(airline, '_', ' ') AS airline_name,
        source_city,
        destination_city,
		CONCAT(source_city, '-', destination_city) AS route,
		price,
		departure_time
	FROM flights
    WHERE class = 'Economy'
),
lead_price AS (
	SELECT
		airline_name,
		route,
        departure_time,
        price,
		LEAD(price) OVER (
			PARTITION BY source_city, destination_city
            ORDER BY route ASC) AS next_flight_price
	FROM airline_details
)
SELECT
	airline_name,
    route,
    departure_time,
    price,
    next_flight_price,
    ROUND((next_flight_price - price), 2) AS price_difference,
    CASE WHEN price <= next_flight_price THEN 'YES' ELSE 'NO' END AS cheaper
FROM lead_price
WHERE next_flight_price IS NOT NULL
ORDER BY route, price ASC
LIMIT 20;

-- Divide all Economy flights into 4 equal price segments — Budget, Economy, Premium and Luxury. Which airlines dominate each segment? --
WITH price_buckets AS (
    SELECT
        REPLACE(airline, '_', ' ')  AS airline_name,
        source_city,
        destination_city,
        price,
        NTILE(4) OVER(ORDER BY price ASC) AS bucket_number
    FROM flights
    WHERE class = 'Economy'
),
bucket_summary AS (
    SELECT
        CASE bucket_number
            WHEN 1 THEN '1. Budget'
            WHEN 2 THEN '2. Economy'
            WHEN 3 THEN '3. Premium'
            WHEN 4 THEN '4. Luxury'
        END                     AS price_segment,
        airline_name,
        COUNT(*)                AS total_flights,
        MIN(price)              AS min_price,
        MAX(price)              AS max_price,
        ROUND(AVG(price), 2)   AS avg_price
    FROM price_buckets
    GROUP BY bucket_number, airline_name
)
SELECT
    price_segment,
    airline_name,
    total_flights,
    min_price,
    max_price,
    avg_price,
    ROUND(total_flights * 100.0 / 
        SUM(total_flights) OVER(PARTITION BY price_segment), 2) AS pct_in_segment
FROM bucket_summary
ORDER BY price_segment, total_flights DESC;

-- What percentile does each airline's average price fall in? Label them as cheapest, mid-range, premium or most expensive. --
WITH airline_avg AS (
    SELECT
        REPLACE(airline, '_', ' ') AS airline_name,
        ROUND(AVG(price), 2)       AS avg_price
    FROM flights
    WHERE class = 'Economy'
    GROUP BY airline
)
SELECT
    airline_name,
    avg_price,
    ROUND(PERCENT_RANK() OVER(ORDER BY avg_price ASC), 2) AS percent_ranks,
    CASE
        WHEN PERCENT_RANK() OVER(ORDER BY avg_price ASC) <= 0.25 THEN 'Cheapest 25%'
        WHEN PERCENT_RANK() OVER(ORDER BY avg_price ASC) <= 0.50 THEN 'Mid Range'
        WHEN PERCENT_RANK() OVER(ORDER BY avg_price ASC) <= 0.75 THEN 'Premium'
        ELSE 'Most Expensive'
    END AS price_tier
FROM airline_avg
ORDER BY avg_price ASC;

-- For each airline track weekly average prices and show how prices change week over week as departure approaches. --

WITH week_bucket AS (
    SELECT
        CASE 
            WHEN days_left BETWEEN 1  AND 7  THEN 'Week 1'
            WHEN days_left BETWEEN 8 AND 14 THEN 'Week 2'
            WHEN days_left BETWEEN 15 AND 21 THEN 'Week 3'
            WHEN days_left BETWEEN 22 AND 28 THEN 'Week 4'
            ELSE 'Week 5+'
        END AS week_group,
        REPLACE(airline, '_', ' ') AS airline_name,
        price
    FROM flights
    WHERE class = 'Economy'
),
weekly_avg AS (
    SELECT
        week_group,
        airline_name,
        ROUND(AVG(price), 2) AS avg_price,
        COUNT(*) AS total_flights
    FROM week_bucket                  
    GROUP BY week_group, airline_name
),
with_lag AS (
    SELECT
        week_group,
        airline_name,
        avg_price,
        total_flights,
        LAG(avg_price) OVER(
            PARTITION BY airline_name  
            ORDER BY week_group ASC
        ) AS prev_week_price
    FROM weekly_avg
)
SELECT
    week_group,
    airline_name,
    avg_price,
    prev_week_price,
    ROUND(avg_price - prev_week_price, 2) AS price_change,
    ROUND((avg_price - prev_week_price) 
        * 100.0 / prev_week_price, 2) AS pct_change
FROM with_lag
ORDER BY airline_name, week_group;
	
-- Find the 3 cheapest flight options for each route and show how much a passenger saves vs the most expensive option. --
WITH ranked_flights AS (
    SELECT
        CONCAT(source_city, ' → ', destination_city) AS route,
        REPLACE(airline, '_', ' ') AS airline_name,
        price,
        departure_time,
        ROW_NUMBER() OVER(
            PARTITION BY source_city, destination_city
            ORDER BY price ASC
        ) AS price_rank,
        MAX(price) OVER(
            PARTITION BY source_city, destination_city
        ) AS max_route_price
    FROM flights
    WHERE class = 'Economy'
)
SELECT
    route,
    price_rank,
    airline_name,
    price,
    departure_time,
    max_route_price - price AS savings_vs_expensive
FROM ranked_flights
WHERE price_rank <= 3
ORDER BY route, price_rank;