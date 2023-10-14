%load weights per epoch and condition index with rejected epochs applied

addpath('/MATLAB Drive/data/OSF Storage/MATLAB scripts');
addpath('/MATLAB Drive/data/OSF Storage/Other files');
addpath('/MATLAB Drive/data/OSF Storage/Raw data/EEG');
addpath(genpath('/MATLAB Add-Ons/Collections/EEGLAB/functions'));
addpath('/MATLAB Drive/data/libraries/firfilt');
addpath('/MATLAB Drive/data/libraries/clean_rawdata');


load('/MATLAB Drive/data/OSF Storage/Other files/weights_per_epoch_after_rejection.mat')

%go to folder with clean data
cd '/MATLAB Drive/data/results/reject_components/'


%load list of files
sbj = dir('/MATLAB Drive/data/results/reject_components/*mat');

% stfft
window = 512; %1 second
noverlap = 461; %overlap
freq = 4:0.1:14; %frequencies
fs = 512; %sampling rate

%create matrices for alpha and theta peaks
%subject trial electrode withintrialtimepoint
alpha_peaks = nan(25, 40, 19,40);
theta_peaks = nan(25, 40, 19,40);

%for mean alpha theta peak
alpha_peak = nan(25, 40, 19);
theta_peak = nan(25, 40, 19);
%possible ratios you want to take into account
temp = 1.1:0.1:3.4;
possible_ratios = unique(temp);

%load 1/f estimation (matlab file created from estimate_1f.m)
load('robust_estimation_1f_per_electrodeandsubject_excl_alpha')


for s = 1:size(sbj,1) %loop subject
    clearvars OUTEEG_clean
    load(sbj(s).name) %load file
    disp(sbj(s).name);
    for ti = 1:size (OUTEEG_clean.data,3) %loop trials
        for e = 1:19 %loop electrodes
            %run stfft
            temp = OUTEEG_clean.data(e,:,ti);
            [spectrum,~,~] = spectrogram(temp,window,noverlap,freq,fs);
            data_fft = abs(spectrum);
           
            %create temporal vars for transient peaks
            alpha_peaks = nan(1,size(data_fft,2));
            theta_peaks = nan(1,size(data_fft,2));
            %delete temporal vars from previous loop
            clearvars nmb_alpha_peaks  nmb_theta_peaks
            for tp = 1:size(data_fft,2) %loop time points within epoch
                %extract the 1/f
                 data_fft2 = data_fft(:,tp)' - power_1f_theta_alpha_range{s,e};
                %estimate peaks
                [pks,locs] = findpeaks(data_fft2,freq, 'MinPeakHeight',0);
                %estimate number of alpha and theta peaks
                nmb_alpha_peaks(tp)= length(pks(locs>8));
                nmb_theta_peaks(tp) = length(pks(locs<8));
                 
                alpha_max = max(pks(locs>8)); %maximum alpha peak amplitude
                theta_max = max(pks(locs<8));%maximum theta peak amplitude
                %estimate alpha and theta peaks and put nans if empty
                if isempty(alpha_max)==0
                    alpha_peaks(tp) = locs(pks==alpha_max);
                else
                    alpha_peaks(tp) = nan;
                end
                if isempty(theta_max)==0
                    theta_peaks(tp)= locs(pks==theta_max);
                else
                    theta_peaks(tp)= nan;
                end
                
            end
            
            %estimate percentage of 0, 1 or >1 peaks per trial
            peak_alpha_1(s,ti,e) = length(find(nmb_alpha_peaks==1)) / size(data_fft,2) * 100;
            peak_alpha_0(s,ti,e) = length(find(nmb_alpha_peaks==0)) / size(data_fft,2) * 100;
            peak_alpha_plus1(s,ti,e) = length(find(nmb_alpha_peaks>1)) / size(data_fft,2) * 100;
            
            peak_theta_1(s,ti,e) = length(find(nmb_theta_peaks==1)) / size(data_fft,2) * 100;
            peak_theta_0(s,ti,e) = length(find(nmb_theta_peaks==0)) / size(data_fft,2) * 100;
            peak_theta_plus1(s,ti,e) = length(find(nmb_theta_peaks>1)) / size(data_fft,2) * 100;
            
  
            %estimate frequency of detected peaks
            alpha_peak(s,ti,e) = nanmean(alpha_peaks,2);
            theta_peak(s,ti,e) = nanmean(theta_peaks,2);
            
            %estimate % of each ratio
            ratios = round(squeeze(alpha_peaks./theta_peaks),1);%estimate ratios per time point (temporal variable)
            for r = 1:length(possible_ratios)% loop all ratios
                ratio_temp = possible_ratios(r);%specific ratio
                percentage_ratio{r}(s,ti,e) = sum(ratios==round(ratio_temp,1),2)./size(data_fft,2) * 100; %percentage of each ratio in 2s
            end
            
        end
    end
    
end

% divide conditions and perform weighted average
%for mean alpha/theta peak
for s = 1:25
    disp(s);
    for e = 1:19
        alpha_peak_bf(s,e) =  wmean(squeeze(alpha_peak(s, condition_index_rejected{s}==1,e)), weights{s}(condition_index_rejected{s}==1));
        alpha_peak_mw(s,e) =  wmean(squeeze(alpha_peak(s, condition_index_rejected{s}==2,e)), weights{s}(condition_index_rejected{s}==2));
        theta_peak_bf(s,e) =  wmean(squeeze(theta_peak(s, condition_index_rejected{s}==1,e)), weights{s}(condition_index_rejected{s}==1));
        theta_peak_mw(s,e) =  wmean(squeeze(theta_peak(s, condition_index_rejected{s}==2,e)), weights{s}(condition_index_rejected{s}==2));
        
    end
end

%for % of each ratio
for r = 1:size(possible_ratios,2)
    disp(r);
    for s = 1:25
        for e = 1:19
            percentage_ratio_bf{r}(s,e) = wmean(percentage_ratio{r}(s, condition_index_rejected{s}==1,e), weights{s}(condition_index_rejected{s}==1));
            percentage_ratio_mw{r}(s,e) = wmean(percentage_ratio{r}(s, condition_index_rejected{s}==2,e), weights{s}(condition_index_rejected{s}==2));
            
        end
    end
end



% percentage of 0,1 or >1 detected peaks
for s = 1:25
    disp(s);
    peak_alpha_1_bf(s,:) = squeeze(mean(peak_alpha_1(s, condition_index_rejected{s}==1,:),2))';
    peak_alpha_0_bf(s,:) = squeeze(mean(peak_alpha_0(s, condition_index_rejected{s}==1,:),2))';
    peak_alpha_plus1_bf(s,:) = squeeze(mean(peak_alpha_plus1(s, condition_index_rejected{s}==1,:),2))';

    peak_alpha_1_mw(s,:) = squeeze(mean(peak_alpha_1(s, condition_index_rejected{s}==2,:),2))';
    peak_alpha_0_mw(s,:) = squeeze(mean(peak_alpha_0(s, condition_index_rejected{s}==2,:),2))';
    peak_alpha_plus1_mw(s,:) = squeeze(mean(peak_alpha_plus1(s, condition_index_rejected{s}==2,:),2))';

    peak_theta_1_bf(s,:) = squeeze(mean(peak_theta_1(s, condition_index_rejected{s}==1,:),2))';
    peak_theta_0_bf(s,:) = squeeze(mean(peak_theta_0(s, condition_index_rejected{s}==1,:),2))';
    peak_thsbj(s).nameeta_plus1_bf(s,:) = squeeze(mean(peak_theta_plus1(s, condition_index_rejected{s}==1,:),2))';

    peak_theta_1_mw(s,:) = squeeze(mean(peak_theta_1(s, condition_index_rejected{s}==2,:),2))';
    peak_theta_0_mw(s,:) = squeeze(mean(peak_theta_0(s, condition_index_rejected{s}==2,:),2))';
    peak_theta_plus1_mw(s,:) = squeeze(mean(peak_theta_plus1(s, condition_index_rejected{s}==2,:),2))';

end