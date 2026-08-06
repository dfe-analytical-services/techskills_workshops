################################################################################
# This script applies required manipulations to raw input data
################################################################################

# Pupils dataset manipulation ----

## Select the columns we want
pupils_aut <- pupils_aut_raw %>%
  select(pupil_id, 
         gender, 
         school_urn, 
         metadata_json)

## Separate metadata_json into multiple columns
pupils_aut %<>%
  separate(metadata_json, 
           into = c("address", "contact", "blank_1", "sen_fsm", "blank_2"), 
           sep = "}") %>%
  ## Remove columns we don't need
  select(-address,
         -contact, 
         -blank_1, 
         -blank_2) %>%
  # Create clean SEN and FSM status columns
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
  select(-school_name)

## Separate metadata_json into multiple columns
schools_aut %<>%
  separate(metadata_json, 
           into = c("ofsted_rating", "last_inspection", "pupil_premium_pct"), 
           sep = ",") %>%
  mutate(ofsted_rating = str_replace(ofsted_rating, '[{]"ofsted_rating": "', ''),
         ofsted_rating = str_replace(ofsted_rating, '"', ''))
