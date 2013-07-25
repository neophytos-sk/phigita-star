# Statistics One, Lecture 3, example script
# Read data, plot histograms, get descriptives
library(psych)

# Read the data into a dataframe called ratings
measurements <- read.table("DAA.01.txt", header=T)

# Print 4 histograms on one page
layout(matrix(c(1,2,3,4,5,6,7,8),2,4,byrow=TRUE))

# Plot histograms

hist(measurements[measurements$cond=="des",]$pre.wm.s,xlab="Rating",main="des pre.wm.s")
hist(measurements[measurements$cond=="des",]$post.wm.s,xlab="Rating",main="des post.wm.s")
hist(measurements[measurements$cond=="des",]$pre.wm.v,xlab="Rating",main="des pre.wm.v")
hist(measurements[measurements$cond=="des",]$post.wm.v,xlab="Rating",main="des post.wm.v")

hist(measurements[measurements$cond=="aer",]$pre.wm.s,xlab="Rating",main="aer pre.wm.s")
hist(measurements[measurements$cond=="aer",]$post.wm.s,xlab="Rating",main="aer post.wm.s")
hist(measurements[measurements$cond=="aer",]$pre.wm.v,xlab="Rating",main="aer pre.wm.v")
hist(measurements[measurements$cond=="aer",]$post.wm.v,xlab="Rating",main="aer post.wm.v")



# Descriptive statistics for the variables in the dataframe called ratings
describe(measurements)
