
# install and call packages -----------------------------------------------

library(readr)
library(dplyr)
library(odbc)
library(ggplot2)
library(tidyverse)
library(tidyr)


# Read in the data --------------------------------------------------------

student_results <- read_csv("data/some_student_results.csv")
View(student_results)


# Aggregate the data ------------------------------------------------------

#An initial way
student_results_aggregated <- student_results %>%
  group_by(school, sex, age) %>%
  summarise(G1_mean = mean(G1), G2_mean = mean(G2), G3_mean = mean(G3),
            students = n())

View(student_results_aggregated)

# BUT copying and pasting repeated functions can get messy, especially as they get longer & the more columns you have!

student_results_aggregated <- student_results %>%
  group_by(year, school, sex, age) %>%
  summarise(across(c(G1, G2, G3), mean, .names = "{.col}_mean"), 
            students = n()) %>%
  ungroup()

View(student_results_aggregated)


# Re-oder columns ---------------------------------------------------------

# student_results_aggregated <- student_results_aggregated %>%
#   select(school, sex, age, students, G1_mean, G2_mean, G3_mean) %>%
#   rename(g1_mean = G1_mean)

student_results_aggregated <- student_results_aggregated %>%
  select(year, school, sex, age, students, G1_mean, G2_mean, G3_mean) %>%
  rename_all(tolower)

# Suppression on rows with less than 5 students ---------------------------

# an initial way
student_results_aggregated_suppressed <- student_results_aggregated %>%
  mutate(g1_mean = ifelse(students < 5, 'c', g1_mean),
         g2_mean = ifelse(students < 5, 'c', g2_mean),
         g3_mean = ifelse(students < 5, 'c', g3_mean),
         students = ifelse(students < 5, 'c', students) # gotta do students last so it's numeric until this point!
         )

#However, if we want to suppress multiple columns using the same rule, we should write a function for this.
suppress_counts <- function(column) {
ifelse(students < 5, 'c', .)
}

# Note that the above will change the 'students' column from a numeric variable to a character variable, 
# because it will now contain the letter 'c' as well as numbers. 

# a better way
student_results_aggregated_suppressed <- student_results_aggregated %>%
  mutate(g1_mean = suppress_counts(g1_mean),
         g2_mean = suppress_counts(g2_mean),
         g3_mean = suppress_counts(g3_mean),
         students = suppress_counts(students))

#the best way - this way your code is future-proofed if you want to add more columns to the mutate step which applies
#the suppression.
student_results_aggregated_suppressed <- student_results_aggregated %>%
  mutate(across(c(g1_mean, g2_mean, g3_mean, students), ~ifelse(students < 5, 'c', .)))


# Add EES columns ---------------------------------------------------------

student_results_aggregated_suppressed_EES <- student_results_aggregated_suppressed %>%
  mutate(time_identifier = 'Academic year', geographic_level = 'Regional',
         region_name = case_when(school == 'MS' ~ "East of England",
                                 school == 'GP' ~ 'London')) %>%
  rename(time_period = year)


# Add region code ---------------------------------------------------------

regions_lookup <- read.csv("https://raw.githubusercontent.com/dfe-analytical-services/dfe-published-data-qa/master/data/regions.csv")

student_results_aggregated_suppressed_EES <- student_results_aggregated_suppressed %>%
  mutate(time_identifier = 'Academic year', geographic_level = 'Regional',
         region_name = case_when(school == 'MS' ~ "East of England",
                                 school == 'GP' ~ 'London')) %>%
  rename(time_period = year) %>%
  left_join(regions_lookup, by = c('region_name' = 'region_name')) %>%
  select(time_period, time_identifier, geographic_level, region_name, region_code, sex, age, students, g1_mean, g2_mean, g3_mean)


# Create metadata with code & console messages ----------------------------

createMetadata <- function(x, metadata = fieldLabels, type = "Destinations"){
  if((!is.data.frame(x)) || NROW(x) == 0){
    message("x must be a populated data frame.")
    stop()
  }
  allColumns <- colnames(x)
  removeCols <- metadata[metadata$label == "", 'col_name']
  allColumns <- allColumns[!allColumns %in% removeCols]
  
  groupingCols <- allColumns[1:(firstNumCol-1)]
  groupingCols <- groupingCols[!groupingCols %in% allColumns[firstNumCol]]
  
  indicatorCols <- allColumns[firstNumCol:NCOL(x)]
  earningCols <- ifelse(TRUE %in% grepl("LearnersWithEarnings", allColumns),
                        grep("LearnersWithEarnings", allColumns),
                        grep("NumLearners", allColumns))
  
  
  if(!is.na(earningCols)){
    indicatorCols <- allColumns[firstNumCol:(earningCols-1)]
    earningCols <- allColumns[(earningCols+1):NCOL(x)]
    
  }
  
  df <- data.frame(col_name = allColumns,
                   col_type = ifelse(allColumns %in% groupingCols, "Filter", "Indicator"),
                   indicator_unit = case_when(grepl("Percent$", allColumns) ~ "%",
                                              allColumns %in% earningCols ~ "£"),
                   indicator_dp = ifelse(allColumns %in% groupingCols, "", "0"))
  #df <- data.frame(df, order =  row.names(df))
  
  df <- merge(df, metadata, by = "col_name", sort = FALSE, all.x = TRUE)
  
  df <- df[!df$col_name %in% removeCols, c("col_name", "col_type", "label", "indicator_grouping", "indicator_unit", "indicator_dp", "filter_hint", "filter_grouping_column")]
  return(df)
}



# ggplot ------------------------------------------------------------------

# will have to reformat to easily use ggplot. Use the long/wide pivot thing we used at away day.

plot_data <- student_results_aggregated_suppressed_EES %>%
 filter(time_period == 2015, age == 16, region_name == 'London') %>%
  pivot_longer(cols = ends_with("mean"),
               names_to = "assessment",
               names_pattern = "(\\d)+",
               values_to = "mean_grade",
               values_drop_na = TRUE)
  

ggplot(plot_data, aes(x = assessment, y = mean_grade)) +
  geom_bar(stat = 'identity', aes(fill = sex), position = "dodge")


