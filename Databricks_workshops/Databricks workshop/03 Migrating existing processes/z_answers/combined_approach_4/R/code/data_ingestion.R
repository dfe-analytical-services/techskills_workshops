################################################################################
# This script reads in all required input data
################################################################################

## Set up connection to Databricks catalog
con <- DBI::dbConnect(
  odbc::databricks(),
  driver = "Databricks ODBC Driver",
  httpPath = Sys.getenv("DATABRICKS_SQL_PATH"),
  useNativeQuery = FALSE #required for dbWriteTable to work
)

## Tell odbc which catalog to use
dbExecute(con, "USE CATALOG catalog_40_copper_analyst_training;")

## Tell odbc which schema to use
dbExecute(con, "USE bronze;")

## Pupils table: Select columns and parse JSON metadata
pupils_aut <- dbGetQuery(
  con,
  statement = "SELECT 
                pupil_id,
                gender,
                school_urn,
                metadata_json:address:postcode AS postcode,
                LOWER(metadata_json:sen_status) AS sen_status,
                metadata_json:fsm_eligible AS fsm_status
              FROM catalog_40_copper_analyst_training.bronze.pupils_autumn_2025"
)

## Schools table: select columns, parse JSON, reformat data in city column, deduplicate
schools_aut <- dbGetQuery(
  con,
  statement = "SELECT DISTINCT
                school_urn,
                INITCAP(city) AS city,
                school_type,
                REPLACE(metadata_json:ofsted_rating, '\"', '') AS ofsted_rating,
                CAST(metadata_json:pupil_premium_pct AS DOUBLE) AS pupil_premium_pct
              FROM catalog_40_copper_analyst_training.bronze.schools_autumn_2025"
)

## Join pupils and schools tables ahead of performing calculations
pupils_schools_aut <- dbGetQuery(
  con,
  statement = "SELECT 
                p.*,
                s.city,
                s.school_type,
                s.ofsted_rating,
                s.pupil_premium_pct
              FROM pupils_aut p
              LEFT JOIN schools_aut s
                ON p.school_urn = s.school_urn"
)

# ## Alternative: Read in SQL file
# ## in this example, we will us the 'dfeR' package
# ## get SQL string
# sql_string <- dfeR::get_clean_sql(
#   filepath = "Databricks_workshops/Databricks workshop/03 Migrating existing processes/z_answers/combined_approach_4/SQL/1_databricks_sql_section_test.sql"
# )

# # execute
# pupils_schools_aut <- dbGetQuery(
#   con,
#   sql_string
# )
