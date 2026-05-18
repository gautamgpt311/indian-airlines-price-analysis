# Indian Airlines Ticket Price Analysis — SQL Analysis

## About This Project

After completing my flight delays project I wanted to work on something closer to the Indian aviation market. This dataset covers real ticket pricing data from Indian airlines including IndiGo, Air India, Vistara, SpiceJet and AirAsia — airlines I see operating daily.

What interested me most was understanding how airlines price tickets dynamically — why the same route costs differently depending on when you book, what time you fly and how many stops your flight has.

## Dataset
- Source: Kaggle — Indian Airlines Ticket Price Dataset
- Size: 300,153 tickets | 11 columns | 1 table
- Tool: MySQL 8.0, MySQL Workbench

## What I Investigated

- Which airline is cheapest and most expensive on average?
- How does booking in advance affect ticket price?
- Does departure time affect how much you pay?
- How much more expensive is Business vs Economy class?
- Which routes are most overpriced?
- How do stops affect ticket price?

## Key Findings

**Cheapest vs Most Expensive**
AirAsia consistently offers the lowest Economy prices while Air India dominates the premium end. Business class tickets are 7 to 8 times more expensive than Economy on the same route.

**Book Early — It Matters**
Last minute tickets (1-7 days before departure) are nearly 70% more expensive than tickets booked 31-60 days in advance. The sweet spot for cheapest prices is booking 31 to 60 days ahead.

**Best Time to Fly Cheaply**
Early morning flights are consistently the cheapest across all airlines. Night flights are the most expensive — sometimes 40% higher than early morning on the same route.

**Stops Cost More**
Connecting flights are actually more expensive than direct flights on average — every extra stop adds roughly 20% to the ticket price.

## Challenges I Faced

The dataset stored airline names with underscores like Air_India instead of spaces. I used REPLACE() and string functions throughout the analysis to clean and present names properly.

Working with price data across Economy and Business class in a single table required pivoting — using CASE WHEN to split one column into two separate columns for comparison. This was a new technique I learned during this project.

I also discovered that using PERCENT_RANK() and NTILE() window functions to segment pricing data gave much more meaningful insights than simple averages alone.

## SQL Skills Demonstrated

- String functions — REPLACE, UPPER, LENGTH, 
  SUBSTRING, LOCATE
- LIKE pattern matching for text searches
- CASE WHEN pivoting — rows to columns
- UNION ALL for combining result sets
- Subqueries inside SELECT
- STDDEV for price consistency analysis
- Window functions — LAG, LEAD, NTILE, 
  PERCENT_RANK, ROW_NUMBER
- Chained CTEs for multi-step analysis
- LEFT JOIN to find missing data patterns

## Project Structure

```
├── 00_sql_schema.sql
├── phase1_data_exploration.sql
├── phase2_pricing_analysis.sql
├── phase3_advanced_pricing.sql
├── phase4_business_strategy.sql
└── README.md
```

## How to Run

1. Run 00_sql_schema.sql to create database and table
2. Download dataset from Kaggle
3. Place CSV in MySQL uploads folder
4. Run LOAD DATA INFILE from 00_sql_schema.sql
5. Execute phases 1 through 4 in order
