################################################################################
# This script runs the entire R-based pipeline

# All scripts sourced here are stored in the code folder
# All data read into the pipeline is stored in csv files in the data folder
# Outputs are saved as csv files in the outputs folder

# Note: Set your working directory to the r_pipeline folder before running
# (Session -> Set Working Directory -> To Source File Location)
################################################################################

## Load required packages
## Note: you'll need to install these if you haven't already got them installed
##    run: install.packages("<package_name>")
library(dplyr)
library(magrittr)
library(tidyr)
library(stringr)

## Define any required functions
source("code/functions.R")

## Read in the data files
source("code/data_ingestion.R")

## Carry out required manipulation of input data
source("code/data_manipulation.R")

## Save output files
source("code/outputs.R")