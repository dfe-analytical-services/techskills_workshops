################################################################################
# This script reads in all required input data
################################################################################

## Read in raw data from csv files in data folder

### Pupils - autumn term
pupils_aut_raw <- read.csv("Databricks_workshops/Databricks workshop/03 Migrating existing processes/r_pipeline/data/pupils_autumn_2025.csv")

### Schools - autumn term
schools_aut_raw <- read.csv("Databricks_workshops/Databricks workshop/03 Migrating existing processes/r_pipeline/data/schools_autumn_2025.csv")
