cd '/MATLAB Drive/data/results/'
addpath('/MATLAB Drive/data/OSF Storage/MATLAB scripts/');
load("exp_after_amp_and_psd_for_classification.mat");

% labels = {'bin1','bin2','bin3','bin4','bin5','bin6','bin7','bin8','bin9','bin10','bin11','bin12','bin13','bin14','bin15','bin16','bin17','bin18','bin19','bin20','bin21','bfmw'};
% 
% row_with_labels = cell(1, 22);
% row_with_labels(1, :) = labels;

avg_psd_value_bf_label = [avg_psd_value_bf,ones(size(avg_psd_value_bf,1),1)];
avg_psd_value_mw_label = [avg_psd_value_mw,2*ones(size(avg_psd_value_mw,1),1)];

avg_psd_data_label = vertcat(avg_psd_value_bf_label,avg_psd_value_mw_label);

output_file = 'avg_psd_data_label.csv';

writematrix(avg_psd_data_label, output_file);

%after this I saved workspace with name
%"exp_for_classification_workspace.mat"
