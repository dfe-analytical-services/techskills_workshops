################################################################################
# This script saves pipeline outputs into the outputs folder
################################################################################

# Create summary of average pupil premium percentage by Ofsted rating ----

avg_pupil_premium_by_ofsted <- pupils_schools_aut %>%
  group_by(ofsted_rating) %>%
  summarise(
    pupils = n(),
    avg_pupil_premium_pct = mean(pupil_premium_pct, na.rm = TRUE),
    median_pupil_premium_pct = median(pupil_premium_pct, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(pupils)) %>%
  filter(!is.na(ofsted_rating))

# Save to your team's Databricks catalog in a schema called <your_name> ----

## Specify your team's catalog
## NOTE: You will need to change this to your own team's catalog name!
DBI::dbExecute(con, "USE CATALOG catalog_40_copper_statistics_services;")

## Create a schema called <your_name> if it doesn't already exist in that schema and specify as the schema to use
## NOTE: Change "lgarbett" to your own name!
DBI::dbExecute(con, "CREATE SCHEMA IF NOT EXISTS lgarbett;")
DBI::dbExecute(con, "USE lgarbett;")

## Write the output to your schema in the Databricks catalog
DBI::dbWriteTable(conn = con,
                  name = "pupil_premium_ofsted",
                  value = avg_pupil_premium_by_ofsted,
                  overwrite = TRUE,
                  append = FALSE,
                  row.names = FALSE)

# Check migrated output matches that from original pipeline ----
avg_pupil_premium_by_ofsted_orig <- read.csv("Databricks_workshops/Databricks workshop/03 Migrating existing processes/r_pipeline/outputs/avg_pupil_premium_by_ofsted.csv")

if (identical(avg_pupil_premium_by_ofsted_orig, avg_pupil_premium_by_ofsted)) {
  paste("SUCCESS! Migrated output matches that from original pipeline")
} else {
  stop("Migrated output does not match that from original pipeline")
}
