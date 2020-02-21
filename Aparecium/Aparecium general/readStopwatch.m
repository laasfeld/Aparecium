function [times, labels] = readStopwatch(fileName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    fileHandle = fopen(fileName,'r', 'b');
    g = textscan(fileHandle,'%s','delimiter','\n');
    fclose(fileHandle);

    times = zeros(numel(g{1}) - 1, 1);
    labels = cell(numel(g{1}) - 1, 1);
    lineSplits = textscan(g{1}{2}, '%s');
    labels{1} = strjoin(lineSplits{1}(1:numel(lineSplits{1}) - 7));
    for lineIndex = 3 : numel(g{1})   
        lineSplits = textscan(g{1}{lineIndex}, '%s');
        additionalLabelParts = numel(lineSplits{1}) - 9;
        if strcmp(lineSplits{1}{2}, 'Pause')
            times(lineIndex - 1 : end) = [];
            labels(lineIndex - 1 : end) = [];
            break;     
        end
        temp = textscan(lineSplits{1}{4 + additionalLabelParts}, '%s');
        timeSplit = strsplit(temp{1}{1}, ':');
        times(lineIndex - 1) = str2double(timeSplit{1})*3600 + str2double(timeSplit{2})*60 + str2double(timeSplit{3});
        labels{lineIndex - 1} = strjoin(lineSplits{1}(2:2+additionalLabelParts));
    end

end