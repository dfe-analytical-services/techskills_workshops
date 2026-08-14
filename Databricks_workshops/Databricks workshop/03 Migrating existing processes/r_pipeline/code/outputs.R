################################################################################
# This script saves pipeline outputs into the outputs folder
################################################################################

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
  file = "Databricks_workshops/Databricks workshop/03 Migrating existing processes/r_pipeline/outputs/avg_pupil_premium_by_ofsted.csv",
  row.names = FALSE
)
