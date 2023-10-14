function [Data, layout]=convertDatatoFieldtrip3(data, marker)
    %addpath D:\fieldtrip-20180805\fieldtrip-20180805
    load('electrode19.mat')
    load('chanlocs.mat')
   

    Data=[];
    Data.label=electrode19;
    Data.hdr.nChans=numel(electrode19);
    Data.hdr.label=electrode19';
    Data.hdr.Fs=256;
    Data.fsample=256;
    
    if iscell (data) %if it is a cell the data contains 3 dimensions (e.g. subject, electrode, frequency)
        data=reshape(cell2mat(data), size(data{1},1), size(data{1},2), size(data,2));
        data=permute(data, [2,3,1]);
        labels=[ones(size(data,3),1)]*marker; 
        Data.trial=squeeze(num2cell(data,[1 2]))';
        Data.time=num2cell(repmat(1:size(data,2), size(data,3),1), 2)';
        Data.trialinfo=labels';
        Data.hdr.nSamples=size(data,2);
        
    else %if it is a matrix the data contains 2 dimensions (e.g. subject and  electrode)
       
        data=permute(data, [2,1]);
        labels=[ones(size(data,2),1)]*marker; 
        Data.trial=squeeze(num2cell(data,[1]))';
        Data.time=num2cell(ones(1,size(data,2)));
        Data.trialinfo=labels';
        Data.hdr.nSamples=1;
    end
         
    cfg=[];
    Data=ft_preprocessing(cfg, Data);
    Data.trialinfo=labels;

     cfg.layout = 'biosemi32.lay';
    Data.layout = ft_prepare_layout(cfg);
    layout = ft_prepare_layout(cfg);
    Data.layout=Data;
           
    
    
end