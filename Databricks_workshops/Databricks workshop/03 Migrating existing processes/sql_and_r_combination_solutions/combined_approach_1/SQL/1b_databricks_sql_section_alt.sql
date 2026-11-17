---- EXERCISE SQL SECTION: TRANSLATE THIS PIPELINE TO R

----------------------------------------
-- This pipeline is similar to the SQL code in the earlier 'sql_and_r_combination' example,
-- but with a few differences. As before, the raw pupil and school tables are cleaned and
-- joined, but this time the SQL also produces a summary table by school type.
--
-- EXERCISE: Rewrite each numbered step below in R (for example, using dplyr), reading the
-- bronze tables through your Databricks connection. Check that your R output matches the
-- output of this SQL.
--
-- Differences from the earlier example to look out for:
--   * Date handling: date of birth is converted to a date and used to calculate age
--   * String handling: postcode is cut down to its district, and school_type is tidied
--     (the raw data contains both 'Academy' and 'academy')
--   * Type conversion: fsm_eligible is converted to a TRUE/FALSE value
--   * Join type: an INNER JOIN is used, so pupils with no matching school are dropped
--   * Aggregation: the pipeline ends with a grouped summary rather than a joined table

-- Define catalog being used
USE CATALOG catalog_40_copper_analyst_training;

--------------------------------------------------------------------------------
-- 1. Look at data structure
--------------------------------------------------------------------------------

-- Check structure of pupils_autumn_2025 table
SELECT * FROM catalog_40_copper_analyst_training.bronze.pupils_autumn_2025 LIMIT 1000;

-- Check structure of schools_autumn_2025 table
SELECT * FROM catalog_40_copper_analyst_training.bronze.schools_autumn_2025 LIMIT 1000;

--------------------------------------------------------------------------------
-- 2. Data manipulation
--------------------------------------------------------------------------------

-- Pupils table: select columns, parse JSON metadata, derive age and postcode district, deduplicate
CREATE OR REPLACE TEMPORARY TABLE pupils_aut AS
SELECT DISTINCT
  pupil_id,
  gender,
  school_urn,
  TO_DATE(date_of_birth) AS date_of_birth,
  -- Age at the start of the 2025/26 academic year
  FLOOR(MONTHS_BETWEEN(DATE'2025-08-31', TO_DATE(date_of_birth)) / 12) AS age_at_start_of_year,
  -- Keep the first part of the postcode only, e.g. 'E1 6AN' becomes 'E1'
  SPLIT(metadata_json:address:postcode, ' ')[0] AS postcode_district,
  LOWER(metadata_json:sen_status) AS sen_status,
  CAST(metadata_json:fsm_eligible AS BOOLEAN) AS fsm_eligible
FROM catalog_40_copper_analyst_training.bronze.pupils_autumn_2025;

-- Schools table: select columns, parse JSON, tidy text columns, deduplicate
CREATE OR REPLACE TEMPORARY TABLE schools_aut AS
SELECT DISTINCT
  school_urn,
  INITCAP(school_name) AS school_name,
  INITCAP(city) AS city,
  INITCAP(school_type) AS school_type,
  REPLACE(metadata_json:ofsted_rating, '"', '') AS ofsted_rating,
  TO_DATE(metadata_json:last_inspection) AS last_inspection_date,
  CAST(metadata_json:pupil_premium_pct AS DOUBLE) AS pupil_premium_pct
FROM catalog_40_copper_analyst_training.bronze.schools_autumn_2025;

-- Join pupils to schools, keeping only pupils with a matching school, and add an SEN flag
CREATE OR REPLACE TEMPORARY TABLE pupils_schools_aut AS
SELECT
  p.*,
  s.school_name,
  s.city,
  s.school_type,
  s.ofsted_rating,
  s.last_inspection_date,
  s.pupil_premium_pct,
  CASE WHEN p.sen_status = 'none' THEN 'No SEN' ELSE 'SEN' END AS sen_flag
FROM pupils_aut p
INNER JOIN schools_aut s
  ON p.school_urn = s.school_urn;

--------------------------------------------------------------------------------
-- 3. Summary analysis by school type
--------------------------------------------------------------------------------

CREATE OR REPLACE TEMPORARY TABLE school_type_summary_aut AS
SELECT
  school_type,
  COUNT(DISTINCT pupil_id) AS pupils,
  COUNT(DISTINCT school_urn) AS schools,
  ROUND(AVG(CASE WHEN fsm_eligible THEN 1 ELSE 0 END), 2) AS fsm_rate,
  ROUND(AVG(CASE WHEN sen_flag = 'SEN' THEN 1 ELSE 0 END), 2) AS sen_rate,
  ROUND(AVG(pupil_premium_pct), 3) AS avg_pupil_premium_pct
FROM pupils_schools_aut
GROUP BY school_type
ORDER BY pupils DESC;

SELECT * FROM school_type_summary_aut;

--------------------------------------------------------------------------------
-- 4. Save outputs
--------------------------------------------------------------------------------

-- Since we don't have write access to the analyst training catalog, you will have to write to your team's Databricks 
-- catalog in a schema called <your_name> ----

-- Specifying your team's catalog explicitly, create a schema called <your_name> if it doesn't already exist
-- NOTE: You will need to change the catalog name to your own team's catalog name, and "rtarrant" to your own name!
CREATE SCHEMA IF NOT EXISTS catalog_40_copper_statistics_services.rtarrant;

-- Create the tables, specifying the full three-level namespace (as we are using a different catalog and schema to what is specified initially)
CREATE OR REPLACE TABLE catalog_40_copper_statistics_services.rtarrant.pupils_schools_aut AS
SELECT *
FROM pupils_schools_aut;

CREATE OR REPLACE TABLE catalog_40_copper_statistics_services.rtarrant.school_type_summary_aut AS
SELECT *
FROM school_type_summary_aut;
