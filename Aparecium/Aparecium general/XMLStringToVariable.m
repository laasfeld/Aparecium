function xmlStruct = XMLStringToVariable(variable)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% check if the temp file we want to generate is 
options.store_class = 0;
options.store_size = 0;
d = dir('ApareciumTempXMLFile.xml');
if isequal(numel(d), 0)
    try
        fileID = fopen('ApareciumTempXMLFile.xml','w');
        fprintf(fileID, regexprep(regexprep(variable, '%', '%%'), '\\', '\\\'));
        fclose(fileID);
        xmlStruct = tinyxml2_wrap('load', 'ApareciumTempXMLFile.xml');
        delete('ApareciumTempXMLFile.xml');
    catch MException
        delete('ApareciumTempXMLFile.xml');
        try
            xmlStruct = XMLStringToVariable(variable);
        catch MException
            errordlg('Something went wrong with xml file reading. Try deleting ApareciumTempXMLFile.xml manually and try again')
        end
    end
else
    pause(1) % if some other process is accessing the file give it time to use it
    delete('ApareciumTempXMLFile.xml');
    xmlStruct = XMLStringToVariable(variable);
end