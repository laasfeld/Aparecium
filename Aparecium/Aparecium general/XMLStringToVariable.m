function xmlStruct = XMLStringToVariable(variable)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% check if the temp file we want to generate is 
options.store_class = 0;
options.store_size = 0;
d = dir('ApareciumTempXMLFile.xml');
if isequal(numel(d), 0)
    fileID = fopen('ApareciumTempXMLFile.xml','w');
    fprintf(fileID, regexprep(regexprep(variable, '%', '%%'), '\\', '\\\'));
    fclose(fileID);
    xmlStruct = tinyxml2_wrap('load', 'ApareciumTempXMLFile.xml');
    delete('ApareciumTempXMLFile.xml');
end
end