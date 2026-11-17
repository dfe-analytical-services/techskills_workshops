################################################################################
# This script reads in all required input data
################################################################################

## Read in data from csv files in data folder
## Picking up where we left off, we will read a csv containing the data from the final output in 1_sql_section.sql
pupils_schools_aut <- read.csv(
  "Databricks_workshops/Databricks workshop/03 Migrating existing processes/sql_and_r_combination/data/pupils_schools_aut.csv"
) |>
  mutate(
    across(everything(), ~ if_else(.x == "null", NA, .x)),
    pupil_premium_pct = as.double(pupil_premium_pct)
  )
