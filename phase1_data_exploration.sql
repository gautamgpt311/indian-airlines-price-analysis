-- Phase 1 - Data Exploration (EDA) --

-- Get a complete snapshot of the dataset — total flights, unique airlines, unique routes, price range and booking window range in one query. --
SELECT 
	COUNT(*) AS total_flights,
    COUNT(DISTINCT airline) AS unique_airlines,
    COUNT(DISTINCT source_city) AS unique_source_city,
    COUNT(DISTINCT destination_city) AS unique_destination_city,
    COUNT(DISTINCT CONCAT(source_city, '-', destination_city)) AS unique_route,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    ROUND(AVG(price), 2) AS avg_price,
    MIN(days_left) AS min_days_left,
    MAX(days_left) AS max_days_left
FROM flights;

-- Find all flights from airlines whose name contains the word "Air". Also find flights with specific code patterns and cities ending with particular letters. --
SELECT 
    COUNT(*) AS flights_with_air,
    COUNT(DISTINCT airline) AS matching_airlines
FROM flights
WHERE airline LIKE '%Air%';

-- Flights starting with 'AI' (Air India code)
SELECT 
    COUNT(*) AS ai_flights,
    COUNT(DISTINCT flight) AS unique_ai_flights
FROM flights
WHERE flight LIKE 'AI-%';

-- Economy flights where source city ends with 'i'
SELECT 
    source_city,
    COUNT(*) AS total_flights
FROM flights
WHERE class = 'Economy'
AND source_city LIKE '%i'
GROUP BY source_city
ORDER BY total_flights DESC;

-- Clean and explore airline names
-- show them in uppercase, replace underscores with spaces, show name lengths and 
-- extract the airline code from the flight number. --
SELECT 
	DISTINCT UPPER(airline) AS unique_airlines
FROM flights;

-- replace underscores with spaces
SELECT 
	DISTINCT(REPLACE(airline, '_','-')) AS unique_airline_name
FROM flights;

-- show name lengths
SELECT
	airline,
    LENGTH(airline) AS unique_airline_length
FROM flights
GROUP BY airline;

-- extract the airline code
SELECT
	DISTINCT SUBSTRING(flight, 1, 2) AS flight_code
FROM flights;

-- Identify data quality issues — 
-- find NULL values, suspicious prices, invalid durations and 
-- flights where source and destination are the same city. --
SELECT
    SUM(CASE WHEN airline IS NULL THEN 1 ELSE 0 END)          AS null_airline,
    SUM(CASE WHEN flight IS NULL THEN 1 ELSE 0 END)           AS null_flight,
    SUM(CASE WHEN source_city IS NULL THEN 1 ELSE 0 END)      AS null_source,
    SUM(CASE WHEN destination_city IS NULL THEN 1 ELSE 0 END) AS null_destination,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END)            AS null_price,
    SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END)         AS null_duration,
    SUM(CASE WHEN days_left IS NULL THEN 1 ELSE 0 END)        AS null_days_left,
    SUM(CASE WHEN class IS NULL THEN 1 ELSE 0 END)            AS null_class
FROM flights;

-- Suspicious prices
SELECT COUNT(*) AS suspicious_prices
FROM flights
WHERE price < 1000 OR price > 100000;

-- Invalid duration
SELECT COUNT(*) AS invalid_duration
FROM flights
WHERE duration <= 0;

-- Same source and destination
SELECT COUNT(*) AS same_city_flights
FROM flights
WHERE source_city = destination_city;