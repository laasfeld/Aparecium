function result = saveMidasFile(inputStruct)
%UNTITLED Summary of this function goes here
%   ei kasuta praeguses versioonis

data = inputStruct.data;
fileName = inputStruct.fileName;
if isfield(inputStruct, 'automatically')
    if inputStruct.automatically
        filePath = inputStruct.filePath;
        filterIndex = 2;
    else
        if isdeployed
            load([pwd, '\', 'settings.mat']);
        else
            load settings
        end 
        startingPath = settings.MIDAS;
        fileName=['MD-',fileName];
        [fileName,filePath,filterIndex] = uiputfile({'.xls';'.csv'},'Choose the filename',[startingPath,'\',fileName]);
    end
else
    if isdeployed
        load([pwd, '\', 'settings.mat']);
    else
        load settings
    end  
    startingPath = settings.MIDAS;
    fileName=['MD-',fileName];
    [fileName,filePath,filterIndex] = uiputfile({'*.xls';'*.csv'},'Choose the filename',[startingPath,'\',fileName]);
end

if isequal(filterIndex, 3)
    [unneeded, unneeded2, extension] = fileparts(fileName);
    if strcmp(extension, '.xls')
        filterIndex = 1;
    elseif strcmp(extension, '.csv')
        filterIndex = 2;
    else
        filterIndex = 0;
    end
end

if isequal(filterIndex,1)
    try
        outputFilenameMIDAS = [filePath,fileName];
        xlswrite(outputFilenameMIDAS, data)
        result = 1;
    catch
        outputFilenameMIDAS = [filePath,fileName];
        cell2csv(outputFilenameMIDAS, data)
        result = 1;
    end
elseif isequal(filterIndex,2)
    outputFilenameMIDAS = [filePath,fileName];
    cell2csv(outputFilenameMIDAS, data, ',')
    result = 1;
elseif isequal(filterIndex, 0) % user selected cancel
   result = 0;
elseif isequal(filerIndex, 3)
    

end

