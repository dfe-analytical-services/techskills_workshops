---- EXAMPLE SQL SECTION

----------------------------------------
-- You might recognise this SQL code from the previous 'sql_pipeline' migration process.
-- It is often the case that a teams data processing pipeline will use SQL initially for 
-- querying and manipulating tables, before turning to R for more complex analysis.
-- We have replicated this combined approach here, with initial processing performed in 
-- this 1_sql_section.sql file, and later analysis in the 2_r_section.R file.

-- Define catalog being used
USE [MDR_Modelling_DSAG_analyst_training]

--------------------------------------------------------------------------------
-- 1. Look at data structure
--------------------------------------------------------------------------------

-- Check structure of pupils_autumn_2025 table
SELECT TOP 1000 *
FROM [dbo].[analyst_training_pupils_autumn_2025]

-- Check structure of schools_autumn_2025 table
SELECT TOP 1000 *
FROM [dbo].[analyst_training_schools_autumn_2025]


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

-- Note that since we cannot write to the analyst training catalog, we will just visualise the output 
-- here, and use a CSV with the same data at the beginning of our R process
SELECT *
FROM #pupils_schools_aut;
