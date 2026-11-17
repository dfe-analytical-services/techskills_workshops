---- EXAMPLE SQL SECTION

----------------------------------------
-- You might recognise this SQL code from the previous 'sql_pipeline' migration process.
-- It is often the case that a data processing pipeline will use SQL initially for 
-- querying and manipulating tables, before turning to R for more complex analysis.
-- We have replicated this combined approach here, with initial processing performed in 
-- this 1_sql_section.sql file, and later analysis in the 2_r_section.R file.

-- Define catalog being used
USE CATALOG catalog_40_copper_analyst_training;

-- Check structure of pupils_autumn_2024 table
SELECT * FROM catalog_40_copper_analyst_training.bronze.pupils_autumn_2024 LIMIT 1000;

-- Check structure of schools_autumn_2024 table
SELECT * FROM catalog_40_copper_analyst_training.bronze.schools_autumn_2024 LIMIT 1000;

-- Check structure of assessments table
SELECT * FROM catalog_40_copper_analyst_training.bronze.assessments LIMIT 1000;

-- Pupils table: select columns and parse JSON metadata
CREATE OR REPLACE TEMPORARY TABLE pupils_aut AS
SELECT 
  pupil_id,
  gender,
  school_urn,
  metadata_json:address:postcode AS postcode,
  LOWER(metadata_json:sen_status) AS sen_status,
  metadata_json:fsm_eligible AS fsm_status
FROM catalog_40_copper_analyst_training.bronze.pupils_autumn_2024;

-- Schools table: select columns, parse JSON, reformat data in city column, deduplicate
CREATE OR REPLACE TEMPORARY TABLE schools_aut AS -- We use TEMP here instead of TEMPORARY in the above example - these can be used interchangeably
SELECT DISTINCT
  school_urn,
  INITCAP(city) AS city,
  school_type,
  REPLACE(metadata_json:ofsted_rating, '"', '') AS ofsted_rating,
  CAST(metadata_json:pupil_premium_pct AS DOUBLE) AS pupil_premium_pct
FROM catalog_40_copper_analyst_training.bronze.schools_autumn_2024;

-- Assessments table: select columns, standardise subject, deduplicate
CREATE OR REPLACE TEMPORARY TABLE assessments_aut AS -- We use TEMP here instead of TEMPORARY in the above example - these can be used interchangeably
SELECT DISTINCT
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
WHERE term = 'Autumn 2024';

-- Join pupils, assessments, and schools tables ahead of performing calculations
CREATE OR REPLACE TEMPORARY TABLE assessments_schools_aut AS -- and here we create a temporary table rather than a view
SELECT 
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
  ON p.school_urn = s.school_urn;


-- Since we don't have write access to the analyst training catalog, you will have to your team's Databricks 
-- catalog in a schema called <your_name> ----

-- Specifying your team's catalog explicitly, create a schema called <your_name> if it doesn't already exist
-- NOTE: You will need to change the catalog name to your own team's catalog name, and "rtarrant" to your own name!
CREATE SCHEMA IF NOT EXISTS catalog_40_copper_statistics_services.rtarrant;

-- Create the table, specifying the full three-level namespace (as we are using a different catalog and schema to what is specified initially)
CREATE OR REPLACE TABLE catalog_40_copper_statistics_services.rtarrant.assessments_schools_aut AS
SELECT *
FROM assessments_schools_aut;
