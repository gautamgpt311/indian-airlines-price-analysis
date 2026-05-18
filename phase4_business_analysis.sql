-- Phase 4 - Business Analysis --

-- Which routes are significantly underpriced or overpriced compared to the overall network average? Identify revenue opportunities. --
WITH route_avg AS (
    SELECT
        CONCAT(source_city, ' → ', destination_city) AS route,
        ROUND(AVG(price), 2) AS route_avg_price,
        COUNT(*) AS total_flights
    FROM flights
    WHERE class = 'Economy'
    GROUP BY source_city, destination_city
),
with_overall AS (
    SELECT
        route,
        total_flights,
        route_avg_price,
        ROUND(AVG(route_avg_price) OVER(), 2) AS overall_avg_price,
        ROUND((route_avg_price - AVG(route_avg_price) OVER())
            * 100.0 / AVG(route_avg_price) OVER(), 2) AS pct_vs_overall
    FROM route_avg
)
SELECT
    route,
    total_flights,
    route_avg_price,
    overall_avg_price,
    pct_vs_overall,
    CASE
        WHEN pct_vs_overall < -20 THEN 'Underpriced'
        WHEN pct_vs_overall >  20 THEN 'Overpriced'
        ELSE 'Fair'
    END AS pricing_label
FROM with_overall
ORDER BY pct_vs_overall DESC;

-- Build a flight search system that accepts source city, destination city, class and 
-- maximum budget as inputs and returns matching flights sorted by price. --
DELIMITER //
CREATE PROCEDURE search_flights(IN p_source VARCHAR(50), IN p_destination VARCHAR(50), IN p_class VARCHAR(20),
    IN p_max_budget INT)
BEGIN
    SELECT
        REPLACE(airline, '_', ' ') AS airline_name,
        flight AS flight_number,
        source_city,
        destination_city,
        departure_time,
        arrival_time,
        stops,
        duration,
        class,
        price,
        days_left
    FROM flights
    WHERE source_city = p_source
    AND   destination_city = p_destination
    AND   class = p_class
    AND   price <= p_max_budget
    ORDER BY price ASC;
END //
DELIMITER ;

-- Test the search system
CALL search_flights('Delhi', 'Mumbai', 'Economy', 10000);
CALL search_flights('Delhi', 'Mumbai', 'Business', 80000);
CALL search_flights('Bangalore', 'Delhi', 'Economy', 8000);
