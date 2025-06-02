# Cooperative Decision-Making in Borderline Personality Disorder


This repository contains the data and analysis code for the study:  
**"Cooperative decision-making in borderline personality disorder: insights from a preregistered study using a comprehensive economic task battery."**


## Repository Structure

- `data_raw_csv/`: Raw data in CSV format, including participant groupings (`HC`, `BPD`) and task responses.
- `data_raw_matlab/`: Equivalent raw data in MATLAB format (used for statistical analysis).
- `data_preprocessed_R/`: Data processed in R (used for statistical analysis and plotting).
- `results/`: Output files generated after running analysis scripts.
- `figures/`: Output figures generated after running the R figure scripts.
- `helpers/`: Helper functions for MATLAB scripts.

## Key Files

- MATLAB Analysis Scripts:  
  Contain the core analysis code. Running these will create the necessary results.

- R Calculations:  
  - `bayesFactors.R`: Bayes factor calculations.  
  - `figures_*.R`: Scripts for creating figures and computing effect sizes in R.

## Data Description

### Common Structure
Each row corresponds to a participant. The grouping variable is either `BPD` or `HC`. Each task has task-specific response variables:

### Task-Specific Details

- **Dictator Game (DG)**:  
  `response` = amount of money allocated to the other (1 to 10, step 1)

- **Dissociality (DIS)**:  
  `sumScore` = total score on the dissociality facet

- **Fairness Ratings (FN)**:  
  `offer0` to `offer10` = ratings of fairness for offers 0–10 (1 = totally fair, 9 = totally unfair)

- **Joint Payoff Evaluation (JPE)**:  
  `item1` to `item121` = evaluations of payoff allocations (1 = very good, 8 = very bad)

- **Minimum Acceptance (MA)**:  
  `response` = minimum acceptable offer (0 to 10, step 1)

- **Ultimatum Game (UG)**:  
  `offer1` to `offer6` = binary response (1 = reject, 0 = accept)

- **Social Value Orientation (SVO)**:  
  `SVO_SliderOutput.csv` contains computed SVO scores using Ackermann's `SVO_Slider.m` (not raw trial data.)

## How to Run the Code

1. Ensure you have MATLAB and R installed.
2. Run the MATLAB analysis scripts (`e.g. dictator_game.m`) to generate results.
3. Run R scripts for plotting and Bayes factor calculations (`figures_*.R`, `bayesFactors.R`).

