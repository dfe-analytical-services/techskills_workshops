---- EXAMPLE SQL SECTION

----------------------------------------
-- You might recognise this SQL code from the previous 'sql_pipeline' migration process.
-- It is often the case that a data processing pipeline will use SQL initially for 
-- querying and manipulating tables, before turning to R for more complex analysis.
-- We have replicated this combined approach here, with initial processing performed in 
-- this 1_sql_section.sql file, and later analysis in the 2_r_section.R file.

-- Define catalog being used
USE CATALOG catalog_40_copper_analyst_training;

-- Check structure of pupils_autumn_2025 table
SELECT * FROM catalog_40_copper_analyst_training.bronze.pupils_autumn_2025 LIMIT 1000;

-- Check structure of schools_autumn_2025 table
SELECT * FROM catalog_40_copper_analyst_training.bronze.schools_autumn_2025 LIMIT 1000;

-- Pupils table: select columns and parse JSON metadata
CREATE OR REPLACE TEMPORARY TABLE pupils_aut AS
SELECT 
  pupil_id,
  gender,
  school_urn,
  metadata_json:address:postcode AS postcode,
  LOWER(metadata_json:sen_status) AS sen_status,
  metadata_json:fsm_eligible AS fsm_status
FROM catalog_40_copper_analyst_training.bronze.pupils_autumn_2025;

-- Schools table: select columns, parse JSON, reformat data in city column, deduplicate
CREATE OR REPLACE TEMPORARY TABLE schools_aut AS -- We use TEMP here instead of TEMPORARY in the above example - these can be used interchangeably
SELECT DISTINCT
  school_urn,
  INITCAP(city) AS city,
  school_type,
  REPLACE(metadata_json:ofsted_rating, '"', '') AS ofsted_rating,
  CAST(metadata_json:pupil_premium_pct AS DOUBLE) AS pupil_premium_pct
FROM catalog_40_copper_analyst_training.bronze.schools_autumn_2025;

-- Join pupils and schools tables ahead of performing calculations
CREATE OR REPLACE TEMPORARY TABLE pupils_schools_aut AS -- and here we create a temporary table rather than a view
SELECT 
  p.*,
  s.city,
  s.school_type,
  s.ofsted_rating,
  s.pupil_premium_pct
FROM pupils_aut p
LEFT JOIN schools_aut s
  ON p.school_urn = s.school_urn;

-- Note that since we cannot write permanent tables to the analyst training catalog (as demonstrated by the error below)
-- we will just visualise the output here, and use a CSV with the same data at the beginning of our R process.
CREATE OR REPLACE TABLE pupils_schools_aut AS
SELECT *
FROM pupils_schools_aut;

-- View table
SELECT *
FROM pupils_schools_aut;

-- Or, actually, we'll write it to our own area?
-- give this one a go 
-- Save to your team's Databricks catalog in a schema called <your_name> ----

-- Specify your team's catalog
-- NOTE: You will need to change this to your own team's catalog name!
USE CATALOG catalog_40_copper_statistics_services;

-- Create a schema called <your_name> if it doesn't already exist in that schema and specify as the schema to use
-- NOTE: Change "lgarbett" to your own name!
CREATE SCHEMA IF NOT EXISTS rtarrant;

USE rtarrant;

CREATE OR REPLACE TABLE pupils_schools_aut AS
SELECT *
FROM pupils_schools_aut;
