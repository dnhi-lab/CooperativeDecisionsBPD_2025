# Figures for Joint Payoff Evaluation (JPE) Task 

#rm(list = objects())

library(readxl)
library(magrittr)

# Stats
library(rstatix)
library(coin) # for wilcox test 

# Set root directory manually relative to current script
root_dir <- file.path("..", "..")

data_raw_csv <- file.path(root_dir, "data", "raw", "csv")
data_processed <- file.path(root_dir, "data", "processed")
figures <- file.path(root_dir, "figures")


# ------------------------------------------------------------------------------
# JPE FS Model parameter estimates


# Load data 
d <- read.csv(file.path(data_processed, "jpe_inequality_parameter.csv")) %>%
  as.data.frame()
d$group <- as.factor(d$group)
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


# ------------------------------------------------------------------------------
# JPE Model Comparison

##### HC - Log-group Bayes Factors ##### 

# Load data 
d <- read.csv(file.path(data_processed, "jpe_model_comparison.csv")) %>%
  as.data.frame()
d$Model_name <- factor(d$Model_name, levels = d$Model_name)

# Labels
pTitle = "HC Group\n"
pX = "\nLog-group Bayes factors"
saveName = file.path(figures, 'jpe_lbfs_hc.png')


# Plot Log-group Bayes Factors
fig <- ggplot(d) +
  geom_col(aes(LBF_HC, Model_name),
           fill = '#3AA6B9', width = 0.7, alpha = 0.7, color = "#3AA6B9", size = 0.6) +
  geom_vline(xintercept = 0, size = 1) +
  scale_x_continuous(limits = c(-6000, 0), 
                     breaks = seq(-6000, 0, by = 2000),
                     expand = c(0, 0)) + # horizontal axis does not extend to either side
  labs(title = pTitle, 
       x = pX) +
  theme_minimal() +
  theme(axis.ticks.x = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        plot.title = element_text(size = 10, hjust = 0.5), 
        axis.title.x = element_text(size = 10),
        axis.title.y = element_blank()) 

fig

# Save
ggsave(saveName, plot = fig, 
       width = 3.15, height = 2.5, dpi = 600)


##### HC - PXP ##### 

# Labels
pX = "\nPXP"
saveName = file.path(figures, 'jpe_pxp_hc.png')

fig <- ggplot(d) +
  geom_col(aes(PXP_HC, Model_name),
           fill = '#3AA6B9', width = 0.7, alpha = 0.7, color = "#3AA6B9", size = 0.6) +
  geom_vline(xintercept = 0, size = 1) +
  scale_x_continuous(limits = c(0, 1), 
                     breaks = c(0, 0.5, 1),
                     expand = expansion(add = c(0, 0.005))) + # extention of horizontal axis
  labs(title = pTitle, 
       x = pX) +
  theme_minimal() +
  theme(axis.ticks.x = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        plot.title = element_text(size = 10, hjust = 0.5), 
        axis.title.x = element_text(size = 10),
        axis.title.y = element_blank(),
        axis.text.y = element_blank()) 


fig

# Save
ggsave(saveName, plot = fig, 
       width = 1.575, height = 2.5, dpi = 600)


##### BPD - Log-group Bayes Factors ##### 

# Labels
pTitle = "BPD Group\n"
saveName = file.path(figures, 'jpe_lbfs_bpd.png')

# Plot Log-group Bayes Factors
fig <- ggplot(d) +
  geom_col(aes(LBF_BPD, Model_name),
           fill = '#CD1818', width = 0.7, alpha = 0.7, color = "#CD1818", size = 0.6) +
  geom_vline(xintercept = 0, size = 1) +
  scale_x_continuous(limits = c(-4000, 0), 
                     breaks = seq(-4000, 0, by = 1000),
                     expand = c(0, 0)) + # horizontal axis does not extend to either side
  labs(title = pTitle, 
       x = pX) +
  theme_minimal() +
  theme(axis.ticks.x = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        plot.title = element_text(size = 10, hjust = 0.5), 
        axis.title.x = element_text(size = 10),
        axis.title.y = element_blank()) 

fig

# Save
ggsave(saveName, plot = fig, 
       width = 3.15, height = 2.5, dpi = 600)



##### HC - PXP ##### 

# Labels
pX = "\nPXP"
saveName = file.path(figures, 'jpe_pxp_bpd.png')

fig <- ggplot(d) +
  geom_col(aes(PXP_BPD, Model_name),
           fill = '#CD1818', width = 0.7, alpha = 0.7, color = "#CD1818", size = 0.6) +
  geom_vline(xintercept = 0, size = 1) +
  scale_x_continuous(limits = c(0, 1), 
                     breaks = c(0, 0.5, 1),
                     expand = expansion(add = c(0, 0.005))) + # extention of horizontal axis
  labs(title = pTitle, 
       x = pX) +
  theme_minimal() +
  theme(axis.ticks.x = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        plot.title = element_text(size = 10, hjust = 0.5), 
        axis.title.x = element_text(size = 10),
        axis.title.y = element_blank(),
        axis.text.y = element_blank()) 

fig

# Save
ggsave(saveName, plot = fig, 
       width = 1.575, height = 2.5, dpi = 600)


