% Analyze SVO (Social Value Orientation) Slider Task

% 2 groups: HC & BPD
% Participants choose preferred allocation options on 15 items
% Items from http://ryanomurphy.com/styled-2/downloads/index.html
% Response options from 1 to 9

%% Two options to run this script 

% Either use social_value_orientation_slider_output.mat data 
% Or download SVO_Slider.m script (see below) and use raw response data
% from social_value_orientation_slider_input.mat file

% set
% matlab2018 = 0; % to use slider_output data 
% matlab2018 = 1; % to use raw data 

% SVO_Slider.m will not work with MATLAB 2024 because one function 
% (graphisdag) of SVO script is not implemented in newer versions

%% Input options for SVO_Slider.m:
% http://ryanomurphy.com/styled-2/downloads/files/SVO_Slider_Tutorial.pdf

% additional input argument if version A and B were used
% output = SVO Slider(Versions, Data), where 1=A, 2=B

% Option variant: subjects x choices matrix
% data contains only chosen option
% rows = subjects
% columns = choices on items (15)
% choices: from 1:9
% e.g. if 1st sub chose 3rd option on first item: 1st row, 1st column = 3

% Full payoff variant subject x payoff matrix
% data contains payoffs for self and for other
% rows = subjects
% columns = choice self-item1, choice other-item1, choice self-item2, ....
%==========================================================================

clear; close all

% SET
saveResults = 1;
printFigures = 1;
matlab2018 = 0; % 0 = use processed data; 1 = use raw data and run SVO_Slider.m first

% set paths
rootDir = setup_paths();

% load data
% either load raw data and run SVO_Slider.m
% or load output of SVO_Slider.m
if matlab2018
    load("social_value_orientation_slider_input.mat") %#ok<*UNRCH>
    [output_v1, ips_format_v1] = SVO_Slider(dVersion, dataPay);
else
    load("social_value_orientation_slider_output.mat")
end


%% ========================================================================
% EXCLUSION CRITERIA
%==========================================================================

% only if we load the raw data
if matlab2018
    disp([newline '-------------------------------------------'])
    display(['Missing data: ' num2str(sum(sum(isnan(dataPay))))]);
    disp(['-------------------------------------------' newline])
end

% get N of transitive subjects
transitiveN = sum(output_v1(:,3));
% get idx to exclude intransitive subjects
inclIdx = output_v1(:,3)==1;
% exclude
output = output_v1(inclIdx,:);
incHC = idxHC(inclIdx);
incBPD = idxBP(inclIdx);


%% ========================================================================
% PRIMARY ITEMS (Social Value Orientation Score)
%==========================================================================

% descriptive
svoHC = output(incHC,1);
svoBPD = output(incBPD,1);
mSvoHC = mean(svoHC);
mSvoBPD = mean(svoBPD);
sdSvoHC = std(svoHC);
sdSvoBPD = std(svoBPD);
nSvoHC = length(svoHC);
nSvoBPD = length(svoBPD);

% Colunm 2: SVO Category (1=Altruistic, 2=Prosocial, 3=Individualistic, 4=Competitive)
% only prosocial and individualistic subjects in our sample
categories = unique(output(:,2));
% get number of subjects in each of the categories
proHC = sum(output(incHC,2) == 2);
proBPD = sum(output(incBPD,2) == 2);
indHC = sum(output(incHC,2) == 3);
indBPD = sum(output(incBPD,2) == 3);

% mean per category and group
category = 2; % 2=prosocial, 3=individualistic
group = incHC;

mSvo = mean(output(output(group,2) == category),1);
sdSvo = std(output(output(group,2) == category),1);

%% stats

% Welch's t-test (unequal variances but normally distributed data)
[svo.ttWelch.H, svo.ttWelch.P, svo.ttWelch.CI, svo.ttWelch.tstats] = ttest2(svoBPD, svoHC, 'Vartype', 'unequal');

% Wilcoxon rank sum/ Mann-Whitney U-test (nonparametric test; if X and Y
% have different sample sizes; is robust to violations of homogeneity of variance)
[svo.ttRank.P, svo.ttRank.H, svo.ttRank.tstats] = ranksum(svoBPD, svoHC);

%% Calculate effect sizes

% Welch's ttest
% mean difference between groups
meanDiff = mSvoBPD - mSvoHC;
% averaged standatad deviation for unequal variances
avgSD = sqrt((var(svoBPD) + var(svoHC)) / 2);
% Cohen's D
cohensD = meanDiff / avgSD;

% Wilcoxon Test
% compute z-based effect size (r)
z = svo.ttRank.tstats.zval; % z-value from test
n = nSvoBPD + nSvoHC; % total sample size
r = z / sqrt(n);


%% Display results

myLine1 = '----------------------------------------------------------------------------------';
myLine2 = '==================================================================================';

disp([myLine2 newline])
disp('General Social Value Orientation')
disp([myLine2 newline])

% Group M, SD
fprintf("BPD group: M = %.3f, SD = %.3f\n", mSvoBPD, sdSvoBPD)
fprintf("HC group: M = %.3f, SD = %.3f\n", mSvoHC, sdSvoHC)

disp([myLine1 newline])

% Welch's t-test
fprintf("Welch's two-sample t-test t(%.3f) = %.3f, p = %.3f, 95%% CI [%.3f, %.3f]\n", ...
    svo.ttWelch.tstats.df, svo.ttWelch.tstats.tstat, svo.ttWelch.P, svo.ttWelch.CI(1), svo.ttWelch.CI(2));

disp([myLine1 newline])

% Wilcoxon rank sum test
fprintf("Wilcoxon rank sum two-sample t-test z = %.3f, p = %.3f\n", ...
    svo.ttRank.tstats.zval, svo.ttRank.P);

disp([myLine1 newline])


%% ========================================================================
% FIGURES
%==========================================================================

if printFigures

    x1 = svoBPD';
    x2 = svoHC';
    xtext = 1.6;
    ytext = 5;
    plotTitle = 'SVO - primary items';
    yLabel = 'SVO angle';
    pVal = svo.ttWelch.P;
    ylimits = [0, 55];

    mk_grouped_boxplots(x1, x2, plotTitle, yLabel, ...
        pVal, ylimits, xtext, ytext)

end


%% ========================================================================
% SECONDARY ITEMS (Prosocial Motivation)
%==========================================================================

% include only prosocials
% according to SVO category &
% preference for both inequality aversion and joint gain maximization over
% both individualism and altruism in the secondary items
% see http://ryanomurphy.com/styled-2/downloads/files/SVO_Slider_Tutorial.pdf

% secondary item idx for ALL tranisitve subjects
inclSN = output(:,2) == 2 & (output(:,11) + output(:,12) == 3);
% secondary item idx for HC tranisitve subjects
inclSnHC = output(:,2) == 2 & (output(:,11) + output(:,12) == 3) & incHC == 1;
% secondary item idx for BPD tranisitve subjects
inclSnBPD = output(:,2) == 2 & (output(:,11) + output(:,12) == 3) & incBPD == 1;

% descriptive
svoSnHc = output(inclSnHC,9);
svoSnBpd = output(inclSnBPD,9);
mSnHC = mean(svoSnHc);
mSnBPD = mean(svoSnBpd);
sdSnHC = std(svoSnHc);
sdSnBPD = std(svoSnBpd);
nSnHC = length(svoSnHc);
nSnBPD = length(svoSnBpd);

% get number of subjects in each of the categories
iaHC = sum(output(inclSnHC,8) == 1);
iaBPD = sum(output(inclSnBPD,8) == 1);
jgHC = sum(output(inclSnHC,8) == 2);
jgBPD  = sum(output(inclSnBPD,8) == 2);

% Welch's t-test (unequal variances but normally distributed data)
[sn.ttWelch.H, sn.ttWelch.P, sn.ttWelch.CI, sn.ttWelch.tstats] = ttest2(svoSnBpd, svoSnHc, 'Vartype', 'unequal');

% Wilcoxon rank sum/ Mann-Whitney U-test (nonparametric test; if X and Y
% have different sample sizes; is robust to violations of homogeneity of variance)
[sn.ttRank.P, sn.ttRank.H, sn.ttRank.tstats] = ranksum(svoSnBpd, svoSnHc);

%% Display results

myLine1 = '----------------------------------------------------------------------------------';
myLine2 = '==================================================================================';

disp([myLine2 newline])
disp('Prosocial Motivation')
disp([myLine2 newline])

% Group M, SD
fprintf("BPD group: M = %.3f, SD = %.3f\n", mSnBPD, sdSnBPD)
fprintf("HC group: M = %.3f, SD = %.3f\n", mSnHC, sdSnHC)

disp([myLine1 newline])

% Welch's t-test
fprintf("Welch's two-sample t-test t(%.3f) = %.3f, p = %.3f, 95%% CI [%.3f, %.3f]\n", ...
    sn.ttWelch.tstats.df, sn.ttWelch.tstats.tstat, sn.ttWelch.P, sn.ttWelch.CI(1), sn.ttWelch.CI(2));

disp([myLine1 newline])

% Wilcoxon rank sum test
fprintf("Wilcoxon rank sum two-sample t-test z = %.3f, p = %.3f\n", ...
    sn.ttRank.tstats.zval, sn.ttRank.P);

disp([myLine1 newline])


%% ========================================================================
% FIGURES
%==========================================================================

if printFigures

    x1 = svoSnBpd';
    x2 = svoSnHc';
    xtext = 1.6;
    ytext = 0.9;
    plotTitle = 'SVO - secondary items';
    yLabel = 'Prosocial Motivation (0=IA,1=JG)';
    pVal = sn.ttRank.P;
    ylimits = [0, 1];

    mk_grouped_boxplots(x1, x2, plotTitle, yLabel, ...
        pVal, ylimits, xtext, ytext)

end

%% ========================================================================
% SAVE DATA
%==========================================================================

% save for R
if saveResults

    % svo angle
    primarySVO = output(:,1);

    % primary items
    group = strings(length(primarySVO),1);
    group(incHC) = 'HC';
    group(incBPD) = 'BPD';

    primarySVOT = table(primarySVO, group);
    writetable(primarySVOT, fullfile(rootDir,'data', 'processed','svo_primary.csv'));

    % secondary items
    secondarySVO = output(:,9); %#ok<*NASGU>
    % only valid cases
    secondarySVO = output(inclSN,9);
    idx_sec_hc = inclSnHC(inclSN);
    idx_sec_bp = inclSnBPD(inclSN);

    group = strings(length(secondarySVO),1);
    group(idx_sec_hc == 1) = 'HC';
    group(idx_sec_bp == 1) = 'BPD';

    secondarySVOT = table(secondarySVO, group);
    writetable(secondarySVOT, fullfile(rootDir,'data', 'processed','svo_secondary.csv'));

end


%% Results table

labels = ["mBPD", "sdBPD", "nBPD", "mHC", "sdHC", "nHC", "t", "df", "CIL", "CIU", "p1", "z", "p2"];

generalSVO = [mSvoBPD, sdSvoBPD, nSvoBPD, mSvoHC, sdSvoHC, nSvoHC, ...
    svo.ttWelch.tstats.tstat, svo.ttWelch.tstats.df, svo.ttWelch.CI(1), svo.ttWelch.CI(2), svo.ttWelch.P, ...
    svo.ttRank.tstats.zval, svo.ttRank.P];

prosocialMotivation = [mSnBPD, sdSnBPD, nSnBPD, mSnHC, sdSnHC, nSnHC, ...
    sn.ttWelch.tstats.tstat, sn.ttWelch.tstats.df, sn.ttWelch.CI(1), sn.ttWelch.CI(2), sn.ttWelch.P, ...
    sn.ttRank.tstats.zval, sn.ttRank.P];

data = round([generalSVO; prosocialMotivation], 3);

T = array2table(data, "VariableNames", labels, "RowNames", ["General SVO", "prosocial Motivation"]);

% save table
if saveResults
    writetable(T, fullfile(rootDir, "results/results_sovial_value_orientation.xlsx"))
end