function [fullData] = sendDataToMidasTable(experimentDataStructure, dimensionality)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

wellID = experimentDataStructure.wellID;
timeOfMeasurements = experimentDataStructure.timeOfMeasurements;
cycles = size(timeOfMeasurements, 1);
numberOfWells = size(wellID, 2);
numberOfChannels = experimentDataStructure.numberOfChannels;
measurements = experimentDataStructure.measurements;

%generateWellID Column, in each cycle of measurement, each well must be
%represented

wellIDColumn = cell((cycles * numberOfWells), 1);
plateIDColumn = cell((cycles * numberOfWells), 1);
treatmentColumns = cell((cycles * numberOfWells), dimensionality);
treatmentColumns(:,:) = {0};
measurementsSplitValue = cell(numberOfChannels, numberOfWells);
measurementsColumns = cell((cycles * numberOfWells), numberOfChannels);
timeColumn = cell((cycles * numberOfWells), 1);
plateIDColumn(1:end) = {'My_plate'};

for cycle = 1 : cycles
    wellIDColumn( (cycle-1)*numberOfWells + 1 : (cycle)*numberOfWells ) = wellID;
    timeColumn((cycle-1)*numberOfWells + 1 : (cycle)*numberOfWells ) = num2cell(timeOfMeasurements(cycle, :));
end

for i = 1:numberOfChannels
    for j = 1:numberOfWells 
       try
           measurementsSplitValue{i,j} = measurements{1,j}(i:numberOfChannels:end);
           measurementsColumns(j:numberOfWells:end, i) = num2cell(measurementsSplitValue{i,j});
       catch MException
           'siin'
       end
    end
end

fullData = [plateIDColumn, wellIDColumn, treatmentColumns, timeColumn, measurementsColumns];
end

