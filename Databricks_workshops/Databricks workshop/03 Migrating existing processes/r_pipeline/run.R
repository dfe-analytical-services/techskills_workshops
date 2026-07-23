# This script runs the R-based pipeline
# Note: Set your working directory to the r_pipeline folder before running


## Load required packages
library(dplyr)

## Source functions script
source("functions.R")

## Source data ingestion script
source("data_ingestion.R")

## Source data manipulation script
source("data_manipulation.R")

## Source output production script
source("outputs.R")