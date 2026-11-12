################################################################################
# This script reads in all required input data
################################################################################

## Read in data from csv files in data folder
# Picking up where we left off in databricks, we would read in the table containing the final output
# by sending a query to the database (expect an error here, explained below...)
pupils_schools_aut <- dbGetQuery(
  db_con,
  "SELECT * FROM pupils_schools_aut;"
)

# Unfortunately, since we do not have write access to the analyst training catalog, the above code will
# not run (although the code would work when trying to read in an existing table, such as pupils_autumn_2025).
# As such, we will instead read a CSV to continue the deomnstration.
pupils_schools_aut <- read.csv(
  "Databricks_workshops/Databricks workshop/03 Migrating existing processes/sql_and_r_combination/data/pupils_schools_aut.csv"
) |>
  mutate(
    across(everything(), ~ if_else(.x == "null", NA, .x)),
    pupil_premium_pct = as.double(pupil_premium_pct)
  )
