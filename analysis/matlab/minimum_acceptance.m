%% Analyse MA (Minimum Acceptance) Ratings
%
% 2 groups: HC & BPD
% Participants indicate the minimum amount the other would have to offer
% for them to accept a split of 10€ (1 trial)
% Response options from 0/10 (self/other) to 10/0 in steps of 1
%==========================================================================

clear; close all

% SET
saveResults = 1;
printFigures = 1;

% set paths
rootDir = setup_paths();

% load data
load("minimum_acceptance.mat")


%% ========================================================================
% STATS
%==========================================================================

% sum items to get dissociality scores
dataBP = response(idxBP);
dataHC = response(idxHC);

% descriptive
subN = length(response);
mBP = mean(response(idxBP), "omitnan");
sdBP = std(response(idxBP), "omitnan");
mHC = mean(response(idxHC), "omitnan");
sdHC = std(response(idxHC), "omitnan");
nBP = sum(idxBP); 
nHC = sum(idxHC); 

% Welch's t-test (unequal variances but normally distributed data)
[ttWelch.H, ttWelch.P, ttWelch.CI, ttWelch.tstats] = ttest2(response(idxBP), response(idxHC), 'Vartype', 'unequal');

% Wilcoxon rank sum/ Mann-Whitney U-test (nonparametric test; if X and Y
% have different sample sizes; is robust to violations of homogeneity of variance)
[ttRank.P, ttRank.H, ttRank.tstats] = ranksum(response(idxBP), response(idxHC));

%% Display results

myLine1 = '----------------------------------------------------------------------------------';

% Missing data
disp([myLine1 newline])
display(['Missing data: ' num2str(sum(sum(isnan(response))))]);
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
% FIGURES
%==========================================================================

if printFigures

    titlePlot = 'Minimum acceptance rating';
    yLabel = 'Offer';
    ylimits = [0 10];
    xtext = 0.55;
    ytext = 9;

    mk_grouped_boxplots(dataBP', dataHC', titlePlot, yLabel, ttWelch.P, ylimits, xtext, ytext)

end


%% ========================================================================
% SAVE DATA
%==========================================================================

%% Results table

labels = ["mBPD", "sdBPD", "nBPD", "mHC", "sdHC", "nHC", "t", "df", "CIL", "CIU", "p1", "z", "p2"];

data = round([mBP, sdBP, nBP, mHC, sdHC, nHC, ...
    ttWelch.tstats.tstat, ttWelch.tstats.df, ttWelch.CI(1), ttWelch.CI(2), ttWelch.P, ...
    ttRank.tstats.zval, ttRank.P], 3);

T = array2table(data, "VariableNames", labels, "RowNames", "MA");

% save table
if saveResults
    writetable(T, fullfile(rootDir, "results/results_minimum_acceptance.xlsx"))
end