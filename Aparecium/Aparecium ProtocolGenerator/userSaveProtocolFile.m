function userSaveProtocolFile(experimentProtocolObject)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[fileName, filePath] = uiputfile('*.mat', 'Save protocol file, prefix PRT- is recommended');
fullPath = [filePath, fileName];
save(fullPath, 'experimentProtocolObject');
end