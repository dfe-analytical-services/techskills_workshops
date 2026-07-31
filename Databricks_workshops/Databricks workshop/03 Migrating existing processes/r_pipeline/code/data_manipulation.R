################################################################################
# This script applies required manipulations to raw input data
################################################################################

# Pupils dataset manipulation

## Select the columns we want
pupils_aut <- pupils_aut_raw %>%
  select(pupil_id, gender, school_urn, metadata_json)

## Separate metadata_json into multiple columns
pupils_aut %<>%
  separate(metadata_json, into = c("adress", "contact", "blank_1", "sen_fsm", "blank_2"), sep = "}") %>%
  select(-contact, -blank_1, -blank_2) %>%
  mutate(sen_fsm = str_extract(sen_fsm, ".*\\b(?:true|false)\\b"))

# Clean the school dataset

