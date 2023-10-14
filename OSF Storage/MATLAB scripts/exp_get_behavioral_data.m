%set current folder to where the text files are
cd '/MATLAB Drive/data/OSF Storage/Raw data/EEG'
addpath('/MATLAB Drive/data/OSF Storage/MATLAB scripts');
addpath('/MATLAB Drive/data/OSF Storage/Other files');
addpath('/MATLAB Drive/data/OSF Storage/Raw data/EEG');
addpath(genpath('/MATLAB Add-Ons/Collections/EEGLAB/functions'));
addpath('/MATLAB Drive/data/libraries/firfilt');
addpath('/MATLAB Drive/data/libraries/clean_rawdata');
path1 = '/MATLAB Drive/data/results/read_preprocess_and_epoch_EEG/';
 % load file with channel locations
 load('EEG21locs'); 
 
% Import text options

%Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 22);
% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = " ";
% Specify column names and types
opts.VariableNames = ["FP1", "FP2", "F7", "F3", "Fz", "F4", "F8", "T3", "C3", "Cz", "C4", "T4", "T5", "P3", "PZ", "P4", "T6", "O1", "O2", "A1", "A2", "Events"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "char"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";
% Specify variable properties
opts = setvaropts(opts, "Events", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Events", "EmptyFieldRule", "auto");


sbj = dir('*MW.txt'); % load list of subjects

%create matrices to save
confidence = zeros(size(sbj,1),40);
arousal = zeros(size(sbj,1),40);
condition_index = zeros(size(sbj,1),40);


for s = 1:size(sbj,1) %loop subjects
%for s = 1:1    
    clearvars data delete_epochs confidence_1 arousal_1
    %import subject data
    data = readtable(sbj(s).name, opts);
    
    %first we get the trigger names and times
    trig = data.Events;
    [trig_time, ~] = find(~cellfun(@isempty,trig));
    trig_names = trig(trig_time);
    
    %check 0 triggers
    %for some reason you get a trigger with number 0 once in a while; delete
    %them
    
    for i = 1:size(trig_names,1) %for each trial
        delete_epochs(i) = isempty(strfind(trig_names{i}, 'RS232 Trigger: 0('))== 0;
    end
    trig_names(delete_epochs)=[];
    trig_time(delete_epochs)=[];
    
    condition = zeros(1,size(trig_names,1)); %create temporal variable
    for i = 1:size(trig_names,1) %loop trial
 
        if isempty(strfind(trig_names{i}, '100'))== 0 %if it is the bell marker
        % after 100 trigger the next line contains either 101 or 102.
        % Indicates that whether they are breath focusing or mind wandering
        % respectively. And the next two lines contains the confidence and
        % arousal levels.
            %confidence and arousal are marker + 2 and + 3 respectively
                    temp2 = trig_names{i+2};
                    temp3 = trig_names{i+3};

                    %disp(temp2); disp(temp3);
     
            confidence_1(i)= str2double(temp2(16));
            arousal_1(i) =  str2double(temp3(16));

            %disp(confidence_1(i));  disp(arousal_1(i));
            if isempty(strfind(trig_names{i+1}, '101'))== 0 %if answer is focus on breathing

            condition(i) = 1;

            end

            if isempty(strfind(trig_names{i+1}, '102'))== 0 %if answer is mind wandering
            condition(i) = 2;  

            end



        end


    end

    %eliminate zeros and save vars
    condition_index(s,:) = nonzeros(condition);
    confidence(s,:) = nonzeros(confidence_1);
    arousal(s,:) = nonzeros(arousal_1);
    
    
end