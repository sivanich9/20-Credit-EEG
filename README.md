# 20-Credit-EEG

Download the following codes from github and add each folder in libraries(create it) folder

1. https://github.com/widmann/firfilt/tree/master
2. https://github.com/sccn/clean_rawdata/tree/master
3. https://github.com/fieldtrip/fieldtrip

main files are in /OSF storage/MATLAB scripts/

Raw EEG data can be found here: https://osf.io/b6rn9/.

Order of matlab files to run in MATLAB online editor(/OSF storage/MATLAB scripts/)

1. exp_read_preprocess_and_epoch_EEG.m
2. exp_read_preprocess_and_epoch_EOG.m
3. exp_get_behavioral_data.m
4. exp_reject_components.m
5. exp_amplitude_and_psd.m
6. exp_adding_labels_for_classification.m

Instead of doing average of all electrodes, we can select particular electrodes and average them. We implemented the same but because of GPU issues, we are not able to run files. If you want to run those files also, follow the above order till exp_reject_components.m(including this file) and then run

7. exp_combinations_electrodes_psd.m
8. exp_adding_labels_combinations_for_classification.m
 

Later save the workspace. Workspaces are in https://drive.google.com/drive/folders/1QfRXZdpKXPldAwgzWF75BLz99X3y3tsM?usp=sharing

Add these workspaces files in /OSF storage/MATLAB scripts/ when running in matlab.

Workspaces order

1. exp_after_rejected_components.mat is created after running the file exp_reject_components.m(Save workspace after running the file exp_reject_components.m and name it as exp_after_rejected_components.mat)similarly
2. exp_after_amp_and_psd_for_classification.mat is created after running the file exp_amplitude_and_psd.m
3. exp_for_classification_workspace.mat is created after running the file exp_adding_labels_for_classification.m
4. exp_preprocess_workspace.mat is created after running all the files thar are in OSF storage/MATLAB scripts

after running the file exp_adding_labels_for_classification.m, avg_psd_data_label.csv is created in results folder. This file is used for machine learning classification.

Code for classification is in file "nonlinear-eeg-bf-mw-classification.ipynb"

Order to run all preprocess files(Not required for our project. It is for this who wanted to see results of author's work)

1. exp_read_preprocess_and_epoch_EEG.m
2. exp_read_preprocess_and_epoch_EOG.m
3. exp_get_behavioral_data.m
4. exp_reject_components.m
5. exp_amplitude_analysis.m
6. exp_estimate_1f.m   (upto here is enough to run algo files)
7. exp_findpeaks_analysisnothreshold.m
8. exp_findpeaks_analysis1fthreshold.m
9. exp_IF_and_PLV.m 
10. exp_IF_and_PLV_withfindpeaks.m

After this run algo files in MW_BF-NL-main/Code in the order

1. HFD_eachChan.m (depends on file Higuchi_FD.m)
2. LZC_eachChan.m (depends on files calc_lz_complexity.m and binary_seq_to_string.m)
3. SampEn_eachChan.m (depends on file sampen.m)
4. Grand_avg.m (depends on files calc_NL_matrix.m and calc_NL_matrix_TB.m)
5. Stat_and_Topoplot.m
6. Cate_scat_plot_subject.m (depends on file Categorical_Scatterplot.m)
7. Complexity_with_Power.m
8. Corr_and_Plot.m

Save workspace after running the file SampEn_eachChan.m and name it as hfz_lzc_saen_workspace.mat
