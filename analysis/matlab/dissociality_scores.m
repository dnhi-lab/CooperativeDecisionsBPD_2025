% Analyse Dissociality Scores from PiCD Questionnaire
%
% 2 groups: HC & BPD
% Data collected via Soscisurvey
% 12 dissociality items from 60 item PiCD
% Response options from 1:5 in steps of 1 (min score = 12, max = 60)
% All scale items are simply added together (note that each domain item is every fifth item)
% Dissocial = 4 + 9 + 14 + 19 + 24 + 29 + 34 + 39 + 44 + 49 + 54 + 59
% PiCD (The Personality Inventory for ICD-11; Damovsky et al., 2021; Oltmanns & Widiger, 2018)
%==========================================================================

clear; close all

% SET
saveResults = 1;
printFigures = 1;

% set paths
rootDir = setup_paths();

% load the data
load("dissociality_scores.mat")


%% ========================================================================
% STATS
%==========================================================================

% sum items to get dissociality scores
data = sum(dissociality, 2, "omitnan"); %#ok<*NASGU>
dataBP = sum(dissociality(idxBP,:), 2, "omitnan");
dataHC = sum(dissociality(idxHC,:), 2, "omitnan");

% descriptive
mBP = mean(dataBP);
sdBP = std(dataBP);
mHC = mean(dataHC);
sdHC = std(dataHC);
nBP = length(dataBP); 
nHC = length(dataHC); 

% Welch's t-test (unequal variances but normally distributed data)
[ttWelch.H, ttWelch.P, ttWelch.CI, ttWelch.tstats] = ttest2(dataBP, dataHC, 'Vartype', 'unequal');

% Wilcoxon rank sum/ Mann-Whitney U-test (nonparametric test; if X and Y
% have different sample sizes; is robust to violations of homogeneity of variance)
[ttRank.P, ttRank.H, ttRank.tstats] = ranksum(dataBP, dataHC);

%% Display results

myLine1 = '----------------------------------------------------------------------------------';

disp([myLine1 newline])
display(['Missing data points: ' num2str(sum(sum(isnan(dissociality))))]);
disp([myLine1 newline])

% Group M, SD
fprintf("BPD group: M = %.3f, SD = %.3f\n", mBP, sdBP)
fprintf("HC group: M = %.3f, SD = %.3f\n", mHC, sdHC)
disp([myLine1 newline])

% Welch's t-test
fprintf("Welch's two-sample t-test t(%.3f) = %.3f, p = %.3f, 95%% CI [%.3f, %.3f]\n", ...
    ttWelch.tstats.df, ttWelch.tstats.tstat, ttWelch.P, ttWelch.CI(1), ttWelch.CI(2));
disp([myLine1 newline])

% Wilcoxon rank sum test
fprintf("Wilcoxon rank sum two-sample t-test z = %.3f, p = %.3f\n", ...
    ttRank.tstats.zval, ttRank.P);
disp([myLine1 newline])


%% ========================================================================
% FIGURE
%==========================================================================

if printFigures

    ylimits = [0 5*12];
    xtext = 0.55;
    ytext = 55;
    plotTitle = 'Dissociality scores';
    yLabel = 'Mean score';

    mk_grouped_boxplots(dataBP', dataHC', plotTitle, yLabel, ttWelch.P, ylimits, xtext, ytext)

end


%% ========================================================================
% SAVE DATA
%==========================================================================

%% Results table

labels = ["mBPD", "sdBPD", "nBPD", "mHC", "sdHC", "nHC", "t", "df", "CIL", "CIU", "p1", "z", "p2"];

data = round([mBP, sdBP, nBP, mHC, sdHC, nHC, ...
    ttWelch.tstats.tstat, ttWelch.tstats.df, ttWelch.CI(1), ttWelch.CI(2), ttWelch.P, ...
    ttRank.tstats.zval, ttRank.P], 3);

T = array2table(data, "VariableNames", labels, "RowNames", "dissociality");

% save table
if saveResults
    writetable(T, fullfile(rootDir, "results/results_dissociality_scores.xlsx"))
end
