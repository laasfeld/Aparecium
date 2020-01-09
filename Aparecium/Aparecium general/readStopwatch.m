function times = readStopwatch(fileName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    fileHandle = fopen(fileName,'r', 'b');
    g = textscan(fileHandle,'%s','delimiter','\n');
    fclose(fileHandle);

    times = zeros(numel(g{1}) - 1, 1);
    for lineIndex = 3 : numel(g{1})   
        lineSplits = textscan(g{1}{lineIndex}, '%s');
        if strcmp(lineSplits{1}{2}, 'Pause')
            times(lineIndex - 1:end) = [];
            break;     
        end
        temp = textscan(lineSplits{1}{4}, '%s');
        timeSplit = strsplit(temp{1}{1}, ':');
        times(lineIndex - 1) = str2double(timeSplit{1})*3600 + str2double(timeSplit{2})*60 + str2double(timeSplit{3});  
    end

end