

%% run this script per participant to plot components
% clear
 %choose files (from 1 to 25)

%path to save clean data in matlab format
cd '/MATLAB Drive/data/results/reject_components/'

addpath('/MATLAB Drive/data/OSF Storage/MATLAB scripts');
addpath('/MATLAB Drive/data/OSF Storage/Other files');
addpath('/MATLAB Drive/data/OSF Storage/Raw data/EEG');
addpath(genpath('/MATLAB Add-Ons/Collections/EEGLAB/functions'));
addpath('/MATLAB Drive/data/libraries/firfilt');
addpath('/MATLAB Drive/data/libraries/clean_rawdata')

%load mat files of behavioral data 
% load('')
%assign path of eeg and eog folder (where saved EEG and EOG data are)
path_eeg = '/MATLAB Drive/data/results/read_preprocess_and_epoch_EEG/';
path_eog = '/MATLAB Drive/data/results/read_preprocess_and_epoch_EOG/';

for s = 1:size(sbj,1)
%for s = 1:1
    
    %get name of participant
    name = sbj(s).name;
    %disp(name);
    
    %load EEG
    load(strcat(path_eeg,name,'.mat'))

    %load corresponding EOG
    split_1 = strsplit(name,'_');
    split_2 = strsplit(split_1{3},'.');
    name_eog = strcat(split_2{1},'_', split_1{1},split_1{2},'.txt'); 

    %disp(name_eog);
    load(strcat(path_eog,name_eog,'.mat'))

    %exclude epochs from EOG (the ones excluded from EEG)
    index = OUTEEG.reject.rejthresh==0;
    OUTEEG_eog.data = OUTEEG_eog.data(:,:,index);

    OUTEEG.icachansind = 1:21;
    %plotting all components
     %pop_topoplot(OUTEEG,0)  %click ok when pop up come after running file

    %concatenate epochs of eog
     eog_conc = reshape(OUTEEG_eog.data, size(OUTEEG_eog.data,1), size(OUTEEG_eog.data,2)*size(OUTEEG_eog.data,3));
    %disp(eog_conc)

     %correlate eog with components
    [r,p] = corr(OUTEEG.icaact',eog_conc');
    %If you see OUTEEG.icaweights, we can observe that it has 20 ica
    %components. When you select a component and put row number in below
    %statement that component has been deleted.

    %% select component to reject
    rejected_ica = [1]; %select component to delete

    OUTEEG_clean = pop_subcomp(OUTEEG, rejected_ica , 0);


    %check the the correlation with EOG channel went down
     [rvalue_beforeICA,pvalue_beforeICA] = corr(OUTEEG.data(2,:)',eog_conc(1,:)');

     [rvalue_afterICA,pvalue_afterICA] = corr(OUTEEG_clean.data(2,:)',eog_conc(1,:)');


    % plot continous data before and after 
     % plot(OUTEEG.data(1,:))
     % hold on
     % plot(OUTEEG_clean.data(1,:))

    % save matlab file
    save(strcat(name,'.mat'),'OUTEEG_clean','rejected_ica','r','p')
    % disp("saved")

end

