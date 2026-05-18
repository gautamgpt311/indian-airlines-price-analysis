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