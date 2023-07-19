
# install and call packages -----------------------------------------------

library(readr)
library(dplyr)
library(odbc)
library(ggplot2)
library(tidyverse)
library(tidyr)
library(plotly)
library(janitor)


# Read in the data --------------------------------------------------------

student_results <- read_csv("data/HEA_some_student_results.csv")
View(student_results)


# Cleaning data -----------------------------------------------------------

student_results_rmNAs <- student_results %>%
  na.omit()

student_results_rmNAage <- student_results %>%
  drop_na(c(age, school))

student_results_negatives <- student_results %>%
  mutate(across(where(is.numeric), ~replace_na(.,-100)))

student_results_x <- student_results %>%
  mutate(across(where(is.numeric), ~as.character(.)),
         across(names(student_results),~replace_na(.,"x")))

student_results_distinct <- student_results %>%
  distinct()

student_results_distinct_school <- student_results %>%
  distinct(school, .keep_all = TRUE)

student_results %>%
  filter(year == 2015,
         age > 16,
         Mjob %in% c("health","teacher","services"))

student_results %>%
  group_by(year, school, sex, age)

student_results %>%
  group_by(year, school, sex, age) %>%
  summarise(G1_mean = mean(G1),
            G2_mean = mean(G2),
            G3_mean = mean(G1),
            students = n())

student_results %>%
  group_by(year, school, sex, age) %>%
  summarise(across(c(G1, G2, G3), mean, .names = "{.col}_mean"),
            students = n())

student_results_aggregated <- student_results %>%
  group_by(year, school, sex, age) %>%
  summarise(across(c(G1, G2, G3), mean, .names = "{.col}_mean"),
            students = n())

student_results_aggregated %>%
  select(year, school, sex, age, students, G1_mean, G2_mean,
         G3_mean)

student_results_aggregated %>%
  select(year, school, sex, age, students, G1_mean, G2_mean,
         G3_mean) %>%
  rename(g1_mean = G1_mean, g2_mean = G2_mean, g3_mean = G3_mean)

student_results_aggregated <- student_results_aggregated %>%
  select(year, school, sex, age, students, G1_mean, G2_mean,
         G3_mean) %>%
  clean_names()

student_results_aggregated_suppressed <- student_results_aggregated %>%
  mutate(g1_mean = ifelse(students < 5, "c", g1_mean),
         g2_mean = ifelse(students < 5, "c", g2_mean),
         g3_mean = ifelse(students < 5, "c", g3_mean),
         students = ifelse(students < 5, "c", students)
  )

suppress_counts <- function(column, count) {
  ifelse(count < 5, "c", column)
}

student_results_aggregated_suppressed <- student_results_aggregated %>%
  mutate(g1_mean = suppress_counts(g1_mean, students),
         g2_mean = suppress_counts(g2_mean, students),
         g3_mean = suppress_counts(g3_mean, students),
         students = suppress_counts(students, students))

student_results_aggregated_suppressed <-
  student_results_aggregated %>%
  mutate(across(c(g1_mean, g2_mean, g3_mean, students),
                ~suppress_counts(. , students)))

student_results_aggregated_suppressed_EES <-
  student_results_aggregated_suppressed %>%
  mutate(time_identifier = "Academic year") %>%
  rename(time_period = year)

student_results_aggregated_suppressed_EES <-
  student_results_aggregated_suppressed %>%
  mutate(time_identifier = "Academic year",
         geographic_level = "Regional",
         region_name =
           case_when(school == "MS" ~ "East of England",
                     school == "GP" ~ "London")) %>%
  rename(time_period = year)

# Pull in regions lookup table
regions_URL <- "https://raw.githubusercontent.com/dfe-analytical-services/dfe-published-data-qa/master/data/regions.csv"
regions_lookup <- read.csv(regions_URL)

student_results_aggregated_suppressed_EES <-
  student_results_aggregated_suppressed %>%
  mutate(time_identifier = "Academic year",
         geographic_level = "Regional",
         region_name =
           case_when(school == "MS" ~ "East of England",
                     school == "GP" ~ "London")) %>%
  rename(time_period = year) %>%
  left_join(regions_lookup,
            by = c("region_name" = "region_name")) %>%
  select(time_period, time_identifier, geographic_level,
         region_name, region_code, sex, age,
         students, g1_mean, g2_mean, g3_mean)

long_data <- student_results_aggregated_suppressed_EES %>%
  pivot_longer(cols = ends_with("mean"),
               names_to = "assessment",
               names_pattern = "(\\d)+",
               values_to = "mean_grade",
               values_drop_na = TRUE)

add_together <- function(x,y){
  x + y
}

# import testthat package
library(testthat)

# use expect_that to create tests
test_that(
  "Unexpected result!",
  {
    expect_equal(add_together(2,2), 5)
    expect_identical(add_together(2,2), 4)
    expect_equal(add_together(2,2), 4)
  }
)
