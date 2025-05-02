function mk_grouped_boxplots(x1, x2, plotTitle, yLabel, pVal, ylimits, xtext, ytext)

x = [x1'; x2'];
group = [ones(length(x1),1); ones(length(x2),1)+1];

% calculate descriptive statistics
meanBPD = round(mean(x1, 'omitnan'), 3);
meanHC = round(mean(x2, 'omitnan'), 3);
sdBPD = round(std(x1, 'omitnan'), 3);
sdHC = round(std(x2, 'omitnan'), 3);
pVal = round(pVal, 3);

if pVal <= 0.005
    pTxt = 'p < 0.005';
elseif pVal <= 0.05
    pTxt = 'p < 0.05';
else
    pTxt = ['p = ' num2str(pVal)];
end

fontSize = 12;

% data for scatter
xS = [{x1'}, {x2'}];
groupS = [{ones(1,length(x1))}, {ones(1,length(x2))+1}];

colHC = [0.2784 0.2549 0.4078];
colBPD = [0.6980 0.1216 0.4000];

colorS = [colBPD; colHC; colBPD; colHC; ]; % for scatter
color = flip(colorS); % for box (patch starts with last box)

% mk figure
figure
boxplot(x, group, 'widths', 0.2)
hold on
h1 = findobj(gca,'Tag','Box');
for j=1:length(h1)
    patch(get(h1(j),'XData'),get(h1(j),'YData'),color(j,:),'FaceAlpha',.99);
    scatter(groupS{j} + 0.2, xS{j}, 'MarkerFaceColor', colorS(j,:), 'MarkerFaceAlpha', 0.3,...
        'MarkerEdgeColor', colorS(j,:), 'jitter', 'on', 'jitterAmount', 0.05);
end
ylim(ylimits)
title(plotTitle)
xlabel('Group','FontSize', fontSize)
ylabel(yLabel,'FontSize', fontSize)
xticklabels({'BPD', 'HC',})

% add pvalue
txt = {['BPD: M = ' num2str(meanBPD), ', SD = ' num2str(sdBPD)];
    ['HC: M = ' num2str(meanHC), ', SD = ' num2str(sdHC)]; ...
    pTxt};
text(xtext,ytext,txt)
hold off