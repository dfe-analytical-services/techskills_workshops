################################################################################
# This script reads in all required input data
################################################################################

# Read in data ----

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

## Select data from tables
pupils_aut_raw <- dbGetQuery(con, "SELECT * FROM pupils_autumn_2025;")

schools_aut_raw <- dbGetQuery(con, "SELECT * FROM schools_autumn_2025;")


# Read in data from csv files for QA of migration ----

## Pupils - autumn term
pupils_aut_raw_csv <- read.csv("Databricks_workshops/Databricks workshop/03 Migrating existing processes/r_pipeline/data/pupils_autumn_2025.csv")

## Schools - autumn term
schools_aut_raw_csv <- read.csv("Databricks_workshops/Databricks workshop/03 Migrating existing processes/r_pipeline/data/schools_autumn_2025.csv")

## Check data files from Databricks catalog are the same as those in the data folder
if (identical(pupils_aut_raw, pupils_aut_raw_csv) & identical(schools_aut_raw, schools_aut_raw_csv)) {
  paste("SUCCESS! Data from Databricks catalog matches that in the data folder")
} 
