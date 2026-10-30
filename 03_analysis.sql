-- USDA Agricultural Production Analysis
-- 03_analysis.sql
-- ==================================================
-- Database: SQLite
-- Tool: DBeaver
-- Data Source: USDA Agricultural Production Data
--
-- Objective:
-- Analyze milk production trends, geographic concentration, and annual growth.
-- ==================================================
-- PART A: Foundational SQL Analysis
-- Course Final Project Queries

-- Q1: Total milk production in 2023
-- Note: Available records cover Jan-May, not full year.
SELECT
    SUM(Value) AS TotalMilkProduction
FROM milk_production
WHERE Year = 2023
  AND Geo_Level = 'STATE'
  AND Period IN ('JAN', 'FEB', 'MAR', 'APR', 'MAY');


-- Q2: States with both honey and milk records in 2022
SELECT DISTINCT
    s.State
FROM honey_production AS h
INNER JOIN milk_production AS m
    ON h.State_ANSI = m.State_ANSI
INNER JOIN state_lookup AS s
    ON h.State_ANSI = s.State_ANSI
WHERE h.Year = 2022
  AND m.Year = 2022
ORDER BY s.State;


-- Q3: States without milk production records in 2023
SELECT
    s.State,
    s.State_ANSI
FROM state_lookup AS s
LEFT JOIN milk_production AS m
    ON s.State_ANSI = m.State_ANSI
    AND m.Year = 2023
WHERE m.State_ANSI IS NULL
ORDER BY s.State;


-- Q4: Yogurt production in 2022 in states
-- with cheese production records in 2023
SELECT
    SUM(y.CleanedValue) AS TotalYogurtProduction
FROM yogurt_production_clean AS y
WHERE y.Year = 2022
  AND y.State_ANSI IN (
      SELECT DISTINCT c.State_ANSI
      FROM cheese_production AS c
      WHERE c.Year = 2023
  );

-- PART B: Advanced SQL Analysis
-- Additional Portfolio Analysis

-- Analysis 1: Top 10 Milk-Producing States (2022)
SELECT
    s.State,
    SUM(m.Value) AS TotalMilkProduction
FROM milk_production AS m
INNER JOIN state_lookup AS s
    ON m.State_ANSI = s.State_ANSI
WHERE m.Year = 2022
  AND m.Period = 'YEAR'
  AND m.Geo_Level = 'STATE'
GROUP BY s.State
ORDER BY TotalMilkProduction DESC
LIMIT 10;

-- Analysis 2: State Production Share (2022)
WITH StateProduction AS (
    SELECT
        s.State,
        SUM(m.Value) AS TotalProduction
    FROM milk_production AS m
    INNER JOIN state_lookup AS s
        ON m.State_ANSI = s.State_ANSI
    WHERE m.Year = 2022
      AND m.Period = 'YEAR'
      AND m.Geo_Level = 'STATE'
    GROUP BY s.State
)
SELECT
    State,
    TotalProduction,
    ROUND(
        100.0 * TotalProduction /
        SUM(TotalProduction) OVER (),
        2
    ) AS ProductionShare
FROM StateProduction
ORDER BY TotalProduction DESC
LIMIT 10;

-- Analysis 3: Year-over-Year Milk Production Growth
WITH AnnualProduction AS (
    SELECT
        Year,
        SUM(Value) AS TotalProduction,
        COUNT(DISTINCT State_ANSI) AS StateCount
    FROM milk_production
    WHERE Period = 'YEAR'
      AND Geo_Level = 'STATE'
      AND Year IN (2021, 2022)
      AND State_ANSI IS NOT NULL
    GROUP BY Year
),
GrowthAnalysis AS (
    SELECT
        Year,
        TotalProduction,
        StateCount,
        LAG(TotalProduction) OVER (
            ORDER BY Year
        ) AS PreviousYearProduction
    FROM AnnualProduction
)
SELECT
    Year,
    TotalProduction,
    StateCount,
    ROUND(
        100.0 * (
            TotalProduction - PreviousYearProduction
        ) / NULLIF(PreviousYearProduction, 0),
        2
    ) AS YoYGrowthPercent
FROM GrowthAnalysis
ORDER BY Year;
-- Validation: Check Consistent Reporting States
WITH States2021 AS (
    SELECT DISTINCT State_ANSI
    FROM milk_production
    WHERE Year = 2021
      AND Period = 'YEAR'
      AND Geo_Level = 'STATE'
      AND State_ANSI IS NOT NULL
),
States2022 AS (
    SELECT DISTINCT State_ANSI
    FROM milk_production
    WHERE Year = 2022
      AND Period = 'YEAR'
      AND Geo_Level = 'STATE'
      AND State_ANSI IS NOT NULL
)
SELECT
    'Only in 2021' AS Difference,
    State_ANSI
FROM States2021
WHERE State_ANSI NOT IN (
    SELECT State_ANSI FROM States2022
)

UNION ALL

SELECT
    'Only in 2022' AS Difference,
    State_ANSI
FROM States2022
WHERE State_ANSI NOT IN (
    SELECT State_ANSI FROM States2021
);
