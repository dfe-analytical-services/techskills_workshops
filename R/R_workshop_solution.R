
# install and call packages -----------------------------------------------

library(readr)
library(dplyr)
library(odbc)


# Read in the data --------------------------------------------------------

student_results <- read_csv("data/some_student_results.csv")
View(student_results)


# Aggregate the data ------------------------------------------------------

# student_results_aggregated <- student_results %>%
#   group_by(school, sex, age) %>%
#   summarise(G1_mean = mean(G1), G2_mean = mean(G2), G3_mean = mean(G3), 
#             students = n())
# 
# View(student_results_aggregated)

# copying and pasting repeated functions can get messy, especially as they get longer & the more columns you have!

student_results_aggregated <- student_results %>%
  group_by(school, sex, age) %>%
  summarise(across(c(G1, G2, G3), mean, .names = "{.col}_mean"), 
            students = n())

View(student_results_aggregated)


# Re-oder columns ---------------------------------------------------------

student_results_aggregated_ <- student_results_aggregated %>%
  select(school, sex, age, students, G1_mean, G2_mean, G3_mean)

# Suppression on rows with less than 5 students ---------------------------

# an initial way
student_results_aggregated_suppressed <- student_results_aggregated %>%
  mutate(students = ifelse(students < 5, 'c', students),
         G1_mean = ifelse(students < 5, 'c', G1_mean),
         G2_mean = ifelse(students < 5, 'c', G2_mean),
         G3_mean = ifelse(students < 5, 'c', G3_mean))

#However, if we want to suppress multiple columns using the same rule, we should write a function for this.
suppress_counts <- function(count){
  ifelse(count < 5, 'c', count)
}

# Note that the above will change the 'students' column from a numeric variable to a character variable, 
# because it will now contain the letter 'c' as well as numbers. 

# a better way
student_results_aggregated_suppressed <- student_results_aggregated %>%
  mutate(students = suppress_counts(students), 
         G1_mean = suppress_counts(students))

#the best way - this way your code is future-proofed if you want to add more columns to the mutate step which applies
#the suppression.
student_results_aggregated_suppressed <- student_results_aggregated %>%
  mutate(across(c(students, G1_mean), suppress_counts))

