%% IF and PLV adding peak detection

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

%load file list
sbj = dir('/MATLAB Drive/data/results/reject_components/*mat');


% stfft parameters
window = 512; %1 second
noverlap = 461; %overlap
freq = 4:0.1:14; %frequencies
fs = 512; %sampling rate

%load 1/f estimation 
%load('robust_estimation_1f_per_electrodeandsubject_excl_alpha')

%possible ratios
temp = 1:0.1:3.5;
possible_ratios = round(unique(temp),1);

%more parameters
EEG.srate = 512; %samplign rate
ny = EEG.srate/2; %Nyquist
ms = 300; %ms of time window
time_window = ms/1000*EEG.srate; % convert samples

%create output variables
percentage= nan(25,40,19, size(possible_ratios,2)); %subject*trial*electrode*ratio
%subject*trial*electrode
mean_alpha = nan(25,40,19); 
mean_theta = nan(25,40,19); 
coh2 = nan(25,40,19); 
coh3 = nan(25,40,19); 



for s = 1:size(sbj,1) %loop subject
    clearvars OUTEEG_clean
    load(sbj(s).name) %load file
    disp(sbj(s).name);
    for t = 1:size (OUTEEG_clean.data,3) %loop trials
        for e = 1:19 %loop electrodes
     temp = OUTEEG_clean.data(e,:,t); %load time series of trial
          
     %check if there are alpha and theta peaks in the mean spectrum of the trial
     [spectrum,~,~] = spectrogram(temp,window,noverlap,freq,fs);
     data_fft = mean(abs(spectrum),2);
     
     %subtract 1/f
     data_fft = data_fft' - power_1f_theta_alpha_range{s,e};
              
     %findpeaks
     [pks,locs] = findpeaks(data_fft,freq, 'MinPeakHeight',0);

     temp_a = double(~isempty(find(locs>8)));
     temp_t = double(~isempty(find(locs<8)));
     
     if temp_a + temp_t ==2 %if there is at least a peak in alpha and theta

            %filter theta
            %filter order is three times the lower filter bound
            filt_order     = round(3*(EEG.srate/4));
            filterweights  = fir1(filt_order,[4 8]./ny);
            % this part does the actual filtering
            theta_filtered =  filtfilt(filterweights,1,temp);
            
            %filter alpha
            %filter order is three times the lower filter bound
            filt_order     = round(3*(EEG.srate/8));
            filterweights  = fir1(filt_order,[8 14]./ny);
            % this part does the actual filtering
            alpha_filtered =  filtfilt(filterweights,1,temp);
            
            
            %estimate angles from hilbert transform
            angles_alpha = angle(hilbert(alpha_filtered));
            angles_theta = angle(hilbert(theta_filtered));
            
            
            %estimate PLV in sliding window
            %difference phase
            diff_phase2 = (2*(unwrap(angles_theta))) - unwrap(angles_alpha);
            diff_phase3 = (3*(unwrap(angles_theta))) - unwrap(angles_alpha);
            clearvars phase_coher2 phase_coher3 exclude
            %we exclude beggining and end of epoch (~ 150 ms in each side)
            for ti = round(time_window)+1:round(size(diff_phase2,2)-(time_window)) %loop for sliding window, start/finish in start+time_window/2 and end-time_window/2
                %estimate PLV in sliding window
                phase_coher2(ti) = abs(mean(exp(1i*diff_phase2(ti-round(time_window/2):ti+round(time_window/2)))));
                phase_coher3(ti) = abs(mean(exp(1i*diff_phase3(ti-round(time_window/2):ti+round(time_window/2)))));
            end
            
            %average PLV
            coh2(s,t,e) = mean(phase_coher2);
            coh3(s,t,e)= mean(phase_coher3);

            %instantaneous frequency estimation (see Cohen 2014)
           freqslide_prefilt_alpha = diff(EEG.srate*unwrap(angles_alpha))/(2*pi);
           freqslide_prefilt_theta = diff(EEG.srate*unwrap(angles_theta))/(2*pi);
           
           % apply median filter to inst frequency
           orders = round(linspace(EEG.srate*0.01,EEG.srate*0.4,10));% recommended: 10 steps between 10 and 400 ms
           aphasemed = cell(length(orders),1);
           tphasemed = cell(length(orders),1);
           for oi=1:length(orders)%loop steps
               aphasemed{oi,1}= medfilt1(freqslide_prefilt_alpha,orders(oi));
               tphasemed{oi,1}= medfilt1(freqslide_prefilt_theta,orders(oi));
           end
          %median of medians 
           freqslide_filt_alpha = median(cell2mat(aphasemed),1);
           freqslide_filt_theta = median(cell2mat(tphasemed),1);
           ratios = round(freqslide_filt_alpha./freqslide_filt_theta,1);
           
           %estimate mean alpha and theta
           mean_alpha(s,t,e) =  mean(nonzeros(freqslide_filt_alpha));
           mean_theta(s,t,e) =  mean(nonzeros(freqslide_filt_theta));
           
           %now estimate percentage of each ratio
           for r = 1:length(possible_ratios)% loop all ratios
               ratio = possible_ratios(r);%specific ratio
               percentage_ratio(s,t,e,r) = sum(ratios==round(ratio,1),2)/size(ratios,2) * 100;
           end
            
     else %if no peaks were detected exclude trial
     mean_alpha(s,t,e) = nan; 
     mean_theta(s,t,e) = nan;
     percentage_ratio(s,t,e,:) = nan;
     coh2(s,t,e) = nan;
     coh3(s,t,e)= nan;
            
     end
     
     
        end
    end
end


% weighted average of trials 
% we exclude nans in the case of mean peaks and coherence (which are rejected epochs)

% %weighted average of perc ratio
for r = 1:size(possible_ratios,2) %for each ratio
    disp(r);
    for s = 1:25%sbj
        for e = 1:19%electrode
            
            
            %little fix in case there is no peaks in a trial
            %get weights
            w1 = weights{s}(condition_index_rejected{s}==1);
            w2 = weights{s}(condition_index_rejected{s}==2);
            %get variable
            a1 = percentage_ratio(s,condition_index_rejected{s}==1,e,r);
            a2 = percentage_ratio(s,condition_index_rejected{s}==2,e,r);
            %delete nans in weights  based on 1 variable ( the
            %same trials are excluded for all variables) so weights don't
            %have to be updated for each variable
            w1 = w1(~isnan(a1));
            w2 = w2(~isnan(a2));
            
            if ~isempty(w1) && ~isempty(w2) %estimate vars only if there are peaks (i.e. weights are not empty)
                
                %delete nans in variable
                a1 = a1(~isnan(a1));
                a2 = a2(~isnan(a2));
                %estimae variable
                percentage_ratio_bf{r}(s,e) = wmean(a1,w1);
                percentage_ratio_mw{r}(s,e) = wmean(a2,w2);
            else %put nans in subject and electrodes without usable trials
                percentage_ratio_bf{r}(s,e) = nan;
                percentage_ratio_mw{r}(s,e) = nan;
                
                
            end
            
        end
    end
end



mean_alpha_peak_bf = nan(25,19);
mean_alpha_peak_mw = nan(25,19);
mean_theta_peak_bf = nan(25,19);
mean_theta_peak_mw = nan(25,19);
coh2_bf  = nan(25,19);
coh2_mw = nan(25,19);
coh3_bf  = nan(25,19);
coh3_mw = nan(25,19);
no_trials_bf= nan(25,19);
no_trials_mw= nan(25,19);
%weighted average mean alpha/theta and coherence
for s = 1:25%sbj
    disp(s);
    for e = 1:19%electrode
        
         %little fix in case there is no peaks in a trial
            %get weights
            w1 = weights{s}(condition_index_rejected{s}==1);
            w2 = weights{s}(condition_index_rejected{s}==2);
            %get variable 
            a1 = mean_alpha(s,condition_index_rejected{s}==1,e);
            a2 = mean_alpha(s,condition_index_rejected{s}==2,e);
            %delete nans in weights  based on 1 variable ( the
            %same trials are excluded for all variables) so weights don't
            %have to be updated for each variable
            w1 = w1(~isnan(a1));
            w2 = w2(~isnan(a2));
            
            if ~isempty(w1) %estimate vars only if there are peaks (i.e. weights are not empty)
            if ~isempty(w2)
            %save number of trials per condition electrode and subject
            no_trials_bf(s,e) = size(w1,2);
            no_trials_mw(s,e) = size(w2,2);
            
            %delete nans in variable
            a1 = a1(~isnan(a1));
            a2 = a2(~isnan(a2));
            %estimate variable
            mean_alpha_peak_bf(s,e) = wmean(a1,w1);
            mean_alpha_peak_mw(s,e) = wmean(a2,w2);
            
            
            %same procedure for other vars
            %get temporal variable 
            a1 = mean_theta(s,condition_index_rejected{s}==1,e);
            a2 = mean_theta(s,condition_index_rejected{s}==2,e);
            %delete nans in variable
            a1 = a1(~isnan(a1));
            a2 = a2(~isnan(a2));
            %estimate variable
            mean_theta_peak_bf(s,e) = wmean(a1,w1);
            mean_theta_peak_mw(s,e) = wmean(a2,w2);
            
             %get temporal variable 
            a1 = coh2(s,condition_index_rejected{s}==1,e);
            a2 = coh2(s,condition_index_rejected{s}==2,e);
            %delete nans in variable
            a1 = a1(~isnan(a1));
            a2 = a2(~isnan(a2));
            %estimate variable
            coh2_bf(s,e) = wmean(a1,w1);
            coh2_mw(s,e) = wmean(a2,w2);
           
            %get temporal variable 
            a1 = coh3(s,condition_index_rejected{s}==1,e);
            a2 = coh3(s,condition_index_rejected{s}==2,e);
            %delete nans in variable
            a1 = a1(~isnan(a1));
            a2 = a2(~isnan(a2));
            %estimate variable
            coh3_bf(s,e) = wmean(a1,w1);
            coh3_mw(s,e) = wmean(a2,w2);
           
            end
            end
        
   end
end

