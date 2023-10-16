%load("exp_after_rejected_components.mat");
%instead of writing above line for load, go to that
%"exp_after_rejected_components.mat" file and double click it automatically
%loads in workspace.


%% This code performs short term fft per epoch and averages across conditions (weighted by confidence)

%load weights per epoch and condition index with rejected epochs applied
load('/MATLAB Drive/data/OSF Storage/Other files/weights_per_epoch_after_rejection.mat')

%go to folder with clean EEG data (after ICA rejection)
cd '/MATLAB Drive/data/results/reject_components/'

addpath('/MATLAB Drive/data/OSF Storage/MATLAB scripts');
addpath('/MATLAB Drive/data/OSF Storage/Other files');
addpath('/MATLAB Drive/data/OSF Storage/Raw data/EEG');
addpath(genpath('/MATLAB Add-Ons/Collections/EEGLAB/functions'));
addpath('/MATLAB Drive/data/libraries/firfilt');
addpath('/MATLAB Drive/data/libraries/clean_rawdata');
addpath('/MATLAB Drive/data/MW-BF-NL-main/Code/');

%list of matlab files
sbj = dir('/MATLAB Drive/data/results/reject_components/*mat');

% short time fft
window = 512; %1 second
noverlap = 461; %90% overlap
freq = 4:0.5:14; %frequencies
fs = 512; %sampling rate

for s = 1:size(sbj,1) %loop subject
%for s = 1:1
    clearvars OUTEEG_clean
    load(sbj(s).name)
    %load(strcat('/MATLAB Drive/osfstorage-archive/rejected_components_results/',sbj(s).name)) %load file
    for ti = 1:size (OUTEEG_clean.data,3) %loop trials
        for e = 1:19 %loop electrodes

            temp = OUTEEG_clean.data(e,:,ti); %data per electrode and trial
            %disp(temp); % temp contains a row in data in OUTEEG.clean
            [spectrum,~,~] = spectrogram(temp,window,noverlap,freq,fs); %short term fft
            [psd,f] = pwelch(temp, window, noverlap, freq, fs);

            %if you check, you can see dimension of relative_amplitude is
            %25x40x19x21 where 25 means no.of subjects, 40 means no.of
            %trails, 19 means no.of electrodes and 21 means no.of frequency
            %bins(freq = 4:0.5:14 (4,4.5,5,5.5,6,6.5.....14) total 21 bins)

            relative_amplitude(s,ti,e,:) = mean(abs(spectrum),2)./ sum(mean(abs(spectrum),2)) .*100;
            absolute_amplitude(s,ti,e,:) = mean(abs(spectrum),2);

            %calucating power spectral density
            psd_value(s,ti,e,:) = psd;

        end
    end



end

% to average trials per condition (weighted by confidence) I use the function wmean from file exchange
for s = 1:size(sbj,1) %loop subject
%for s = 1:1
    %disp("entered2")
    for fr = 1:size(freq,2) %loop frequency
        for e = 1:19 %loop electrode
 
 	    %average trails
            relative_amplitude_bf{fr}(s,e) = wmean(squeeze(relative_amplitude(s,condition_index_rejected{s}==1,e,fr))...
                ,weights{s}(condition_index_rejected{s}==1));

            relative_amplitude_mw{fr}(s,e) = wmean(squeeze(relative_amplitude(s,condition_index_rejected{s}==2,e,fr))...
                ,weights{s}(condition_index_rejected{s}==2));

            absolute_amplitude_bf{fr}(s,e) = wmean(squeeze(absolute_amplitude(s,condition_index_rejected{s}==1,e,fr))...
                ,weights{s}(condition_index_rejected{s}==1));

            absolute_amplitude_mw{fr}(s,e) =   wmean(squeeze(absolute_amplitude(s,condition_index_rejected{s}==2,e,fr))...
                ,weights{s}(condition_index_rejected{s}==2));

            psd_value_bf{fr}(s,e) = wmean(squeeze(psd_value(s,condition_index_rejected{s}==1,e,fr))...
                ,weights{s}(condition_index_rejected{s}==1))

            psd_value_mw{fr}(s,e) = wmean(squeeze(psd_value(s,condition_index_rejected{s}==2,e,fr))...
                ,weights{s}(condition_index_rejected{s}==2))

        end
    end

end


% get average spectrum per subject to plot

%average electrodes
avg_rel_mw = squeeze(mean(reshape(cell2mat(relative_amplitude_mw(:)'),[25 19 21]),2));
avg_rel_bf = squeeze(mean(reshape(cell2mat(relative_amplitude_bf(:)'),[25 19 21]),2));
avg_abs_mw = squeeze(mean(reshape(cell2mat(absolute_amplitude_mw(:)'),[25 19 21]),2));
avg_abs_bf = squeeze(mean(reshape(cell2mat(absolute_amplitude_bf(:)'),[25 19 21]),2));

avg_psd_value_bf = squeeze(mean(reshape(cell2mat(psd_value_bf(:)'),[25 19 21]),2));
avg_psd_value_mw = squeeze(mean(reshape(cell2mat(psd_value_mw(:)'),[25 19 21]),2));
