---- EXAMPLE SQL SECTION

----------------------------------------
-- You might recognise this SQL code from the previous 'sql_pipeline' migration process.
-- It is often the case that a data processing pipeline will use SQL initially for 
-- querying and manipulating tables, before turning to R for more complex analysis.
-- We have replicated this combined approach here, with initial processing performed in 
-- this 1_sql_section.sql file, and later analysis in the 2_r_section.R file.

-- Define catalog being used
--USE CATALOG catalog_40_copper_analyst_training;

-- Check structure of pupils_autumn_2024 table
--SELECT * FROM catalog_40_copper_analyst_training.bronze.pupils_autumn_2024 LIMIT 1000;

-- Check structure of schools_autumn_2024 table
--SELECT * FROM catalog_40_copper_analyst_training.bronze.schools_autumn_2024 LIMIT 1000;

-- Check structure of assessments table
--SELECT * FROM catalog_40_copper_analyst_training.bronze.assessments LIMIT 1000;

-- Pupils table: select columns and parse JSON metadata
WITH pupils_aut AS
(SELECT 
  pupil_id,
  gender,
  school_urn,
  metadata_json:address:postcode AS postcode,
  LOWER(metadata_json:sen_status) AS sen_status,
  metadata_json:fsm_eligible AS fsm_status
FROM catalog_40_copper_analyst_training.bronze.pupils_autumn_2024),

-- Schools table: select columns, parse JSON, reformat data in city column, deduplicate
schools_aut AS -- We use TEMP here instead of TEMPORARY in the above example - these can be used interchangeably
(SELECT DISTINCT
  school_urn,
  INITCAP(city) AS city,
  school_type,
  REPLACE(metadata_json:ofsted_rating, '"', '') AS ofsted_rating,
  CAST(metadata_json:pupil_premium_pct AS DOUBLE) AS pupil_premium_pct
FROM catalog_40_copper_analyst_training.bronze.schools_autumn_2024),

-- Assessments table: select columns, standardise subject, deduplicate
assessments_aut AS -- We use TEMP here instead of TEMPORARY in the above example - these can be used interchangeably
(SELECT DISTINCT
  assessment_id,
  pupil_id,
  school_urn,
  CASE 
    WHEN LOWER(subject) LIKE '%e' THEN 'English'
    WHEN LOWER(subject) LIKE '%m' THEN 'Maths'
    WHEN LOWER(subject) LIKE '%s' THEN 'Science' 
  ELSE 'Unknown' END AS subject,
  score,
  grade
FROM catalog_40_copper_analyst_training.bronze.assessments
WHERE term = 'Autumn 2024'),

-- Join pupils, assessments, and schools tables ahead of performing calculations
assessments_schools_aut AS -- and here we create a temporary table rather than a view
(SELECT 
  p.*,
  s.city,
  s.school_type,
  s.ofsted_rating,
  s.pupil_premium_pct,
  a.assessment_id,
  a.subject,
  a.score,
  a.grade
FROM pupils_aut p
LEFT JOIN assessments_aut a
  ON p.pupil_id = a.pupil_id
LEFT JOIN schools_aut s
  ON p.school_urn = s.school_urn)

-- Print final output as the result to read into R
SELECT *
FROM assessments_schools_aut;
