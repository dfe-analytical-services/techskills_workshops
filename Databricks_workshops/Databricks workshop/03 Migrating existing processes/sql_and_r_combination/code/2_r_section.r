## EXAMPLE R SECTION

----------------------------------------
## You might recognise this R code from the previous 'r_pipeline' migration process.
## It is often the case that a teams data processing pipeline will use SQL initially for 
## querying and manipulating tables, before turning to R for more complex analysis.
## We have replicated this combined approach here, with initial processing performed in 
## this 1_sql_section.sql file, and later analysis in the 2_r_section.R file.

## Picking up where we left off, we will read a csv containing the data from the final output in 1_sql_section.sql
pupils_schools_aut <- read.csv("path/to/file.csv")

# Investigate relationships in joined data ----
cat("Joined pupils_schools_aut dimensions: ", nrow(pupils_schools_aut), "x", ncol(pupils_schools_aut), "\n")

cat("\nGender by Ofsted rating:\n")
print(pupils_schools_aut %>% count(gender, ofsted_rating, sort = TRUE))

cat("\nSEN status by Ofsted rating:\n")
print(pupils_schools_aut %>% count(sen_status, ofsted_rating, sort = TRUE))

cat("\nFSM status by Ofsted rating:\n")
print(pupils_schools_aut %>% count(fsm_status, ofsted_rating, sort = TRUE))

cat("\nAverage pupil premium percentage by Ofsted rating:\n")
print(pupils_schools_aut %>%
  group_by(ofsted_rating) %>%
  summarise(
    pupils = n(),
    avg_pupil_premium_pct = mean(pupil_premium_pct, na.rm = TRUE),
    median_pupil_premium_pct = median(pupil_premium_pct, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(pupils)))

cat("\nSchool count by city and Ofsted rating:\n")
print(pupils_schools_aut %>%
  distinct(school_urn, city, ofsted_rating) %>%
  count(city, ofsted_rating, sort = TRUE))
