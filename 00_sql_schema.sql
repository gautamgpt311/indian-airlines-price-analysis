-- ============================================================
-- Project  : Indian Airlines Ticket Price Analysis
-- File     : 00_sql_schema.sql
-- Tool     : MySQL 8.0
-- Dataset  : Kaggle — Indian Airlines Ticket Price Dataset
-- Rows     : 300,153 tickets | 11 columns | 1 table
-- ============================================================

-- Create the database
CREATE DATABASE IF NOT EXISTS airlines_db;
USE airlines_db;

-- Create the flights table
CREATE TABLE flights (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    airline          VARCHAR(50),
    flight           VARCHAR(20),
    source_city      VARCHAR(50),
    departure_time   VARCHAR(20),
    stops            VARCHAR(20),
    arrival_time     VARCHAR(20),
    destination_city VARCHAR(50),
    class            VARCHAR(20),
    duration         DECIMAL(6,2),
    days_left        INT,
    price            INT
);

-- Load the flights data
-- Why @skip is used:
--   The CSV contains an index column at position 1
--   which has no corresponding table column.
--   We load it into @skip variable and ignore it.
-- ------------------------------------------------------------
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Indian_Airlines.csv'
INTO TABLE flights
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @skip, airline, flight, source_city,
    departure_time, stops, arrival_time,
    destination_city, class, duration,
    days_left, price
);

-- Verify data loaded correctly
SELECT COUNT(*) AS total_records FROM flights;
-- Result: 300,153 rows

SELECT DISTINCT class FROM flights;
-- Result: Economy, Business

SELECT DISTINCT airline FROM flights;
-- Result: 6 airlines