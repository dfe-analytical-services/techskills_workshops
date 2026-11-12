################################################################################
# This script reads in all required input data
################################################################################

## Connect to databricks
db_con <- open_db_connection(
  catalog = "catalog_40_copper_statistics_services",
  schema = "rtarrant"
)

# Instead of running SQL code within databricks, we can use XYZ functions to read in the SQL code and
# run directly from your R IDE.
# by sending a query to the database (expect an error here, explained below...)

## get SQL string
## in this example, we will us the 'dfeR' package
sql_string <- dfeR::get_clean_sql(
  filepath = "Databricks_workshops/Databricks workshop/03 Migrating existing processes/z_answers/combined_approach_4/SQL/1_databricks_sql_section.sql"
)


pupils_schools_aut <- dbGetQuery(
  db_con,
  sql_string
)

# # Unfortunately, since we do not have write access to the analyst training catalog, the above code will
# # not run (although the code would work when trying to read in an existing table, such as pupils_autumn_2025).
# # As such, we will instead read a CSV to continue the deomnstration.
# pupils_schools_aut <- read.csv(
#   "Databricks_workshops/Databricks workshop/03 Migrating existing processes/sql_and_r_combination/data/pupils_schools_aut.csv"
# ) |>
#   mutate(
#     across(everything(), ~ if_else(.x == "null", NA, .x)),
#     pupil_premium_pct = as.double(pupil_premium_pct)
#   )
