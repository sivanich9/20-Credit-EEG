
%% all analysis (for 19chan together)  -- need the 'condition_index' and 'sbj'
%load condition_index_and_confidence_levels.mat  %
%% for Sample entropy (calculate each channel )

cd '/MATLAB Drive/data/MW-BF-NL-main/Code';

addpath('/MATLAB Drive/data/results/reject_components/');

allsub_alltrial_eachChan_SampEn = cell(1,25);

%list of matlab files
subj = dir('/MATLAB Drive/data/results/reject_components/*mat');

for sub=1:size(subj,1)
    Subject=(sbj(sub).name);  % to get the subject order from "sbj"
    % loaddata = ['load  ...path\' Subject '.mat']; % load data from the corresponding folder
    % eval(loaddata);
    disp(Subject);
    tr = size(OUTEEG_clean.data,3); %  trial numbers
    SampEnTemp = NaN(19,tr);% 19 channels
    
    for i=1:tr % i = trial index
        for ch=1:19 % each channel
            tempdata = OUTEEG_clean.data(ch,:,i); % 1:19 channels   (Data Could be a raw vector)
            SampEnTemp(ch,i) = sampen(tempdata, 2, 0.2);
        end
    end
    
    allsub_alltrial_eachChan_SampEn{1,sub} = SampEnTemp;
    
    %clear OUTEEG_clean
    
end

save allsub_alltrial_eachChan_SampEn  allsub_alltrial_eachChan_SampEn
