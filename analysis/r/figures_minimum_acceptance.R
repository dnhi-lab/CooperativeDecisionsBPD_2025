# Figures for Minimum Acceptance Rating 

#rm(list = objects())

library(readxl)
library(magrittr)
library(ggplot2)
library(gghalves)

# Stats
library(rstatix)
library(coin) # for wilcox test 

# Set root directory manually relative to current script
root_dir <- file.path("..", "..")

data_raw_csv <- file.path(root_dir, "data", "raw", "csv")
data_processed <- file.path(root_dir, "data", "processed")
figures <- file.path(root_dir, "figures")

# Load data 
d <- read.csv(file.path(data_raw_csv, "minimum_acceptance.csv")) %>%
  as.data.frame()
d$group <- as.factor(d$group)
names(d)[2] <- "yData"

# Labels
pTitle = "Minimum Acceptance Rating"
pX = "Group"
pY = "Smalles accepted offer"
saveName = file.path(figures, 'minimum_acceptance.png')

##### Stats #####

# Calculate Welch's t-test 
t.test(d$yData ~ d$group, var.equal = FALSE)

# Calculate the effect size
d %>% cohens_d(yData ~ group, var.equal = FALSE)

# Calculate the ranksum test
coin::wilcox_test(d$yData ~ d$group)

# Calculate the effect size for Wilcoxon test 
d %>% wilcox_effsize(yData ~ group)


##### Raincloud Plot #####

fig <- ggplot(d, aes(x = group, y = yData, fill = group)) + 
  geom_half_violin(aes(color = group), 
                   side = "r", 
                   alpha = 0.7, 
                   position = position_nudge(x = 0.15)) +  
  geom_point(aes(color = group), 
             position = position_jitterdodge(jitter.width = 0.225, dodge.width = 0.3, seed = 2025),
             size = 1.5,
             alpha = 0.5) +
  geom_boxplot(width = 0.15, 
               position = position_nudge(x = -0.225), 
               outlier.shape = 3,
               fatten = 1) +  
  scale_fill_manual(values = c("BPD" = "#CD1818", "HC" = "#3AA6B9")) +  
  scale_color_manual(values = c("BPD" = "#CD1818", "HC" = "#3AA6B9")) + 
  scale_y_continuous(breaks = seq(0, 10, 1), limits = c(0, 10)) +
  theme_minimal() +
  labs(title = pTitle, 
       x = pX, 
       y = pY) + 
  theme(plot.title = element_text(size = 8, hjust = 0.5), # center title 
        axis.title.x = element_text(size = 8),
        axis.title.y = element_text(size = 8),
        axis.text = element_text(size = 8)) + 
  theme(panel.grid.major.x = element_blank(), # remove vertical grid lines       
        legend.position = "none")
fig

# Save
ggsave(saveName, plot = fig, 
       width = 3.15, height = 2.5, dpi = 600)
