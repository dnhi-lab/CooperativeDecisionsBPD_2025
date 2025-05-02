# Calculate Bayes Factors 

#rm(list = objects())

library(readxl)
library(dplyr)
library(lsr)
library(BayesFactor)

# Set root directory manually relative to current script
root_dir <- file.path("..", "..")

data_raw_csv <- file.path(root_dir, "data", "raw", "csv")
data_processed <- file.path(root_dir, "data", "processed")

###### Choose data set #####

# (1) SVO primary scores
d <- read.csv(file.path(data_processed, "svo_primary.csv")) %>%
  as.data.frame()
names(d)[1] <- "data"

# (2) SVO secondary scores
d <- read.csv(file.path(data_processed, "svo_secondary.csv")) %>%
  as.data.frame()
names(d)[1] <- "data"

# (3) Dictator Game
d <- read.csv(file.path(data_raw_csv, "dictator_game.csv")) %>%
  as.data.frame()
names(d)[2] <- "data"


###### Stats #####

# group is a factor
d$group <- as.factor(d$group)

# Bayesian independent samples t-test
independentSamplesTTest(
  formula = data ~ group, 
  data = d, 
  var.equal = FALSE
)

# Bayesian t-test
BFresults <- ttestBF(
  formula = data ~ group, 
  data = d)

# Extract Bayes Factor
df <- extractBF(BFresults) 
BF10 <- df$bf # Extract BF value 
BF10

# Compute BF01 (evidence for H0)
BF01 <- 1/BF10
BF01

