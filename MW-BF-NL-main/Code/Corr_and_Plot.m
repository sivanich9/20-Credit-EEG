
% Correlation analysis and plot for nonlinear results and drowsiness

%% Nonlinear metrics values and drowsiness level, without MTC (non-MTC), for cluster
% sbj-order: [1:16, 18:20, 23:25]
sbj_drow = [1:16, 18:20, 23:25];  % total 22 subjects -- with valid drowsiness level data

% NL Values were from cluster statistics and grand average data:
% (all: MW - BF, i.e., mind wandering - breath focus)
NLdiff_drow(:,1) = HFDdiff(sbj_drow,1);
NLdiff_drow(:,2) = LZCdiff(sbj_drow,1);
NLdiff_drow(:,3) = SENdiff(sbj_drow,1);
drowlevel_drow = drowlevel(sbj_drow,1);

%% Nonlinear metrics values and drowsiness level, with Trial-balanced (MTC), for cluster
% sbj-order: [2,3,4,6,7,9,10,12:16, 18:20, 25];
TB_sbj_drow = [1:12, 14:16, 19]; % total 16 subjects -- with valid drowsiness level data
TB_NLdiff_drow(:,1) = TB_HFDdiff(TB_sbj_drow,1);
TB_NLdiff_drow(:,2) = TB_LZCdiff(TB_sbj_drow,1);
TB_NLdiff_drow(:,3) = TB_SENdiff(TB_sbj_drow,1);
TB_drowlevel_drow = TB_drowlevel(TB_sbj_drow,1);

%% fit and scatter plot, for cluster //  note: here use 'Type'--'Kendall'
% (Here the code is for MTC, same method for non-MTC)

X = TB_drowlevel_drow; % Note: remove the "TB_" for non-MTC
Ylist={ 'TB_ HFDdiff','TB_ LZCdiff', 'TB_ SENdiff'};

figure,
set(gcf,'outerposition',get(0,'screensize')); 
for k=1:3
    
    Ystr=Ylist{k};
    Y = TB_NLdiff_drow(:,k);  % Note: remove the "TB_" for non-MTC
    
    % corr:
    [coef, pval] = corr(X, Y,'Type','Kendall'); % corr is only for column
    p = polyfit(X, Y, 1); % fitted coefficient p
    yFit = polyval(p, X); % estimate fitted Y with X and p.
    
    % plot
    subplot(2,3,k);
    scatter(X, Y, 25,'k','filled');
    hold on
    curve=plot(X,yFit,'k','linewidth',2);
    
    xlabel('TB_ Drowsiness level');  % Note: remove the "TB_" for non-MTC
    ylabel(Ystr);
    xlim([1-0.1*(7-1)  7+0.1*(7-1)]);
    ylim([min(Y)-0.1*(max(Y)-min(Y))  max(Y)+0.1*(max(Y)-min(Y))]);
    title(['Kendall coef tau = ',num2str(coef), ', p = ',num2str(pval)]); hold off
    
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEXT, FOR EACH ELECTRODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Nonlinear metrics values and drowsiness level, without MTC (non-MTC), for each electrode
% sbj-order: [1:16, 18:20, 23:25]
sbj_drow = [1:16, 18:20, 23:25];  % total 22
% Diff: 
% NOTE:  diff = MW - BF ---- (2-1)
% GA Values were from grand average data:
GA_diff = GA_wSampEn2.individual - GA_wSampEn1.individual; % same method for HFD and LZC
NLdiff_drow = GA_diff(sbj_drow,:);   % size: sub * 19elec
drowlevel_drow = drowlevel(sbj_drow,1); % size: sub * 1

%% Nonlinear metrics values and drowsiness level, with MTC (or called Trial-balanced: TB), for each electrode
TB_sbj_drow = [1:12, 14:16, 19]; % total 16
% Diff: 
% NOTE:  diff = MW - BF ---- (2-1)
% GA Values were from grand average data:
GA_diff = TB_GA_wSampEn2.individual - TB_GA_wSampEn1.individual; % same method for HFD and LZC
NLdiff_drow = GA_diff(TB_sbj_drow,:);   % size: sub * 19elec
drowlevel_drow = TB_drowlevel(TB_sbj_drow,1); % size: sub * 1

%% Correlation for each electrode
% note: here use 'Type'--'Kendall'
kendallcoef = NaN(19,1); % tau
kendallpval = NaN(19,1);

X =  drowlevel_drow; % Note: same method for MTC

for k =1:19 %for electrode   
    Y =  NLdiff_drow(:,k);  % Note: same method for MTC
    % corr:
    [kendallcoef(k), kendallpval(k)] = corr(X, Y,'Type','Kendall'); % corr is only for column
    % coef is tau, pval is p
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEXT, FOR ALL ELECTRODES AVERAGE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Correlation for all electrode average
X =  drowlevel_drow; % Note: same method for MTC
Y =  mean(NLdiff_drow,2); % Note: same method for MTC
% corr:
[allcoef, allpval] = corr(X, Y,'Type','Kendall');  

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEXT, CORRELATION BETWEEN NONLINEAR VALUES AND TRIAL NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
Spearmancoef = NaN(25,1); % rho
Spearmanpval = NaN(25,1);

% OriData = allsub_alltrial_eachChan_HFD; % values from complexity analysis
% sigchan = [1:6, 9:19]  ; % for HFD (significant cluster (channels), no-MTC)
% OriData = allsub_alltrial_eachChan_LZC;
% sigchan = [6 10 11 15]  ; % for LZC (significant cluster, no-MTC)
OriData = allsub_alltrial_eachChan_SampEn;
sigchan = [1 3 5 6 10 11 12 16]  ; % for SampEn (significant cluster, no-MTC)
for sub=1:25   % 25 subs
    % select one sub data --> calculate the value in cluster
    meanvalue = mean(OriData{1,sub}(sigchan,:),1);
    % weighted by confidence (use: .*):
    weighted_meanvalue = meanvalue.*confidence{1,sub}/7;
    % spearman corr: (corr with trial number , e.g, 1:40)
    [Spearmancoef(sub,1), Spearmanpval(sub,1)] = corr((1:length(weighted_meanvalue))',weighted_meanvalue','Type','Spearman' ); 
end
% One-sample t-test:
 [h,p,ci,stats] = ttest(Spearmancoef);
 