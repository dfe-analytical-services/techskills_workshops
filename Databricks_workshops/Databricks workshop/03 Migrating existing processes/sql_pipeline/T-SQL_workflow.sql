/*
===============================================================================
SQL Server Data Processing Code
===============================================================================
This code demonstrates an example of data processing using T-SQL (used in SQL 
Server), including setup, a brief look at data structure, data manipulation, 
joins, and calculations. This demonstrates some of the common functions and 
processes that may be found in T-SQL code that is being translated to work with 
Databricks following legacy servers being decomissioned. Your task is to 
adapt this code to run in Databricks. 
 
This code mirrors the data processing steps in the r_pipeline folder.


Pipeline stages:
  1. Check data - Look at data structure of Autumn 2025 pupils and schools data
  2. Data Manipulation - Select columns and parse metadata, join pupils to 
     schools
  3. Outputs - Produce average pupil premium by Ofsted rating summary
===============================================================================
*/

-- Define catalog being used
USE [catalog_40_copper_analyst_training]

--------------------------------------------------------------------------------
-- 1. Look at data structure
--------------------------------------------------------------------------------

-- Check structure of pupils_autumn_2025 table
SELECT TOP 1000 *
FROM [bronze].[pupils_autumn_2025]

-- Check structure of schools_autumn_2025 table
SELECT TOP 1000 *
FROM [bronze].[schools_autumn_2025]


--------------------------------------------------------------------------------
-- 2. DATA MANIPULATION
-- Select required columns and parse JSON metadata, join pupils to schools
--------------------------------------------------------------------------------

-- Pupils table: select columns and parse JSON metadata
IF OBJECT_ID('tempdb..#pupils_aut') IS NOT NULL DROP TABLE #pupils_aut
SELECT
    [pupil_id],
    [gender],
    [school_urn],
    JSON_VALUE(metadata_json, '$.address.postcode') AS postcode,
    LOWER(JSON_VALUE([metadata_json], '$.sen_status')) AS [sen_status],
    JSON_VALUE([metadata_json], '$.fsm_eligible') AS [fsm_status]
INTO #pupils_aut
FROM [dbo].[analyst_training_pupils_autumn_2025]

-- Schools table: select columns, parse JSON, reformat data in city column, deduplicate
IF OBJECT_ID('tempdb..#schools_aut') IS NOT NULL DROP TABLE #schools_aut
SELECT DISTINCT
    [school_urn],
    UPPER(LEFT([city], 1)) + LOWER(SUBSTRING([city], 2, LEN([city]))) AS [city],
    [school_type],
    JSON_VALUE([metadata_json], '$.ofsted_rating') AS [ofsted_rating],
    CAST(JSON_VALUE([metadata_json], '$.pupil_premium_pct') AS FLOAT) AS [pupil_premium_pct]
INTO #schools_aut
FROM [dbo].[analyst_training_schools_autumn_2025]

-- Join pupils and schools tables ahead of performing calculations
IF OBJECT_ID('tempdb..#pupils_schools_aut') IS NOT NULL DROP TABLE #pupils_schools_aut
SELECT
    p.[pupil_id],
    p.[gender],
    p.[school_urn],
    p.[sen_status],
    p.[fsm_status],
    s.[city],
    s.[school_type],
    s.[ofsted_rating],
    s.[pupil_premium_pct]
INTO #pupils_schools_aut
FROM #pupils_aut p
LEFT JOIN #schools_aut s
    ON p.[school_urn] = s.[school_urn]


-- Investigate relationships in joined data
SELECT
    [gender],
    [ofsted_rating],
    COUNT(*) AS [n]
FROM #pupils_schools_aut
GROUP BY [gender], [ofsted_rating]
ORDER BY [n] DESC


--------------------------------------------------------------------------------
-- 3. OUTPUTS
-- Produce summary output: calculate average pupil premium percentage by Ofsted rating
--------------------------------------------------------------------------------

-- Common Table Expression to calculate median pupil premium 
WITH median_pp_prep AS (
    SELECT
        [ofsted_rating],
        [pupil_premium_pct],
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY [pupil_premium_pct])
            OVER (PARTITION BY [ofsted_rating]) AS median_pupil_premium_pct
    FROM #pupils_schools_aut
)
-- Create final output table
SELECT
    [ofsted_rating],
    COUNT(*) AS [pupils],
    ROUND(AVG([pupil_premium_pct]), 4) AS [avg_pupil_premium_pct],
    ROUND(MAX(median_pupil_premium_pct), 4) AS [median_pupil_premium_pct]
FROM median_pp_prep
GROUP BY [ofsted_rating]
ORDER BY [pupils] DESC;
