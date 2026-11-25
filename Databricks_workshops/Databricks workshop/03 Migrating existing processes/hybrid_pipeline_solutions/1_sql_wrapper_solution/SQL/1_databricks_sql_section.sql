---- EXAMPLE SQL
----------------------------------------

-- Pupils table: select columns and parse JSON metadata
WITH pupils_aut AS
(SELECT 
  pupil_id,
  gender,
  school_urn,
  metadata_json:address:postcode AS postcode,
  LOWER(metadata_json:sen_status) AS sen_status,
  metadata_json:fsm_eligible AS fsm_status
FROM catalog_40_copper_analyst_training.bronze.pupils_autumn_2025),

-- Schools table: select columns, parse JSON, reformat data in city column, deduplicate
schools_aut AS
(SELECT DISTINCT
  school_urn,
  INITCAP(city) AS city,
  school_type,
  REPLACE(metadata_json:ofsted_rating, '"', '') AS ofsted_rating,
  CAST(metadata_json:pupil_premium_pct AS DOUBLE) AS pupil_premium_pct
FROM catalog_40_copper_analyst_training.bronze.schools_autumn_2025),

-- Join pupils and schools tables ahead of performing calculations
pupils_schools_aut AS
(SELECT 
  p.*,
  s.city,
  s.school_type,
  s.ofsted_rating,
  s.pupil_premium_pct
FROM pupils_aut p
LEFT JOIN schools_aut s
  ON p.school_urn = s.school_urn)


-- Output the intermediate table to read into R for further analysis
SELECT *
FROM pupils_schools_aut;
