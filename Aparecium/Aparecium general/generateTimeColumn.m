function timeColumn = generateTimeColumn(experimentDataStructure, fastKinetics)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
wellID = experimentDataStructure.wellID;
timeOfMeasurements = experimentDataStructure.timeOfMeasurements;
cycles = size(timeOfMeasurements, 1);
numberOfWells = size(wellID, 2);

timeOfFastKineticsMeasurements = experimentDataStructure.timeOfFastKineticsMeasurements;
if isequal(fastKinetics, 0)
    for cycle = 1 : cycles
        timeColumn((cycle-1)*numberOfWells + 1 : (cycle)*numberOfWells ) = num2cell(timeOfMeasurements(cycle));
    end
else
    for cycle = 1 : cycles
        for well = 1 : numberOfWells
            timeColumn((cycle-1)*numberOfWells + well) = num2cell(timeOfFastKineticsMeasurements(cycle, well));
        end
    end 
end

