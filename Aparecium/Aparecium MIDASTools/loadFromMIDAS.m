function [data, textData] = loadFromMIDAS(fileName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% old version, has trouble with NaN values

%% load xls or csv MIDAS file in

% All = importdata(fileName);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% convert data into meaningful parameters
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if isstruct(All.textdata)
% %if numel(fieldnames(All.textdata))>0
% %if(isfield(All.textdata,'Sheet1'))%% checks if the file has Sheet1. .xls format files might have 3 sheets in which case it exists or just a single sheet in which case All.textdata already contains the information
%     fieldName = fieldnames(All.textdata);  
%     textData = All.textdata.(fieldName{1});
%     data = All.data.(fieldName{1});
% else
%     textData = All.textdata;
%     data = All.data;
% end


%% end of old version
if verLessThan('matlab', '9.9')
    try
        table = readtable(fileName,'ReadVariableNames',false,'Sheet', 1); %MIDAS column headers contain colon and are not compatible with the table class varable names
    catch
        table = readtable(fileName,'ReadVariableNames',false);
    end
    textData = cell(size(table));
    headerLogic = 'old';
else
    try
        table = readtable(fileName,'Sheet', 1, 'ReadVariableNames',true, 'VariableNamingRule', 'preserve');
    catch
        table = readtable(fileName,'ReadVariableNames',true, 'VariableNamingRule', 'preserve');        
    end
    headerLogic = 'new';
    tableSize = size(table);
    tableSize(1) = tableSize(1) + 1;
    textData = cell(tableSize);
end


nonIDVars = 0;
nonIDIndeces = zeros(size(textData, 2), 1);
for i = 1 : size(textData, 2)
    if strcmp(headerLogic, 'old') && strcmp(table{1,i}{1}(1:3), 'ID:')
        textData(:, i) = table{:, i};
    elseif strcmp(headerLogic, 'new') && strcmp(table.Properties.VariableNames{i}(1:3), 'ID:')
        textData{1, i} = table.Properties.VariableNames{i};
        textData(2:end, i) = table{:, i};
    elseif strcmp(headerLogic, 'old')
        nonIDVars = nonIDVars + 1;
        textData(1, i) = table{1, i};
        nonIDIndeces(nonIDVars) = i;
    elseif strcmp(headerLogic, 'new')
        nonIDVars = nonIDVars + 1;
        textData{1, i} = table.Properties.VariableNames{i};
        nonIDIndeces(nonIDVars) = i;
    end
end
nonIDIndeces( all(~nonIDIndeces,2), : ) = [];
if strcmp(headerLogic, 'old')
    startRowIndex = 2;
elseif strcmp(headerLogic, 'new')
    startRowIndex = 1;
end
tempTable = table2cell(table(startRowIndex:end, nonIDIndeces));
tempTable(cellfun(@isempty, tempTable)) = {'NaN'};
if strcmp(headerLogic, 'old')
    data = cellfun(@str2num, tempTable);
elseif strcmp(headerLogic, 'new')
    data = cell2mat(tempTable);
end