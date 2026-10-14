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

## Load required packages
library(dplyr)
library(magrittr)
library(tidyr)
library(stringr)

## Picking up where we left off, we will read a csv containing the data from the final output in 1_sql_section.sql
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

cat("\nGender by Ofsted rating:\n")
print(pupils_schools_aut %>% count(gender, ofsted_rating, sort = TRUE))

cat("\nSEN status by Ofsted rating:\n")
print(pupils_schools_aut %>% count(sen_status, ofsted_rating, sort = TRUE))

cat("\nFSM status by Ofsted rating:\n")
print(pupils_schools_aut %>% count(fsm_status, ofsted_rating, sort = TRUE))

cat("\nAverage pupil premium percentage by Ofsted rating:\n")
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

cat("\nSchool count by city and Ofsted rating:\n")
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
