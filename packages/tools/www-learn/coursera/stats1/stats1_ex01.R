# Statistics One, Lecture 3, example script
# Read data, plot histograms, get descriptives
library(psych)

# Read the data into a dataframe called ratings
ratings <- read.table("stats1_ex01.txt", header=T)

# What type of object is ratings?
class(ratings)

# List the names of the variables in the dataframe called ratings
names(ratings)

# Print 4 histograms on one page
layout(matrix(c(1,2,3,4),2,2,byrow=TRUE))

# Plot histograms
hist(ratings$WoopWoop,xlab="Rating")
hist(ratings$RedTruck,xlab="Rating")
hist(ratings$HobNob,xlab="Rating")
hist(ratings$FourPlay,xlab="Rating")

# Descriptive statistics for the variables in the dataframe called ratings
describe(ratings)