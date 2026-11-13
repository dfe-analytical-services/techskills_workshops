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
dbExecute(con, "USE CATALOG catalog_40_copper_statistics_services;")

## Tell odbc which schema to use
dbExecute(con, "USE rtarrant;")

# Picking up where we left off in databricks, read in the table containing the intermediate output
# by sending a query to the database
pupils_schools_aut <- dbGetQuery(
  con,
  "SELECT * FROM pupils_schools_aut;"
)
