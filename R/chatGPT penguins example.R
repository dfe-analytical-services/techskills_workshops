library(palmerpenguins)

# Get the total number of penguins in the dataset
total_penguins <- nrow(penguins)

# Get the number of penguins with a body mass greater than 4500
heavy_penguins <- nrow(subset(penguins, body_mass_g > 4500))

# Calculate the percentage of penguins with a body mass greater than 4500
perc_heavy_penguins <- (heavy_penguins / total_penguins) * 100

# Print the result
cat("Percentage of penguins with body mass greater than 4500: ", round(perc_heavy_penguins, 2), "%", sep="")
