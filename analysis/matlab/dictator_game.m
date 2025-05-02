%% Analyse DG (Dictator Game)
%
% 2 groups: HC & BPD
% Participants played a one-shot Dictator Game in role of proposer
% Allocation of 10€
% Response options from 0:10 in steps of 1
%==========================================================================

clear; close all

% SET
saveResults = 1;
printFigures = 1;

% set paths
rootDir = setup_paths();

% load the data
load("dictator_game.mat")
data = response';


%% ========================================================================
% STATS
%==========================================================================

% descriptive
meanHC = mean(data(:,idxHC'));
meanBP = mean(data(:,idxBP'));
sdHC = std(data(:,idxHC'));
sdBP = std(data(:,idxBP'));
nHC = length(data(:,idxHC));
nBP = length(data(:,idxBP));

% Welch's t-test (unequal variances but normally distributed data)
[ttWelch.H, ttWelch.P, ttWelch.CI, ttWelch.tstats] = ttest2(data(idxBP), data(idxHC), 'Vartype', 'unequal');

% Wilcoxon rank sum/ Mann-Whitney U-test (nonparametric test; if X and Y
% have different sample sizes; is robust to violations of homogeneity of variance)
[ttRank.P, ttRank.H, ttRank.tstats] = ranksum(data(idxBP), data(idxHC));

%% Display results

myLine1 = '----------------------------------------------------------------------------------';

% Missing data
disp([myLine1 newline])
display(['Missing data points: ' num2str(sum(sum(isnan(data))))]);
disp([myLine1 newline])

% Group M, SD
fprintf("BPD group: M = %.3f, SD = %.3f\n", meanBP, sdBP)
fprintf("HC group: M = %.3f, SD = %.3f\n", meanHC, sdHC)
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

    ylimits = [0 10];
    yLabel = 'Allocation to other';
    xtext = 0.55;
    ytext = 9;

    %% boxplot

    titlePlot = 'Dictator Game';

    mk_grouped_boxplots(data(:,idxBP'), data(:,idxHC'), titlePlot, yLabel, ...
        ttWelch.P, ylimits, xtext, ytext)


end


%% ========================================================================
% SAVE DATA
%==========================================================================

%% Results table

labels = ["mBPD", "sdBPD", "nBPD", "mHC", "sdHC", "nHC", "t", "df", "CIL", "CIU", "p1", "z", "p2"];

data = round([meanBP, sdBP, nBP, meanHC, sdHC, nHC, ...
    ttWelch.tstats.tstat, ttWelch.tstats.df, ttWelch.CI(1), ttWelch.CI(2), ttWelch.P, ...
    ttRank.tstats.zval, ttRank.P], 3);

T = array2table(data, "VariableNames", labels, "RowNames", "DG");

% save table
if saveResults
    writetable(T, fullfile(rootDir, "results/results_dictator_game.xlsx"))
end