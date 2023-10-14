addpath('/MATLAB Drive/data/OSF Storage/MATLAB scripts');
addpath('/MATLAB Drive/data/OSF Storage/Other files');
addpath('/MATLAB Drive/data/OSF Storage/Raw data/EOG');
addpath(genpath('/MATLAB Add-Ons/Collections/EEGLAB/functions'));
addpath('/MATLAB Drive/data/libraries/firfilt');
addpath('/MATLAB Drive/data/libraries/clean_rawdata');
%define path to save matlab files
path1 = '/MATLAB Drive/data/results/read_preprocess_and_epoch_EOG/';
%current folder contains text EOG files
cd '/MATLAB Drive/data/OSF Storage/Raw data/EOG'

% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 5);

% Specify range and delimiter
opts.DataLines = [8, Inf];
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["TIME", "SensorCEOG", "SensorDEOG", "Events", "VarName5"];
opts.VariableTypes = ["categorical", "double", "double", "char", "char"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Events", "VarName5"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["TIME", "Events", "VarName5"], "EmptyFieldRule", "auto");

sbj = dir('*.txt'); % load list of subjects
epoch_time = [-5,-0.1]; %select epoch time in seconds



for s = 1:size(sbj,1)
    %import subject data
    data = readtable(sbj(s).name, opts);
    
    %first we get the trigger names and times
    trig = data.Events;
    [trig_time, ~] = find(~cellfun(@isempty,trig));
    trig_names = trig(trig_time);
    %now get EEG data and put it in eeglab-friendly structure
    EEG1= data(:,2:3);
    EEGdata = EEG1{:,:}';
    EEG = pop_importdata('data',EEGdata);
    EEG.srate = 2048;
    EEG.times = linspace(1/EEG.srate,size(EEG.data,2)/EEG.srate,size(EEG.data,2));
    
    % preprocessing
    %filter data
    EEG = pop_eegfiltnew(EEG, [], 1, [], true, [], 0); % Highpass filter 1 Hz
    EEG = pop_eegfiltnew(EEG, [], 40, [], false, [], 0); % Lowpass filter 40 Hz
    

    %create markers 
    
    %check for 0 triggers
    %for some reason you get a trigger with number 0 once in a while; delete
    %them
    clearvars delete_epochs
    for i = 1:size(trig_names) %for each trial
        delete_epochs(i) = isempty(strfind(trig_names{i}, 'RS232 Trigger: 0('))== 0;
    end
    trig_names(delete_epochs)=[];
    trig_time(delete_epochs)=[];
    
    
    %find bell sound trigger
    index_trigger = zeros(1,size(trig_names,1));
    for i = 1:size(trig_names) %loop trial
        if isempty(strfind(trig_names{i}, '100'))== 0
            index_trigger(i) = 1;
        end
    end
    
    bell = trig_time(index_trigger==1);
    
    %create event in sound trigger
    for i = 1:size(bell,1)
        EEG.event(i).latency = bell(i);
        EEG.event(i).type = 'bell';
        EEG.event(i).urevent = i;
        EEG.urevent(i).latency = bell(i);
        EEG.urevent(i).type = 'bell';
    end
    
    
 [OUTEEG, epoch_indices] = pop_epoch( EEG, {}, epoch_time);
  %downsample
 [OUTEEG_eog] = pop_resample(OUTEEG, 512);
 
 %save
 file_name1 = strcat(path1, sbj(s).name);
 file_name = strcat(file_name1, '.mat');
 save(file_name, 'OUTEEG_eog')
 clearvars EEG OUTEEG   
 

 
end