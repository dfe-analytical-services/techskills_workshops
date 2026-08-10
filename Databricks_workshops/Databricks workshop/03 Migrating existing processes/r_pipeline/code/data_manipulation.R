################################################################################
# This script applies required manipulations to raw input data
################################################################################

# Pupils dataset manipulation ----

## Select the columns we want
pupils_aut <- pupils_aut_raw %>%
  select(pupil_id, 
         gender, 
         school_urn, 
         metadata_json) %>%
  ## Separate metadata_json into multiple columns and keep those we want
  separate(metadata_json, 
           into = c("address", "contact", "blank_1", "sen_fsm", "blank_2"), 
           sep = "}") %>%
  select(-address,
         -contact, 
         -blank_1, 
         -blank_2) %>%
  # Create separate SEN and FSM status columns and tidy them
  mutate(sen_fsm = str_extract(sen_fsm, ".*\\b(?:true|false)\\b"),
         sen_fsm = str_replace(sen_fsm, ', "sen_status": ', '')) %>%
  separate(sen_fsm, into = c("sen_status", "fsm_status"), sep = ",") %>%
  mutate(sen_status = str_replace(sen_status, '"', ''),
         sen_status = str_replace(sen_status, '"', ''),
         sen_status = str_to_lower(sen_status),
         fsm_status = str_replace(fsm_status, '"fsm_eligible": ', ''))

# Schools dataset manipulation ----

## Select the columns we want
schools_aut <- schools_aut_raw %>%
  select(-school_name, 
         -status) %>%
  ## Separate metadata_json into multiple columns and keep those we want
  separate(metadata_json, 
           into = c("ofsted_rating", "last_inspection", "pupil_premium_pct"), 
           sep = ",") %>%
  select(-last_inspection) %>%
  ## Tidy remaining columns
  mutate(city = str_to_title(city),
         ofsted_rating = str_replace(ofsted_rating, '[{]"ofsted_rating": "', ''),
         ofsted_rating = str_replace(ofsted_rating, '"', ''),
         pupil_premium_pct = str_replace(pupil_premium_pct, '"pupil_premium_pct": ', ''),
         pupil_premium_pct = as.numeric(str_replace(pupil_premium_pct, '[}]', ''))) %>%
  ## De-duplicate entries
  unique()

# Join pupils and schools datasets ----
pupils_schools_aut <- pupils_aut %>%
  left_join(schools_aut, by = "school_urn")

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
