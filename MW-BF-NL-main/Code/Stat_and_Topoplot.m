% Cluster statistics and topographic plot
% 2 and 1: different conditions: MW and BF
% avg: with average across subjects (otherwise: without average across subjects)
% diff: difference between MW and BF (MW - BF)

%% cluster statistics (here is for HFD-MTC, same method for LZC and SampEn, with or without MTC)

load elec1020_neighb.mat
cfg=[];
cfg.method = 'montecarlo';       % use the Monte Carlo Method to calculate the significance probability
cfg.statistic = 'ft_statfun_depsamplesT';% use dependent samples t statistic
cfg.correctm = 'cluster';
cfg.clusteralpha = 0.05;         % alpha level of the sample-specific test statistic that will be used for thresholding
cfg.clusterstatistic = 'maxsum'; % test statistic that will be evaluated under the permutation distribution.
cfg.neighbours = neighbours;     % definition of neighbours
cfg.tail = 0;                    %two-sided test
cfg.clustertail = 0;
cfg.alpha = 0.025;               % alpha level of the permutation test
cfg.numrandomization = 1000;     % number of draws from the permutation distribution

subj = 19;  %<-- to adjust the subject numbers
design = zeros(2,2*subj);
for i = 1:subj
    design(1,i) = i;
end
for i = 1:subj
    design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,(subj+1):2*subj) = 2;
cfg.design   = design;
cfg.uvar     = 1;
cfg.ivar     = 2;

[stat] = ft_timelockstatistics(cfg, TB_GA_wHFD2, TB_GA_wHFD1);

%% topoplot (3 subplots)
cfg = [];
cfg.marker       = 'on';
cfg.markersize   = 1;
cfg.colorbar     = 'yes';
cfg.layout       = 'elec1020.lay';
cfg.style        = 'straight';
cfg.renderer     = 'painters';

figure,
set(gcf,'outerposition',get(0,'screensize'));
% Note, here subplot and topoplot, use the Fieldtrip-20190626 to work (version 2021 has bugs)
subplot(1,3,1)
cfg.zlim   = [1.66 1.8]; % adjust the scale
ft_topoplotER(cfg,TB_GA_wHFD2_avg);
title('MW')

subplot(1,3,2)
cfg.zlim   = [1.66 1.8]; % adjust the scale
ft_topoplotER(cfg,TB_GA_wHFD1_avg);
title('BF')

subplot(1,3,3)
cfg.zlim   = [-0.024  0.024]; % adjust the scale
% note: here plot the cluster together
cfg.highlight          =  'on';
cfg.highlightchannel   = find(stat.negclusterslabelmat==1);
cfg.highlightsymbol    =  '*';
% Or:
% cfg.highlightchannel   =  {'...','...'}; % the channel labels
% Or:
% cfg.highlightchannel   = find(stat.negclusterslabelmat>0);   % the cluster channel/s
% Or:
% cfg.highlightchannel   = {find(stat.negclusterslabelmat==1), find(stat.negclusterslabelmat==2)}; % select the clusters
% cfg.highlightsymbol    = {'*','v'};        % the empty option will be defaulted
% Can use symbols: '+' | 'o' | '*' | '.' | 'x' | 'square' | 'diamond' | 'v' | '^' | '>' | '<' | 'pentagram' | 'hexagram' | 'none'
cfg.highlightsize      = 10;
ft_topoplotER(cfg, TB_GA_wHFD_diff_avg);
title('Diff')

%% calculate cluster values
sigchan = find(stat.negclusterslabelmat==1);
bothcond = [mean(TB_GA_wHFD2.individual(:,sigchan),2), mean(TB_GA_wHFD1.individual(:,sigchan),2)];

bothmean = mean(bothcond,1);
bothstd2 = std(bothcond);
bothmedian = median(bothcond,1);




