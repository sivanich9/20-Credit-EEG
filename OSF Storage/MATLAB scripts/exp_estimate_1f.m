%% estimation of 1/f trend across trials

%load weights per epoch and condition index with rejected epochs applied
load('/MATLAB Drive/data/OSF Storage/Other files/weights_per_epoch_after_rejection.mat')

%go to folder with clean data
% cd 'G:\PhD KU Leuven\mind wandering experiment\data\eegdata_epoched_rejected_components'
cd '/MATLAB Drive/data/results/reject_components/'

sbj = dir('/MATLAB Drive/data/results/reject_components/*mat');

%stfft
window = 512; %1 second
noverlap = 461; %overlap
freq = 2:0.1:30; %frequencies
fs = 512; %sampling rate


for s = 1:size(sbj,1) %loop subject
    clearvars OUTEEG_clean
    load(sbj(s).name)
    %load(strcat('/MATLAB Drive/osfstorage-archive/rejected_components_results/',sbj(s).name)) %load file
    
        for e = 1:19 %loop electrodes
            %run stfft or wavelet
            temp = squeeze(OUTEEG_clean.data(e,:,:));%select electrode
            temp2 = temp(:); %concatenate epoch
            
            [spectrum,~,~] = spectrogram(temp2,window,noverlap,freq,fs);
            data_fft = mean(abs(spectrum),2);
          
             %exlude alpha range for fitting
            data_fft(find(freq==8):find(freq==14))=nan;
            
            b = robustfit(log10(freq),log10(data_fft));
            pv(1) = b(2);
            pv(2) = b(1);
            power_1f=10.^(polyval(pv,log10(freq))); 
            power_1f_theta_alpha_range{s,e} = power_1f(find(freq==4):find(freq==14));
          




        end
        
end