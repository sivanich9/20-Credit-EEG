%set current folder to where the text files are
cd '/MATLAB Drive/data/OSF Storage/Raw data/EEG'
addpath('/MATLAB Drive/data/OSF Storage/MATLAB scripts');
addpath('/MATLAB Drive/data/OSF Storage/Other files');
addpath('/MATLAB Drive/data/OSF Storage/Raw data/EEG');
addpath(genpath('/MATLAB Add-Ons/Collections/EEGLAB/functions'));
addpath('/MATLAB Drive/data/libraries/firfilt');
addpath('/MATLAB Drive/data/libraries/clean_rawdata');
path1 = '/MATLAB Drive/data/results/read_preprocess_and_epoch_EEG/';
load('EEG21locs');
%whos
labels = {EEG21locs.labels};
%disp(labels(:));
%disp(labels);
opts = delimitedTextImportOptions("NumVariables", 22);
opts.DataLines = [2, Inf];
opts.Delimiter = " ";
opts.VariableNames = ["FP1", "FP2", "F7", "F3", "Fz", "F4", "F8", "T3", "C3", "Cz", "C4", "T4", "T5", "P3", "PZ", "P4", "T6", "O1", "O2", "A1", "A2", "Events"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "char"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";
opts = setvaropts(opts, "Events", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Events", "EmptyFieldRule", "auto");

epoch_time = [-5,-0.1];

sbj = dir('/MATLAB Drive/data/OSF Storage/Raw data/EEG/*MW.txt');

for s = 1:size(sbj,1)
%for s = 1:1
    data = readtable(sbj(s).name, opts);
    %first we get the trigger names and times
    trig = data.Events;   %storing events of EEG files(P_1_MW.txt)
    [trig_time, ~] = find(~cellfun(@isempty,trig));   %trig_time is having cell numbers which are not empty
    trig_names = trig(trig_time);    %trig_names are having names of cells which are not empty
    
    %now get EEG data and put it in eeglab-friendly structure
    EEG1= data(:,1:21);  %EEG1 contains data same as in 'data' but without column 'event'
    EEGdata = EEG1{:,:}';  %EEGdata is transpose of EEG1(row 21 is no.of channels)
    EEG = pop_importdata('data',EEGdata);
    EEG.srate = 512;
    EEG.chanlocs = EEG21locs;
    EEG.times = linspace(1/EEG.srate,size(EEG.data,2)/EEG.srate,size(EEG.data,2));
    
    % preprocessing
    % filter data
    
    EEG = pop_eegfiltnew(EEG, [], 1, [], true, [], 0); % Highpass filter 1 Hz
    EEG = pop_eegfiltnew(EEG, [], 40, [], false, [], 0); % Lowpass filter 40 Hz 
    signal = clean_flatlines(EEG);   %detect and delete flat channels
    flat_electrodes(s) = size(signal.data,1); %keep track of flat electrodes if any
    signal = clean_asr(signal,20);  %use asr method for cleaning
    EEG = pop_interp(signal,EEG21locs , 'spherical');    %interpolate flat electrodes if any
    EEG= pop_reref(EEG, []);    %re-reference to average
    %to visualize continous data before and after preprocessing     
    %plot(EEG.times,EEGdata(1,:))
    %hold on
    %plot(EEG.times,EEG.data(1,:))
    %create markers  
    %check for 0 triggers
    %for some reason you get a trigger with number 0 once in a while; delete them
    clearvars delete_epochs
    for i = 1:size(trig_names) %for each trial
        delete_epochs(i) = isempty(strfind(trig_names{i}, 'RS232 Trigger: 0('))== 0;
    end
    trig_names(delete_epochs)=[];
    trig_time(delete_epochs)=[];


    % find bell sound trigger
    index_trigger = zeros(1,size(trig_names,1));
    for i = 1:size(trig_names) %loop trial
        if isempty(strfind(trig_names{i}, '100'))== 0
            index_trigger(i) = 1;
        end
    end

    bell = trig_time(index_trigger==1);

    %create event in EEGLAB with bell sound trigger
    for i = 1:size(bell,1)
        EEG.event(i).latency = bell(i);
        EEG.event(i).type = 'bell';
        EEG.event(i).urevent = i;
        EEG.urevent(i).latency = bell(i);
        EEG.urevent(i).type = 'bell';
    end

    %epoch
    [OUTEEG, epoch_indices] = pop_epoch( EEG, {}, epoch_time);

    %mark epochs to reject based on amplitude criteria 
    [OUTEEG,index_reject] = pop_eegthresh(OUTEEG, 1, 1:19, -100, ...
               100, -5, -0.1, 0, 1);

    %to visualize epoched data
    % pop_eegplot(OUTEEG)

     %to visualize continous data
     %pop_eegplot(EEG)


    %since data consists of multiple discontinuous epochs, 
    %each epoch should be separately baseline-zero'd 
    [data_bas,datamean] = rmbase(OUTEEG.data,0,0);

    %concatenate epochs for ICA
    data_bas_conc = reshape(data_bas, size(data_bas,1), size(data_bas,2)*size(data_bas,3));

    %run ica
    [ OUTEEG.icaweights , OUTEEG.icasphere ,~,~,~,~, OUTEEG.icaact] = runica(data_bas_conc,'ncomps',20);
    % to get inverse matrix if you want to plot in space with topoplot
    OUTEEG.icawinv = pinv(OUTEEG.icaweights * OUTEEG.icasphere);

     %save data
    file_name1 = strcat(path1, sbj(s).name);
    file_name = strcat(file_name1, '.mat');
    save(file_name, 'OUTEEG')
    clearvars EEG OUTEEG   %comment this if you want to see EEG and OUTEEG variables and don't forget to put for s = 1:1 instead of for s = 1:size(sbj,1) 

end    