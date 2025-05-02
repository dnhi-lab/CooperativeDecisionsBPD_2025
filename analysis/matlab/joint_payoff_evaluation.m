% Analyze JPE (Joint Payoff Evaluation) Task
%
% 2 groups: HC & BPD
% Participants evaluate payoff allocations for self and other
% Allocations range from -50 to +50 in steps of 1 (121 trials)
% Response options from 1 (= very good) to 8 (very bad) in steps of 1

% !!! add SPM to path for PXP !!!
%==========================================================================

clear; close all

% SET
saveResults = 1;
printFigures = 1;

% set paths
rootDir = setup_paths();

% load data
load("joint_payoff_evaluation.mat")


%% ========================================================================
% EXCLUSION CRITERIA
%==========================================================================

subN = length(idxHC);

% we exclude subjects who choose the same choice option more than 90% of
% the trials
criterion = 121 * 0.9;

% count how often each response option was chosen
% rows: choice options from 1:8, row 9 is nans, columns: subjects
% check if one of the options was chosen more than 90% criterion
dataVar = nan(9,subN);
dataExcl = nan(1,subN);

for iSub = 1:subN

    for iVal = 1:8 % response from 1:8
        dataVar(iVal,iSub) = sum(responses(:,iSub) == iVal);
    end
    % count nans
    dataVar(9,iSub) = sum(isnan(responses(:,iSub)));
    % >= than 80% same responses per profile (row) per participant (column)
    dataExcl(:,iSub) = sum(dataVar(:,iSub) > criterion);

end


%% ========================================================================
% PREPARE JPE MODELS
%==========================================================================
% get necessary variables from items

% absolute inequality (IA)
items(:,3) = abs(items(:,1) - items(:,2));

% joint gain
items(:,4) = sum(items(:,1:2), 2);

% for Fehr-Schmidt-Model =
% alpha*self + beta*disadvantageous IA + gamma*advantageous IA
% disadvantageous IA = max(other - self, 0)
items(:,5) = max(items(:,2) - items(:,1), 0);
% advantageous IA = max(self - other, 0)
items(:,6) = max(items(:,1) - items(:,2), 0);

% for ERC model (Equity, Reciprocity, Competition) =
% alpha * self + beta * 0.5 * (self/(other+self) - 0.5 )^2
items(:,7) = 0.5 * ( items(:,1) ./ items(:,4) - 0.5 ).^2;
findInf = isinf(items(:,7));
findNan = isnan(items(:,7));
% set inf and nan to zero
items(findInf,7) = 0;
items(findNan,7) = 0;

% intercept
items(:,8) = 1;

% positive and negative parameter for FS model
% self positive
items(:,9) = max(items(:,1),0);
% self negative
items(:,10) = min(items(:,1),0);
% disadvantageous IA positive
self_pos = items(:,1) >= 0;
items(:,11) = items(:,5);
items(self_pos==1,11) = 0;
% disadvantageous IA negative
items(:,12) = items(:,6);
items(self_pos==0,12);


%% HF models: regression models

% model names
modNames = {'Individualism',...
    'Prosocial', ...
    'Altruism', ...
    'Joint-gain',...
    'Inequality',...
    'Inequality & Joint-gain',...
    'Fehr-Schmidt', ...
    'ERC',...
    'Fehr-Schmidt-pos-neg'};

modelX{1} = items(:,[8,1]);         % Individualism: self
modelX{2} = items(:,[8,1,2]);       % Altruism: self, other
modelX{3} = items(:,[8,2]);         % Simple altruism: self+other
modelX{4} = items(:,[8,4]);         % joint gain model: abs(self-other)
modelX{5} = items(:,[8,3]);         % Inequality model: abs(self-other), self+other
modelX{6} = items(:,[8,3,4]);       % IA + JG: abs(self-other), self+other
modelX{7} = items(:,[8,1,5,6]);     % Fehr-Schmidt: self, disadvantageous inequality, advantageous inequality
modelX{8} = items(:,[8,1,7]);       % ERC: self, quadratic normalized inequality
modelX{9} = items(:,[8,9,10,11,12]); % Fehr-Schmidt with pos and neg: self-pos, self-neg, disadIA-pos, disadIA-neg, advanIA

% N of models
nModels = size(modelX,2);
% N of model parameter for each model
modK = nan(nModels,1);
for iMod = 1:nModels
    modK(iMod,1) = size(modelX{iMod}, 2);
end

%% ========================================================================
% REGRESS
%==========================================================================

% initialize
[modelN, modelVar] = deal(nan(subN, 1));
[modelB, modelR, modelStats] = deal(cell(1, nModels));
[modelSSR, modelBIC] = deal(nan(subN, nModels));

for iSub = 1:subN

    % response variable
    modelY = responses(:,iSub);

    % number of observations per subject
    modelN(iSub,1) = size(modelY, 1);
    % variance of observations per subject
    modelVar(iSub,1) = var(modelY);

    for iMod = 1:nModels

        % regress
        [modelB{iMod}(iSub,:), ~, modelR{iMod}(iSub,:), ~, modelStats{iMod}(iSub,:)] = regress(modelY, modelX{iMod});

        % residual sum of squares (RSS) aka sum of squared residuals (SSR)
        modelSSR(iSub,iMod) = sum(modelR{iMod}(iSub,:) .^2);
        % Bayesian Information Criterion, gaussian special case (Schwarz, 1978)
        % SBC = n * log(SSE/n) + p * log(n), where p is number of parameters
        modelBIC(iSub,iMod) = modelN(iSub,1) * log(modelSSR(iSub,iMod)/modelN(iSub,1)) + modK(iMod,1) * log(modelN(iSub,1));

    end

end


%% ========================================================================
% FIGURES
%==========================================================================

% Plot Log Group Bays Factors (barplot)
if printFigures

    colBPD = [0.6980 0.1216 0.4000];
    colHC = [0.2784 0.2549 0.4078];

    %% BPD

    % Log group bayes factors = bic1- bic2 because of log quotient property
    % substract 1st model
    bicSumBP = sum(modelBIC(idxBP,:));
    lbfBP = bicSumBP - (bicSumBP(1,1));

    % plot LBFs
    figure
    barh(fliplr(lbfBP), 'FaceColor', colBPD)
    xlabel('Log-group Bayes factors')
    set(gca,'yticklabel', fliplr(modNames),'FontSize', 10.5)
    title('BPD sample')

    % Protected exceedance probabilities
    % -BIC because for log likelihood max value is best model but for BIC min
    % value is best model
    PXP_3 = PXP_random_plot_v1(-modelBIC(idxBP,:), 'PXP - BPD sample' );

    %% HC

    % Log group bayes factors
    bicSumHC = sum(modelBIC(idxHC,:));
    lbfHC = bicSumHC - (bicSumHC(1,1));

    % plot LBFs
    figure
    barh(fliplr(lbfHC), 'FaceColor', colHC)
    xlabel('Log-group Bayes factors')
    set(gca,'yticklabel', fliplr(modNames),'FontSize', 10.5)
    title('HC sample')

    % Protected exceedance probabilities
    pxpHC = PXP_random_plot_v1( -modelBIC(idxHC,:), 'PXP - HC sample');


end


%% ========================================================================
% STATS
%==========================================================================

% compare disadvantegeous IA model parameter of winning model (Fehr-Schmidt model)
FSdis = modelB{7}(:,3);

mDisBP = mean(FSdis(idxBP));
mDisHC = mean(FSdis(idxHC));
sdDisBP = std(FSdis(idxBP));
sdDisHC = std(FSdis(idxHC));
nDisBP = sum(idxBP);
nDisHC = sum(idxHC); 

% Welch's t-test (unequal variances but normally distributed data)
[ttWelch.H, ttWelch.P, ttWelch.CI, ttWelch.tstats] = ttest2(FSdis(idxBP), FSdis(idxHC), 'Vartype', 'unequal');

% Wilcoxon rank sum/ Mann-Whitney U-test (nonparametric test; if X and Y
% have different sample sizes; is robust to violations of homogeneity of variance)
[ttRank.P, ttRank.H, ttRank.tstats] = ranksum(FSdis(idxBP), FSdis(idxHC));


%% Display results

myLine1 = '----------------------------------------------------------------------------------';

% Missing data
disp([myLine1 newline])
display(['Missing data: ' num2str(sum(sum(isnan(responses))))]);
disp([myLine1 newline])
display(['Same choice more than 90%: ' num2str(sum(sum(dataExcl)))]);
disp([myLine1 newline])

% Group M, SD
fprintf("BPD group: M = %.3f, SD = %.3f\n", mDisBP, sdDisBP)
fprintf("HC group: M = %.3f, SD = %.3f\n", mDisHC, sdDisHC)
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
% SAVE DATA
%==========================================================================

% Save data for R
if saveResults

    %% Save BIC & PXP

    % substract model with worst fit from all bics
    LBFhc = bicSumHC - max(bicSumHC); %#ok<*UNRCH>
    LBFbp = bicSumBP - max(bicSumBP);

    T = table(modNames', bicSumHC', LBFhc', pxpHC.pxp', bicSumBP', LBFbp', PXP_3.pxp');
    T = renamevars(T, ["Var1", "Var2", "Var3", "Var4", "Var5", "Var6", "Var7"], ...
        ["Model_name", "BIC_HC", "LBF_HC", "PXP_HC", "BIC_BPD", "LBF_BPD", "PXP_BPD"]);

    % flip
    T = flipud(T);

    writetable(T, fullfile(rootDir, 'data', 'processed','jpe_model_comparison.csv'));

    %% Save FS disadvantageous IA model parameters

    group = strings(length(FSdis), 1);
    group(idxHC) = 'HC';
    group(idxBP) = 'BPD';
    
    T1 = table(FSdis, group);

    writetable(T1, fullfile(rootDir,'data', 'processed','jpe_inequality_parameter.csv'));

end

%% Results table

labels = ["mBPD", "sdBPD", "nBPD", "mHC", "sdHC", "nHC", "t", "df", "CIL", "CIU", "p1", "z", "p2"];

data = round([mDisBP, sdDisBP, nDisBP, mDisHC, sdDisHC, nDisHC, ...
    ttWelch.tstats.tstat, ttWelch.tstats.df, ttWelch.CI(1), ttWelch.CI(2), ttWelch.P, ...
    ttRank.tstats.zval, ttRank.P], 3);

T = array2table(data, "VariableNames", labels, "RowNames", "JPEDis");

% save table
if saveResults
    writetable(T, fullfile(rootDir,"results/results_jpe_inequality_parameter.xlsx"))
end
