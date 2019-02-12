function line = variableToXMLString(variable)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% check if the temp file we want to generate is 
options.store_class = 0;
options.store_size = 0;
line = tinyxml2_wrap('format', variable, options);
% d = dir('ApareciumTempXMLFile.txt');
% if isequal(numel(d), 0)
%     tinyxml2_wrap('save', 'ApareciumTempXMLFile.txt', variable, options)
%     fileHandle = fopen('ApareciumTempXMLFile.txt','r', 'b');
%     line = '';
%     while 1
%         cline = fgetl(fileHandle);
%         if isequal(cline, -1)
%             break;
%         end
%         line = [line, cline];
%     end
%     line = regexprep(line,' idx="\d*"'  , '');
%     line = regexprep(line, regexptranslate('escape','<?xml version="1.0" encoding="UTF-8"?><!--Written using tinyxml2_wrap version 1.0-->'), '');
%     fclose(fileHandle);
%     delete('ApareciumTempXMLFile.txt');
% end
% end

