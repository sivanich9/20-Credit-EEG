function [TB_GA1, TB_GA1_avg, TB_GA2, TB_GA2_avg, TB_GA_diff_avg] = calc_NL_matrix_TB(OriData,condition_index_rejected,confidence_levels_rejected)

% calc_NL_matrix_TB: NL-nonlinear; TB-trial balanced (MTC: matched trial count)
% load  condition and confidence data
%load condition_index_and_confidence_levels.mat ;

addpath('/MATLAB Drive/data/libraries/fieldtrip/');

% 1st:  calc weighted matrix:
weighted_Data1 = NaN(19,25); % Dim1: breath focus;  for 25 subs
weighted_Data2 = NaN(19,25); % Dim2: mind wandering;  for 25 subs

for sub=1:25  % 25 subs
    % for matched trial count:
    tr01 =find(condition_index_rejected{1,sub} == 1);
    tr02 =find(condition_index_rejected{1,sub} == 2);
    tcount=min(length(tr01),length(tr02));
    alltcount(sub,1)=tcount;
    tr_new_1= randsample(tr01,tcount);
    tr_new_2= randsample(tr02,tcount);
    
    % to average trials per condition (weighted by confidence); 
    % the function wmean is from file exchange: y = sum(w.*x,dim)./sum(w,dim);
    weighted_Data1(:,sub) = wmean(OriData{1,sub}(:,tr_new_1), repmat(confidence_levels_rejected{1,sub}(:,tr_new_1),[19 1]), 2);
    weighted_Data2(:,sub) = wmean(OriData{1,sub}(:,tr_new_2), repmat(confidence_levels_rejected{1,sub}(:,tr_new_2),[19 1]), 2);
end

% 2nd: convert weighted matrix to fieldtrip format:
[TB_GA1, TB_GA1_avg] = calc_NL_matrix_FTformat_TB(weighted_Data1, alltcount);
[TB_GA2, TB_GA2_avg] = calc_NL_matrix_FTformat_TB(weighted_Data2, alltcount);

% calculate the difference :
% NOTE:  diff = MW - BF ---- (2-1)
cfg=[];
cfg.operation='subtract';
cfg.parameter = 'avg';
TB_GA_diff_avg = ft_math(cfg, TB_GA2_avg, TB_GA1_avg); % note: "2" first


% sub-function
function [TB_GA, TB_GA_avg] = calc_NL_matrix_FTformat_TB(weighted_Data, atc) 
% atc is alltcount

addpath('/MATLAB Drive/data/MW-BF-NL-main/Template/');
load electrode19.mat ;
total=cell(1,19);
lesssub=find(atc>10);
for sub=1:19
    tempdata = [];
    tempdata.time = 0;
    tempdata.label = electrode19;
    tempdata.avg = weighted_Data(:,lesssub(sub));
    tempdata.dimord = 'chan_time';
    total{1,sub} = tempdata;
    clear tempdata;
end
cfg=[];
cfg.keepindividual = 'yes'; % should use 'yes'!
TB_GA = ft_timelockgrandaverage(cfg, total{:});   
cfg=[];
cfg.keepindividual = 'no'; %

TB_GA_avg = ft_timelockgrandaverage(cfg, total{:});