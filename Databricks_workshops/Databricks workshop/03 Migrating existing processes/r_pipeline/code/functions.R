################################################################################
# This script defines any required functions
################################################################################

## Function to set up connection to database

## NOTE: This does not work, and that's intentional! We are pretending our data is in an existing SQL Server
## database, and if it was we'd use a function like this to connect to that database.
##    <sql_server_name> would be the name of the SQL server in which the data is stored
##    <database_name> would be the name of the SQL database in which the data is stored

open_db_connection <- function(driver = "SQL Server Native Client 11.0",
                               server = "<sql_server_name>", 
                               database = "<database_name") {
  
  conn_string <- paste0("driver=", driver, "; server=", server, "; database=", database, ";trusted_connection=yes")
  
  conn <- dbConnect(odbc::odbc(), .connection_string = conn_string)
  
  return(conn)
  
}