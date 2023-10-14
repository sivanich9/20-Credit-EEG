
%% plot the values for each subject 
% (here is for HFD-MTC, same method for LZC and SampEn, with or without MTC)

% Values:
sigchan = find(stat.negclusterslabelmat==1);
Y = mean(TB_GA_wHFD2.individual(:,sigchan),2); % y -- MW
X = mean(TB_GA_wHFD1.individual(:,sigchan),2); % x -- BF
plotdata = [Y, X];
mimmin = min(min(X),min(Y));
maxmax = max(max(X),max(Y));

% Plot the values for each subject using the CategoricalScatterplot function:
CategoricalScatterplot(plotdata,'Labels',{'MW','BF'},...
    'spreadWidth',0.25,...   % adjustable
    'boxWidth',0.3,...       % adjustable
    'BoxAlpha',1,...         % Keep BoxAlpha = 1; then the EPS is a vector plot
    'WhiskerLine',false,'BoxColor',[0.9 0.9 0.9],'WhiskerColor',[0.8235 0.7412 0.0392]); % adjustable
xlim([0.3 2.8]);
ylim([mimmin-0.1*(maxmax-mimmin)  maxmax+0.1*(maxmax-mimmin)]);
axis square
box on
