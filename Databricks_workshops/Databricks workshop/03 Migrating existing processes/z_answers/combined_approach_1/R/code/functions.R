################################################################################
# This script defines any required functions
################################################################################

## Function to set up connection to database

## NOTE: This does not work, and that's intentional! We are pretending our data is in an existing SQL Server
## database, and if it was we'd use a function like this to connect to that database.
##    <sql_server_name> would be the name of the SQL server in which the data is stored
##    <database_name> would be the name of the SQL database in which the data is stored

open_db_connection <- function(
  httpPath = Sys.getenv("DATABRICKS_SQL_PATH"),
  catalog = "catalog_40_copper_analyst_training",
  schema = "bronze",
  useNativeQuery = FALSE # required for dbWriteTable to work
) {
  conn <- DBI::dbConnect(
    odbc::databricks(),
    httpPath = httpPath,
    catalog = catalog,
    schema = schema,
    useNativeQuery = useNativeQuery #required for dbWriteTable to work
  )

  return(conn)
}
