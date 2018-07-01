function createSlopeImages(inDirectoryName, outDirectoryName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
directory = dir(inDirectoryName);
fileNames = cell(numel(directory), 1);
for fileIndex = 1 : numel(directory)
    fileNames{fileIndex} = directory(fileIndex).name;
end

rigthFileNames = cell(numel(fileNames), 1);
for fileIndex = 1 : numel(fileNames)
    if( ~isequal(strfind(fileNames{fileIndex}, 'Z0'), []) && ~isequal(strfind(fileNames{fileIndex}, 'Bright Field'), []))
        rigthFileNames{fileIndex} = fileNames{fileIndex};
    else
    end
end
rigthFileNames = rigthFileNames(~cellfun(@isempty, rigthFileNames));
%matlabpool
for i = 1 : numel(rigthFileNames)
    slopesCell = stackLinearReg([inDirectoryName,'/'], rigthFileNames{i}, 'stdev');
    imwrite(slopesCell, [outDirectoryName,'/', regexprep(rigthFileNames{i}, 'Bright Field', 'Slopes')], 'tif');
    disp(['writing ',outDirectoryName,'/', regexprep(rigthFileNames{i}, 'Bright Field', 'Slopes')]);
end
%matlabpool close



