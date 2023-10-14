
% Calculate grand average values
% 2 and 1: different conditions: MW and BF
% avg: with average across subjects (otherwise: without average across subjects)
% diff: difference between MW and BF (MW - BF)

cd '/MATLAB Drive/data/MW-BF-NL-main/Code';
addpath('/MATLAB Drive/data/MW-BF-NL-main/Code/');

%disp(ch);

% Define the desired cell sizes
cellRows = size(confidence,1); % Each cell is 1 row high
cellColumns = size(confidence,2);      % Each cell is 40 columns wide

confidence_levels_rejected = cell(1,cellRows);
for i = 1:cellRows
    % Extract the i-th row and store it in a cell
    confidence_levels_rejected{i} = confidence(i, :);
end


%% Done and saved
[GA_wHFD1, GA_wHFD1_avg, GA_wHFD2, GA_wHFD2_avg, GA_wHFD_diff_avg] = calc_NL_matrix(allsub_alltrial_eachChan_HFD,condition_index_rejected,confidence_levels_rejected);
[TB_GA_wHFD1, TB_GA_wHFD1_avg, TB_GA_wHFD2, TB_GA_wHFD2_avg, TB_GA_wHFD_diff_avg] = calc_NL_matrix_TB(allsub_alltrial_eachChan_HFD,condition_index_rejected,confidence_levels_rejected);

%% Done and saved
[GA_wLZC1, GA_wLZC1_avg, GA_wLZC2, GA_wLZC2_avg, GA_wLZC_diff_avg] = calc_NL_matrix(allsub_alltrial_eachChan_LZC,condition_index_rejected,confidence_levels_rejected);
[TB_GA_wLZC1, TB_GA_wLZC1_avg, TB_GA_wLZC2, TB_GA_wLZC2_avg, TB_GA_wLZC_diff_avg] = calc_NL_matrix_TB(allsub_alltrial_eachChan_LZC,condition_index_rejected,confidence_levels_rejected);

%% Done and saved
[GA_wSampEn1, GA_wSampEn1_avg, GA_wSampEn2, GA_wSampEn2_avg, GA_wSampEn_diff_avg] = calc_NL_matrix(allsub_alltrial_eachChan_SampEn,condition_index_rejected,confidence_levels_rejected);
[TB_GA_wSampEn1, TB_GA_wSampEn1_avg, TB_GA_wSampEn2, TB_GA_wSampEn2_avg, TB_GA_wSampEn_diff_avg] = calc_NL_matrix_TB(allsub_alltrial_eachChan_SampEn,condition_index_rejected,confidence_levels_rejected);


