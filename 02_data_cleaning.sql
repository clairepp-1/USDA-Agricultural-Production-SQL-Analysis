
-- USDA Agricultural Production Analysis
-- 02_data_cleaning.sql

-- 1. Cheese Production
CREATE VIEW cheese_production_clean AS
SELECT
    Year,
    Period,
    Geo_Level,
    State_ANSI,
    Commodity_ID,
    Domain,
    Value AS OriginalValue,
    CASE
        WHEN TRIM(Value) IN ('(D)', '(NA)')
            THEN NULL
        ELSE CAST(REPLACE(Value, ',', '') AS INTEGER)
    END AS CleanedValue
FROM cheese_production;


-- 2. Egg Production
CREATE VIEW egg_production_clean AS
SELECT
    Year,
    Period,
    Geo_Level,
    State_ANSI,
    Commodity_ID,
    Value AS OriginalValue,
    CASE
        WHEN TRIM(Value) IN ('(D)', '(NA)')
            THEN NULL
        ELSE CAST(REPLACE(Value, ',', '') AS INTEGER)
    END AS CleanedValue
FROM egg_production;


-- 3. Yogurt Production
CREATE VIEW yogurt_production_clean AS
SELECT
    Year,
    Period,
    Geo_Level,
    State_ANSI,
    Commodity_ID,
    Domain,
    Value AS OriginalValue,
    CASE
        WHEN TRIM(Value) IN ('(D)', '(NA)')
            THEN NULL
        ELSE CAST(REPLACE(Value, ',', '') AS INTEGER)
    END AS CleanedValue
FROM yogurt_production;
