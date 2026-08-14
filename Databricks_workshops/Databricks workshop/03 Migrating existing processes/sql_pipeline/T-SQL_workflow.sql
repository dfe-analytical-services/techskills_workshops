/*
===============================================================================
T-SQL Pipeline: Pupils & Schools Autumn 2025
===============================================================================
This script is the T-SQL (SQL Server) equivalent of the Databricks notebook
T-SQL_workflow, which itself mirrors the R pipeline (r_pipeline/).

Pipeline stages:
  1. Data Ingestion  - Read pupils and schools autumn 2025 from bronze tables
  2. Data Manipulation - Parse JSON metadata, select columns, join
  3. Outputs - Produce avg pupil premium by Ofsted rating summary

Key differences from Databricks SQL:
  - TEMP VIEWS -> #temp tables (SELECT INTO)
  - metadata_json:key -> JSON_VALUE(metadata_json, '$.key')
  - INITCAP() -> UPPER(LEFT()) + LOWER(SUBSTRING())
  - PERCENTILE() -> PERCENTILE_CONT() WITHIN GROUP
  - LIMIT n -> TOP n
===============================================================================
*/

USE [MDR_Modelling_DSAG_PRI_PERF]

--------------------------------------------------------------------------------
-- 1. Look at data structure
--------------------------------------------------------------------------------

-- Preview pupils data
SELECT TOP 1000 *
FROM [dbo].[analyst_training_pupils_autumn_2025]

-- Preview schools data
SELECT TOP 1000 *
FROM [dbo].[analyst_training_schools_autumn_2025]


--------------------------------------------------------------------------------
-- 2. DATA MANIPULATION
-- Parse JSON metadata, select required columns, join pupils to schools
--------------------------------------------------------------------------------

-- Pupils: select columns and parse JSON metadata
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

-- Schools: select columns, parse JSON, title-case city, deduplicate
IF OBJECT_ID('tempdb..#schools_aut') IS NOT NULL DROP TABLE #schools_aut
SELECT DISTINCT
    [school_urn],
    UPPER(LEFT([city], 1)) + LOWER(SUBSTRING([city], 2, LEN([city]))) AS [city],
    [school_type],
    JSON_VALUE([metadata_json], '$.ofsted_rating') AS [ofsted_rating],
    CAST(JSON_VALUE([metadata_json], '$.pupil_premium_pct') AS FLOAT) AS [pupil_premium_pct]
INTO #schools_aut
FROM [dbo].[analyst_training_schools_autumn_2025]

-- Join pupils and schools
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
-- Produce avg pupil premium by Ofsted rating
--------------------------------------------------------------------------------

-- CTE to calculate median pupil premium 
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
