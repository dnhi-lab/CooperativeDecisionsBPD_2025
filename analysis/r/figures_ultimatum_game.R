# Figures for Ultimatum Game

rm(list = objects())

library(readxl)
library(magrittr)
library(ggplot2)

# Set root directory manually relative to current script
root_dir <- file.path("..", "..")

data_raw_csv <- file.path(root_dir, "data", "raw", "csv")
data_processed <- file.path(root_dir, "data", "processed")
figures <- file.path(root_dir, "figures")

# Load data
d <- read.csv(file.path(data_processed, "ultimatum_game_offer_average.csv")) %>%
  as.data.frame()
d$group <- as.factor(d$group)


##### Line Plot #####

# Labels
pTitle = "Ultimatum Game"
pX = "Offers"
pY = "% rejected"
saveName = file.path(figures, 'ultimatum_game.png')

# Plot
fig <- ggplot(d, aes(offers, meanRejections, color = group)) +
  geom_line() +
  geom_errorbar(aes(ymin = meanRejections - semRejections, ymax = meanRejections + semRejections), width = 0.2)+
  geom_point() +
  scale_color_manual(values = c("#CD1818", "#3AA6B9")) +
  scale_x_continuous(breaks = seq(1, 6, 1))+
  scale_y_continuous(breaks = seq(0, 100, 10)) +
  theme_minimal() +
  labs(title = pTitle, 
       x = pX, 
       y = pY,
       color = "Group") +
  theme(plot.title = element_text(size = 8, hjust = 0.5), # center title 
        axis.title.x = element_text(size = 8),
        axis.title.y = element_text(size = 8),
        axis.text = element_text(size = 8)) + 
  theme(legend.position = c(0.8, 0.8),
        legend.title=element_blank(),
        legend.text=element_text(size = 8))

fig

# Save figure 
ggsave(saveName, plot = fig, 
       width = 3.15, height = 2.5, dpi = 600)


###### Full dataset UG ######

d <- read.csv(file.path(data_processed, "ultimatum_game_subject_average.csv")) %>%
  as.data.frame()
d$group <- as.factor (d$group)
names(d)[1] <- "yData"


##### Stats #####

# Calculate Welch's t-test 
t.test(d$yData ~ d$group, var.equal = FALSE)

# Calculate the effect size
d %>% cohens_d(yData ~ group, var.equal = FALSE)

# Calculate the ranksum test
coin::wilcox_test(d$yData ~ d$group)

# Calculate the effect size for Wilcoxon test 
d %>% wilcox_effsize(yData ~ group)

