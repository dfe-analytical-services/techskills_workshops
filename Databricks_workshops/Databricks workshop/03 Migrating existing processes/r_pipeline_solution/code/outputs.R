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
  arrange(desc(pupils))

# Save to outputs folder ----
write.csv(
  avg_pupil_premium_by_ofsted,
  file = "Databricks_workshops/Databricks workshop/03 Migrating existing processes/r_pipeline_solution/outputs/avg_pupil_premium_by_ofsted_migrated.csv",
  row.names = FALSE
)

# Check migrated output matches that from original pipeline ----
avg_pupil_premium_by_ofsted_orig <- read.csv("Databricks_workshops/Databricks workshop/03 Migrating existing processes/r_pipeline/outputs/avg_pupil_premium_by_ofsted.csv")
avg_pupil_premium_by_ofsted_migrated <- read.csv("Databricks_workshops/Databricks workshop/03 Migrating existing processes/r_pipeline_solution/outputs/avg_pupil_premium_by_ofsted_migrated.csv")
if (identical(avg_pupil_premium_by_ofsted_orig, avg_pupil_premium_by_ofsted_migrated)) {
  paste("SUCCESS! Migrated output matches that from original pipeline")
} else {
  stop("Migrated output does not match that from original pipeline")
}
