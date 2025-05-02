# Figures for Fairness Ratings

#rm(list = objects())

library(readxl)
library(magrittr)
library(ggplot2)

# Stats
library(rstatix)
library(coin) # for wilcox test 

# Set root directory manually relative to current script
root_dir <- file.path("..", "..")

data_raw_csv <- file.path(root_dir, "data", "raw", "csv")
data_processed <- file.path(root_dir, "data", "processed")
figures <- file.path(root_dir, "figures")

# Load data
d <- read.csv(file.path(data_processed, "fairness_ratings_offer_average.csv")) %>%
  as.data.frame()
d$group <- as.factor(d$group)

# Labels
pTitle = "Fairness Ratings"
pX = "Offers"
pY = "Rating"
saveName = file.path(figures, 'fairness_ratings.png')


# Plot
fig <- ggplot(d, aes(offers, meanFair, color = group)) +
  geom_line() +
  geom_errorbar(aes(ymin = meanFair - semFair, ymax = meanFair + semFair), width = 0.2) +
  geom_point() +
  scale_color_manual(values = c("#CD1818", "#3AA6B9")) +
  scale_x_continuous(breaks = seq(0, 10, 1))+
  scale_y_continuous(breaks = seq(0, 9, 1))+
  theme_minimal() +
  labs(title = pTitle, 
       x = pX, 
       y = pY,
       color = "Group") +
  theme(plot.title = element_text(size = 8, hjust = 0.5), # center title 
        axis.title.x = element_text(size = 8),
        axis.title.y = element_text(size = 8),
        axis.text = element_text(size = 8)) + 
  theme(legend.position = c(0.9, 0.9),
        legend.title=element_blank(),
        legend.text=element_text(size = 8)) 

fig



# Save figure 
ggsave(saveName, plot = fig, 
       width = 4, height = 3, dpi = 600)











