################################################################################
# This script runs the entire R-based pipeline

# All scripts sourced here are stored in the code folder
# All data read into the pipeline is stored in csv files in the data folder
# Outputs are saved as csv files in the outputs folder

# Note: Set your working directory to the r_pipeline folder before running
# (Session -> Set Working Directory -> To Source File Location)
################################################################################

## Install required packages if not already installed
if (!require(dplyr)) install.packages("dplyr")
if (!require(magrittr)) install.packages("magrittr")
if (!require(tidyr)) install.packages("tidyr")
if (!require(stringr)) install.packages("stringr")

## Load required packages
library(dplyr)
library(magrittr)
library(tidyr)
library(stringr)

## Define any required functions
source("Databricks_workshops/Databricks workshop/03 Migrating existing processes/r_pipeline/code/functions.R")

## Read in the data files
source("Databricks_workshops/Databricks workshop/03 Migrating existing processes/r_pipeline/code/data_ingestion.R")

## Carry out required manipulation of input data
source("Databricks_workshops/Databricks workshop/03 Migrating existing processes/r_pipeline/code/data_manipulation.R")

## Save output files
source("Databricks_workshops/Databricks workshop/03 Migrating existing processes/r_pipeline/code/outputs.R")