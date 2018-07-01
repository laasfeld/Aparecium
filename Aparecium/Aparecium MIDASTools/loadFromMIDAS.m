function [data, textData] = loadFromMIDAS(fileName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% load xls or csv MIDAS file in

All = importdata(fileName);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% convert data into meaningful parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isstruct(All.textdata)
%if numel(fieldnames(All.textdata))>0
%if(isfield(All.textdata,'Sheet1'))%% checks if the file has Sheet1. .xls format files might have 3 sheets in which case it exists or just a single sheet in which case All.textdata already contains the information
    fieldName = fieldnames(All.textdata);  
    textData = All.textdata.(fieldName{1});
    data = All.data.(fieldName{1});
else
    textData = All.textdata;
    data = All.data;
end

end