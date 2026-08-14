################################################################################
# This script runs the entire R-based pipeline

# All scripts sourced here are stored in the code folder
# All data inputs are sourced from the Databricks catalog
# Outputs are saved as csv files in the original r_pipeline/outputs folder

################################################################################

## Install required packages if not already installed
if (!require(dplyr)) install.packages("dplyr")
if (!require(magrittr)) install.packages("magrittr")
if (!require(tidyr)) install.packages("tidyr")
if (!require(stringr)) install.packages("stringr")
if (!require(usethis)) install.packages("usethis")
if (!require(odbc)) install.packages("odbc")
if (!require(DBI)) install.packages("DBI")

## Load required packages
library(dplyr)
library(magrittr)
library(tidyr)
library(stringr)
library(usethis)
library(odbc)
library(DBI)

## Read in the data files
source("Databricks_workshops/Databricks workshop/03 Migrating existing processes/r_pipeline_solution/code/data_ingestion.R")

## Carry out required manipulation of input data
source("Databricks_workshops/Databricks workshop/03 Migrating existing processes/r_pipeline_solution/code/data_manipulation.R")

## Save output files
source("Databricks_workshops/Databricks workshop/03 Migrating existing processes/r_pipeline_solution/code/outputs.R")
