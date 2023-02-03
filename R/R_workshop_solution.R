install.packages("dplyr")

library(readr)
library(dplyr)

some_student_results <- read_csv("data/some_student_results.csv")
View(some_student_results)

some_student_results <- some_student_results %>%
  group_by(school, sex, age) %>%
  summarise(G1_mean = mean(G1), G2_mean = mean(G2), G3_mean = mean(G3), 
            students = n())
