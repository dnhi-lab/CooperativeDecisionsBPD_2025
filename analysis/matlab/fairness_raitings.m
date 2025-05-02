%% Analyse FN (Fairness) Ratings
%
% 2 groups: HC & BPD
% Participants rated fairness of hypothetical allocations raning from 0:10
% in steps of 1 (11 trials)
% Response options from 1 (=totally fair) to 9 (totally unfair) in steps of 1
%==========================================================================

clear; close all

% SET
saveResults = 1;
printFigures = 1;

% set paths
rootDir = setup_paths();

% load data
load("fairness_ratings.mat")


%% ========================================================================
% EXCLUSION CRITERIA
%==========================================================================

subN = length(response);

% we exclude subjects who choose the same choice option more than 90% of
% the trials
criterion = 11 * 0.9;

% count how often each response option was chosen
% rows: choice options from 1:9, row 10 is nans, columns: subjects
% check if one of the options was chosen more than 90% criterion
dataVar = nan(10,subN);
dataVarExcl = nan(1,subN);
for iSub = 1:subN

    for iVal = 1:9 % response from 1:9
        dataVar(iVal,iSub) = sum(response(:,iSub) == iVal);
    end
    % count nans
    dataVar(10,iSub) = sum(isnan(response(:,iSub)));

    % >= than 80% same responses per profile (row) per participant (column)
    dataVarExcl(:,iSub) = sum(dataVar(:,iSub) > criterion);
end


%% ========================================================================
% DESCRIPTIVE STATS
%==========================================================================

ranges = [1,4; % disadvantageous offers 0:3
    5,7;       % fair offers 4:6
    8,11];     % advantageous offers 7:10
condLabels = ["unfair offers (disadvantageous)";
    "fair offers";
    "unfair offers (advantageous)"];

ratingStats = nan(3,4);
for iCon = 1:3

    rangeL = ranges(iCon,1);
    rangeU = ranges(iCon,2);

    % calculate subject-wise mean first
    meanRating = mean(response(rangeL:rangeU, :));
    % then group-wise
    ratingStats(iCon,1) = mean(meanRating(:, idxBP));
    ratingStats(iCon,2) = std(meanRating(:, idxBP));
    ratingStats(iCon,3) = mean(meanRating(:, idxHC));
    ratingStats(iCon,4) = std(meanRating(:, idxHC));

end


%% save descriptive table 

labels = ["condition", "mBPD", "sdBPD", "mHC", "sdHC"];
ratingStats = round(ratingStats,3);
ratingStatsT = array2table(ratingStats);
ratingStatsT = addvars(ratingStatsT, condLabels, 'Before', 'ratingStats1');
ratingStatsT = renamevars(ratingStatsT, 1:5, labels);

% save table
if saveResults
    writetable(ratingStatsT, fullfile(rootDir,"results/results_fairness_ratings.xlsx"))
end

%% Display results

myLine1 = '----------------------------------------------------------------------------------';

disp([myLine1 newline])
display(['Missing data: ' num2str(sum(sum(isnan(response))))]);
disp([myLine1 newline])
display(['Same choice more than 90%: ' num2str(sum(sum(dataVarExcl)))]);
disp([myLine1 newline])

% display table
disp(ratingStatsT);
disp([myLine1 newline])


%% ========================================================================
% FIGURES IMAGESC
%==========================================================================

if printFigures

    colBPD = [0.6980 0.1216 0.4000];
    colHC = [0.2784 0.2549 0.4078];

    labels = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'};

    % barplot
    figure;
    bar(mean(response(:,idxBP), 2), 'FaceColor', colBPD)
    hold on
    bar(mean(response(:,idxHC), 2),'FaceColor', colHC,'FaceAlpha', 0.7)
    legend({'BPD','HC'})
    xlabel('Offer')
    ylabel('Rating')
    title('Fairness Ratings')
    xticklabels(labels)

end

%% ========================================================================
% GLMM
%==========================================================================

% create data table for mixed model
rating = reshape(response, subN*11, 1);
group = idxBP + 1; % now 1=HC, 2=BP
group = repelem(group, 11)';
offer = 0:10;
offer = repmat(offer',size(response,2),1);
subID = 1: length(response);
subID = repelem(subID,11)';

% as table
T = table(subID, group, offer, rating);
T.group = categorical(T.group);
% mean centered offer
T.offerC = T.offer - mean(T.offer);

% fit linear model
FN_formula = 'rating ~ group * offer + (1|subID)';
mdl_1 = fitglme(T, FN_formula);

% Calculate effects sizes: Odds Ratios by converting Log-Odds Ratios
estimates1 = mdl_1.Coefficients.Estimate;
oddsRatios1 = exp(estimates1);

% fit quadratic model
% info about quadratic term & centered variables see
% https://stats.oarc.ucla.edu/other/mult-pkg/faq/general/faqhow-do-i-interpret-the-sign-of-the-quadratic-term-in-a-polynomial-regression/
FN_formula_2 = 'rating ~ group * offerC^2 + (1|subID)';
mdl_2 = fitglme(T, FN_formula_2);
disp(mdl_2)

% Calculate effects sizes: Odds Ratios by converting Log-Odds Ratioss
estimates2 = mdl_2.Coefficients.Estimate;
oddsRatios2 = exp(estimates2);


%% ========================================================================
% SAVE DATA
%==========================================================================

if saveResults

    % save as word doc
    cd(fullfile(rootDir, 'results'))

    % choose model & name
    mdlSave = mdl_2; %#ok<*UNRCH>
    mdlName = "fairness_ratings_quadratic"; % "FN_linear"; 
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
    % Extract model fit statistics
    aic = mdlSave.ModelCriterion.AIC;
    bic = mdlSave.ModelCriterion.BIC;
    logLikelihood = mdlSave.LogLikelihood;
    fit = table(aic, bic, logLikelihood);

    % save text in document
    import mlreportgen.dom.*;
    % Create a new Word document
    doc = Document(docName, 'docx');

    % Add a title to the document
    titleDoc = Paragraph('GLMM Model Results');
    titleDoc.Style = {Bold, FontSize('12pt')};
    append(doc, titleDoc);

    % Model fit
    append(doc, Paragraph());
    append(doc, Paragraph('Model Formula:'));
    append(doc, formattedDisplayText(mdlSave.Formula));

    % Fixed effects
    % Add Odds Ratios to tables
    fixedEffects = addvars(fixedEffects, oddsRatios);
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


    %% Save data for R: summarized data

    meanHC = mean(response(:,idxHC),2);
    sdHC = std(response(:,idxHC),0,2);
    semHC = sdHC / sqrt(sum(idxHC));
    meanBP = mean(response(:,idxBP),2);
    sdBP = std(response(:,idxHC),0,2);
    semBP = sdBP / sqrt(sum(idxBP));

    clear group;
    group = strings(length(meanHC)+length(meanBP),1);
    group(1:11,1) = 'HC';
    group(12:22,1) = 'BPD';

    meanFair = [meanHC; meanBP];
    sdFair = [sdHC; sdBP];
    semFair = [semHC; semBP];
    offers = [0:10, 0:10]';

    FNT = table(meanFair, sdFair, semFair, offers, group);

    % save
    writetable(FNT, fullfile(rootDir, 'data', 'processed','fairness_ratings_offer_average.csv'));

end
