## EXAMPLE R SECTION

## You might recognise this R code from the previous 'r_pipeline' migration process.
## It is often the case that a teams data processing pipeline will use SQL initially for
## querying and manipulating tables, before turning to R for more complex analysis.
## We have replicated this combined approach here, with initial processing performed in
## this 1_sql_section.sql file, and later analysis in the 2_r_section.R file.

## Install required packages if not already installed
if (!require(dplyr)) {
  install.packages("dplyr")
}
if (!require(magrittr)) {
  install.packages("magrittr")
}
if (!require(tidyr)) {
  install.packages("tidyr")
}
if (!require(stringr)) {
  install.packages("stringr")
}
if (!require(stringr)) {
  install.packages("odbc")
}

## Load required packages
library(dplyr)
library(magrittr)
library(tidyr)
library(stringr)
library(odbc)

## As mentioned in the notebook '02 Migrating processes containing both R & SQL', the R code would pick up from
## Databricks by reading the table from the relevant catalog.

## This additional step requires the 'odbc' package, in addition to any other packages being used.

## Note that, if you have not yet connected to databricks via R, you may need to set up your environment
## variables. Instructions for this can be found in the Analysts guide:
## (https://dfe-analytical-services.github.io/analysts-guide/ADA/databricks_rstudio_sql_warehouse.html)

# Connect to databricks --------------------------------------------------------------------
# Establish databricks connection
db_con <- DBI::dbConnect(
  odbc::databricks(),
  httpPath = Sys.getenv("DATABRICKS_SQL_PATH"),
  catalog = "catalog_40_copper_analyst_training",
  schema = "bronze",
  useNativeQuery = FALSE #required for dbWriteTable to work
)

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

## Print to console to confirm this is what we produced in SQL
glimpse(pupils_schools_aut)

# Investigate relationships in joined data ----
cat(
  "Joined pupils_schools_aut dimensions: ",
  nrow(pupils_schools_aut),
  "x",
  ncol(pupils_schools_aut),
  "\n"
)

# Gender by Ofsted rating:
print(pupils_schools_aut %>% count(gender, ofsted_rating, sort = TRUE))

# SEN status by Ofsted rating:
print(pupils_schools_aut %>% count(sen_status, ofsted_rating, sort = TRUE))

# FSM status by Ofsted rating:
print(pupils_schools_aut %>% count(fsm_status, ofsted_rating, sort = TRUE))

# Average pupil premium percentage by Ofsted rating:
print(
  pupils_schools_aut %>%
    group_by(ofsted_rating) %>%
    summarise(
      pupils = n(),
      avg_pupil_premium_pct = mean(pupil_premium_pct, na.rm = TRUE),
      median_pupil_premium_pct = median(pupil_premium_pct, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(desc(pupils))
)

# School count by city and Ofsted rating:
print(
  pupils_schools_aut %>%
    distinct(school_urn, city, ofsted_rating) %>%
    count(city, ofsted_rating, sort = TRUE)
)

# save pipeline outputs into the outputs folder
avg_pupil_premium_by_ofsted <- pupils_schools_aut %>%
  group_by(ofsted_rating) %>%
  summarise(
    pupils = n(),
    avg_pupil_premium_pct = mean(pupil_premium_pct, na.rm = TRUE),
    median_pupil_premium_pct = median(pupil_premium_pct, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(pupils))

write.csv(
  avg_pupil_premium_by_ofsted,
  file = "Databricks_workshops/Databricks workshop/03 Migrating existing processes/sql_and_r_combination/outputs/avg_pupil_premium_by_ofsted.csv",
  row.names = FALSE
)
