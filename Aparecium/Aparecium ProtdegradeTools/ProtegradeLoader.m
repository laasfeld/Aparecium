function experimentDataStructure = ProtegradeLoader(filePath)
%PROTEGRADELOADER Summary of this function goes here
%   Detailed explanation goes here
%filePath = 'C:\Users\Kasutaja\Downloads\20190118_2_lysozyme.txt';
tic
table = readtable(filePath, 'HeaderLines', 2);
toc
tic
[nrOfChannels, channelNames] = readToCell(filePath);
toc
experimentDataStructure.numberOfChannels = nrOfChannels;
experimentDataStructure.wellID = ImageImporter.sortWellID(table2cell(unique(table(:,1))));
experimentDataStructure.cycleTime = table{2, 7} - table{1, 7};
experimentDataStructure.timeOfMeasurements = table{1 : size(table, 1)/numel(experimentDataStructure.wellID), 8};
experimentDataStructure.channelNames = channelNames;

experimentDataStructure.timeOfFastKineticsMeasurements = [];
experimentDataStructure.measurements = cell(1, numel(experimentDataStructure.wellID));
nrOfTimepoints = numel(experimentDataStructure.timeOfMeasurements);
for well = 1 : numel(experimentDataStructure.wellID)
    experimentDataStructure.measurements{well} = zeros(numel(experimentDataStructure.timeOfMeasurements) * nrOfChannels, 1);
    tableIndex = (well - 1)*numel(experimentDataStructure.timeOfMeasurements);
    for channelIndex = 1 : nrOfChannels                 
         experimentDataStructure.measurements{well}(channelIndex : nrOfChannels:end) = table{tableIndex+1 : tableIndex + nrOfTimepoints, 7+channelIndex};
    end
end


end

function [nrOfChannels, channelNames] = readToCell(filePath)
    fileHandle = fopen(filePath,'r', 'b');
    fseek(fileHandle, 0, 'bof');
    lines = linecount(fileHandle);
    fseek(fileHandle, 0, 'bof');
    %skip one line of header, currently we do not need that information
    line = fgetl(fileHandle);
    %read true table header line. From here we can get the number of
    %channels
    line = fgetl(fileHandle);
    header = strsplit(line, ' ');
    nrOfChannels = numel(header) - 6;
    channelNames = header(7:end);
    %resultCell = cell(lines - 2, numel(header));
    %for i = 3 : lines
    %    line = fgetl(fileHandle);
    %    resultCell(i - 2, :) = splitAtChar(line, 9, numel(header));
    %end  
end

function array = splitAtChar(line, charNr, expectedNr)
    array = cell(1, expectedNr);
    indices = find(line == char(charNr));
    indices = [0, indices, numel(line)];
    for i = 1 : numel(indices) - 1
       array{i} = line(indices(i) + 1 : indices(i+1) - 1); 
    end
end

function result = notAtEndOfTheFile(line)
   if isequal(line, -1)
       result = 0;
   else
       result = 1;
   end
end

function n = linecount(fid) % adapted from https://se.mathworks.com/matlabcentral/answers/81137-pre-determining-the-number-of-lines-in-a-text-file code by Guru
    n = 0;
    tline = fgetl(fid);
    while ischar(tline)
      tline = fgetl(fid);
      n = n+1;
    end
end