%go to permutation stats folder
cd 'permutation stats'

%put data in a fieltrip-friendly structure
[Data1,layout]=convertDatatoFieldtrip3(absolute_amplitude_mw,1); 
[Data2,layout]=convertDatatoFieldtrip3(absolute_amplitude_bf,2);

%parameters definition
cfg=[];
cfg.method        = 'triangulation';
cfg.layout =layout;
neighbours = ft_prepare_neighbours(cfg);

cfg.method = 'montecarlo';       % use the Monte Carlo Method to calculate the significance probability
cfg.statistic = 'ft_statfun_depsamplesT';% use dependent samples t statistic
cfg.correctm = 'cluster';
cfg.clusteralpha = 0.05;         % alpha level of the sample-specific test statistic that will be used for thresholding
cfg.clusterstatistic = 'maxsum'; % test statistic that will be evaluated under the permutation distribution.
cfg.neighbours = neighbours;   % definition of neighbours
cfg.tail = 0;                    %two-sided test
cfg.clustertail = 0;
cfg.alpha = 0.025;               % alpha level of the permutation test
cfg.numrandomization = 1000;      % number of draws from the permutation distribution

%define design matrix
nsubj=size(Data1.trial,2);
cfg.design(1,:) = [1:nsubj 1:nsubj];
cfg.design(2,:) = [ones(1,nsubj)*1 ones(1,nsubj)*2];
cfg.uvar        = 1; % row of design matrix that contains unit variable (in this case: subjects)
cfg.ivar        = 2; % row of design matrix that contains independent variable (the conditions)


[stat] = ft_timelockstatistics(cfg, Data1, Data2);




