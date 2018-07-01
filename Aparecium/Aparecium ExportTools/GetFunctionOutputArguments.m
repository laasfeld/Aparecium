function [channelNames] = GetFunctionOutputArguments(inputChannelNames, inputFunctionAcronyme)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if strcmp(inputFunctionAcronyme, 'TFI')
    channelNames = {'TFI'};
elseif strcmp(inputFunctionAcronyme, 'FA')
    channelNames = {'FA'};
elseif strcmp(inputFunctionAcronyme, 'Blank correct')
    channelNames = cell(1, 0);
    for channel = 1 : numel(inputChannelNames)
       channelNames{channel} = ['blanked_',inputChannelNames{channel}]; 
    end
elseif strcmp(inputFunctionAcronyme, 'Blank normalize')
    channelNames = cell(1, 0);
    for channel = 1 : numel(inputChannelNames)
       channelNames{channel} = ['blank normalized_',inputChannelNames{channel}]; 
    end
elseif strcmp(inputFunctionAcronyme, 'Timewise blank normalize')
    channelNames = cell(1, 0);
    for channel = 1 : numel(inputChannelNames)
       channelNames{channel} = ['timewise blank normalized_',inputChannelNames{channel}]; 
    end
else
    channelNames = {inputFunctionAcronyme};
end



end

