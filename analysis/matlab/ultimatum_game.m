%% Analyse UG (Ultimatum Game)
%
% 2 groups: HC & BPD
% Participants play 6 rounds of an Ultimatum Game in the role of the
% responder; they accept or reject offers from 6 others (6 trials)
% Offers range from 1 to 6€ in steps of 1 (1:3=unfair; 4:6=fair)
% Response options from 1 (reject) to 2 (accept) - I transform this in the
% code to 1 (reject) and 0 (accept)
%==========================================================================

clear; close all

% SET
saveResults = 1;
printFigures = 1;

% set paths
rootDir = setup_paths();

% load data
load("ultimatum_game.mat")


%% ========================================================================
% STATS
%==========================================================================

% intransivitv if more than one diff < 0 per subject
transCheck = sum(diff(response));

% mean rejection rate per subject
mReject = mean(response);
mBP = round(mean(mReject(:, idxBP)) * 100, 3);
mHC = round(mean(mReject(:, idxHC)) * 100, 3);
sdBP = round(std(mReject(:, idxBP)) * 100, 3);
sdHC = round(std(mReject(:, idxHC)) * 100, 3);
nBP = length(mReject(:, idxBP)); %#ok<*NASGU>
nHC = length(mReject(:, idxHC));

% Welch's t-test (unequal variances but normally distributed data)
[ttWelch.H, ttWelch.P, ttWelch.CI, ttWelch.tstats] = ttest2(mReject(:, idxBP), mReject(:, idxHC), 'Vartype', 'unequal');

% Wilcoxon rank sum/ Mann-Whitney U-test (nonparametric test; if X and Y
% have different sample sizes; is robust to violations of homogeneity of variance)
[ttRank.P, ttRank.H, ttRank.tstats] = ranksum(mReject(:, idxBP), mReject(:, idxHC));

%% Display results

myLine1 = '----------------------------------------------------------------------------------';

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

    ylimits = [0 100]; % set ylim for all plots
    yLabel = 'Average offer rejection';
    xtext = 0.55;
    ytext = 90;

    % all offers
    titlePlot = 'Ultimatum Game: offer rejections across all offers';
    mk_grouped_boxplots(mReject(idxBP)*100, mReject(idxHC)*100, ...
        titlePlot, yLabel, ttWelch.P, ylimits, xtext, ytext)

end


%% ========================================================================
% DISSOCIALITY SCORES
%==========================================================================

% get scores from ana_main_diss
load dissociality_scores.mat

%% prepare data: long format

% get mean dissociality score per participant
scoresDiss = sum(dissociality, 2, 'omitnan');
nSub = length(dissociality);

% 6 UG items so rep every variable 6 times
subID = 1:nSub;
subID = repelem(subID, 6)';
group = idxBP + 1; % now 1=HC, 2=BP
group = repelem(group, 6);
offer = repmat(1:6, 1, nSub)';
dissScore = repelem(scoresDiss, 6);
offerReject = reshape(response, [], 1);

T = table(subID, group, offer, offerReject, dissScore);

% separate group tables
T1 = T(T.group==1,:);
T2 = T(T.group==2,:);

T.group = categorical(T.group);
T1.group = categorical(T1.group);
T2.group = categorical(T2.group);

% add centered dissocilaity and offer variable
T.offerC = T.offer - mean(T.offer);
T.dissScoreC = T.dissScore - mean(T.dissScore) ;


%% ========================================================================
% GLMM
%==========================================================================

% dependent variable: rejection (yes/no)
% fixed: group (BPD/HC), offer amounts (1:6), dissociality scores
% random: participant ID

% interaction model without dissociality
UG_formula = 'offerReject ~ group * offerC + (1|subID)';
mdlUG = fitglme(T, UG_formula,'Distribution','binomial', 'link', 'logit');
disp(mdlUG)

% Calculate effects sizes: Odds Ratios by converting Log-Odds Ratios
estimates1 = mdlUG.Coefficients.Estimate;
oddsRatios1 = exp(estimates1);

% interaction model without group with centered variables
% https://stats.oarc.ucla.edu/other/mult-pkg/faq/general/faqhow-do-i-interpret-the-sign-of-the-quadratic-term-in-a-polynomial-regression/
UGDiss_formula = 'offerReject ~ offerC * dissScoreC  + (1|subID)';
mdlUGDiss = fitglme(T, UGDiss_formula,'Distribution','binomial', 'link', 'logit');
disp(mdlUGDiss)

% Calculate effects sizes: Odds Ratios by converting Log-Odds Ratios
estimates2 = mdlUGDiss.Coefficients.Estimate;
oddsRatios2 = exp(estimates2);


%% ========================================================================
% SAVE DATA
%==========================================================================

if saveResults

    % save as word doc
    cd(fullfile(rootDir, 'results'))

    % Choose model & name
    mdlSave = mdlUG;
    mdlName = "ultimatum_game"; % "ultimatum_game-dissociality"
    docName = sprintf('GLMM_model_%s', mdlName);

    % get Odds Ratios for current model
    estimates = mdlSave.Coefficients.Estimate;
    oddsRatios = exp(estimates);

    % Extract fixed effects table
    fE = dataset2table(mdlSave.Coefficients);
    % format table
    roundValues = array2table(round(fE{:,2:end},3)); % round to 3 decimal points
    fixedEffects = [fE.Name, roundValues]; % add names again
    fixedEffects.Properties.VariableNames = fE.Properties.VariableNames; % add original variable names
    % Add Odds Ratios to tables
    fixedEffects = addvars(fixedEffects, oddsRatios);
    % Extract model fit statistics
    aic = mdlSave.ModelCriterion.AIC;
    bic = mdlSave.ModelCriterion.BIC;
    logLikelihood = mdlSave.LogLikelihood;
    fit = table(aic, bic, logLikelihood);

    % save text in document
    import mlreportgen.dom.*;
    % Create a new Word document
    doc = Document( docName, 'docx');

    % Add a title to the document
    titleDoc = Paragraph('GLMM Model Results');
    titleDoc.Style = {Bold, FontSize('12pt')};
    append(doc, titleDoc);

    % Model fit
    append(doc, Paragraph());
    append(doc, Paragraph('Model Formula:'));
    append(doc, formattedDisplayText(mdlSave.Formula));

    % Fixed effects
    t = Table(fixedEffects); % create a DOM table
    t.Style = [t.Style
        {NumberFormat("%1.3f"),... % precision of 3 digits after decimal point
        Width("100%"),...
        Border("solid"),...
        ColSep("solid"),...
        RowSep("solid")}];
    append(doc, Paragraph('Fixed Effects:'));
    append(doc, t);
    % Model fit
    append(doc, Paragraph());
    append(doc, Paragraph('Model fit:'));
    append(doc, fit);

    % Close the document
    close(doc);
    % Display the document (opens it in Word if you have it installed)
    rptview(doc.OutputPath);

    cd(rootDir)


    %% save for R: summarized data

    % Ns
    nHC = sum(idxHC);
    nBP = sum(idxBP);

    %% rejection rates for all offers separately
    clear mRejectHC sdRejectHC mRejectBP sdRejectBP
    rejectHC = response(:, idxHC);
    mRejectHC = mean(rejectHC, 2) * 100;
    sdRejectHC = std(rejectHC, 0, 2) * 100;
    semRejectHC = sdRejectHC / sqrt(nHC);

    rejectBP = response(:, idxBP);
    mRejectBP = mean(rejectBP, 2) * 100;
    sdRejectBP = std(rejectBP, 0, 2) * 100;
    semRejectBP = sdRejectBP / sqrt(nBP);

    clear group;
    group = strings(12,1);
    group(1:6,1) = 'HC';
    group(7:12,1) = 'BPD';

    meanRejections = [mRejectHC; mRejectBP];
    sdRejections = [sdRejectHC; sdRejectBP];
    semRejections = [semRejectHC; semRejectBP];
    offers = [1:6, 1:6]';

    UGT = table(meanRejections, sdRejections, semRejections, offers, group);

    % save
    writetable(UGT, fullfile(rootDir,'data', 'processed','ultimatum_game_offer_average.csv'));

    %% mean rejection per subject
    clear group
    group = strings(length(mReject),1); %#ok<*UNRCH>
    group(idxHC) = 'HC';
    group(idxBP) = 'BPD';
    data = mReject';
    UGTM = table(data, group);
    writetable(UGTM, fullfile(rootDir, 'data', 'processed','ultimatum_game_subject_average.csv'));

end

%% Results table

labels = ["mBPD", "sdBPD", "nBPD", "mHC", "sdHC", "nHC", "t", "df", "CIL", "CIU", "p1", "z", "p2"];

data = round([mBP, sdBP, nBP, mHC, sdHC, nHC, ...
    ttWelch.tstats.tstat, ttWelch.tstats.df, ttWelch.CI(1), ttWelch.CI(2), ttWelch.P, ...
    ttRank.tstats.zval, ttRank.P], 3);

T = array2table(data, "VariableNames", labels, "RowNames", "UG");

% save table
if saveResults
    writetable(T, fullfile(rootDir, "results/results_ultimatum_game.xlsx"))
end