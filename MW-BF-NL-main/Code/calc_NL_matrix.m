function [GA1, GA1_avg, GA2, GA2_avg, GA_diff_avg] = calc_NL_matrix(OriData,condition_index_rejected,confidence_levels_rejected)

% calc_NL_matrix: NL-nonlinear
% load  condition and confidence data
%load condition_index_and_confidence_levels.mat ;

%disp(ch);

addpath('/MATLAB Drive/data/libraries/fieldtrip/');

% 1st:  calc weighted matrix:
weighted_Data1 = NaN(19,25); % Dim1: breath focus;  for 25 subs
weighted_Data2 = NaN(19,25); % Dim2: mind wandering;  for 25 subs

%list of matlab files
subj = dir('/MATLAB Drive/data/results/reject_components/*mat');

for sub=1:size(subj,1)
    %disp(sub);
    tr1 =find(condition_index_rejected{1,sub} == 1);
    %disp(tr1);
    tr2 =find(condition_index_rejected{1,sub} == 2);
    
    % to average trials per condition (weighted by confidence);
    % the function wmean is from file exchange: y = sum(w.*x,dim)./sum(w,dim);
    weighted_Data1(:,sub) = wmean(OriData{1,sub}(:,tr1), repmat(confidence_levels_rejected{1,sub}(:,tr1),[19 1]), 2);
    weighted_Data2(:,sub) = wmean(OriData{1,sub}(:,tr2), repmat(confidence_levels_rejected{1,sub}(:,tr2),[19 1]), 2);
end

% 2nd: convert weighted matrix to fieldtrip format:
[GA1, GA1_avg] = calc_NL_matrix_FTformat(weighted_Data1);
[GA2, GA2_avg] = calc_NL_matrix_FTformat(weighted_Data2);

% calculate the differenve :
% NOTE:  diff = MW - BF ---- (2-1)
cfg=[];
cfg.operation='subtract';
cfg.parameter = 'avg';
GA_diff_avg = ft_math(cfg, GA2_avg, GA1_avg); % note: "2" first


% sub-function
function [GA, GA_avg] = calc_NL_matrix_FTformat(weighted_Data)
addpath('/MATLAB Drive/data/MW-BF-NL-main/Template/');
load electrode19.mat ;
total=cell(1,25);
for sub=1:25
    tempdata = [];
    tempdata.time = 0;
    tempdata.label = electrode19;
    tempdata.avg = weighted_Data(:,sub);
    tempdata.dimord = 'chan_time';
    total{1,sub} = tempdata;
    clear tempdata;
end
cfg=[];
cfg.keepindividual = 'yes'; % should use 'yes'!
GA = ft_timelockgrandaverage(cfg, total{:});   
cfg=[];
cfg.keepindividual = 'no'; %
GA_avg = ft_timelockgrandaverage(cfg, total{:});