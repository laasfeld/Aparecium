function experimentDataStructure = generateEmptyExperimentDataStructure(channelNames, plateHeight, plateWidth)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
experimentDataStructure.numberOfChannels = numel(channelNames);
experimentDataStructure.channelNames = channelNames;
experimentDataStructure.readingDirection = 0;
experimentDataStructure.timeOfMeasurements = [0;1];

numberOfWells = plateHeight * plateWidth;
experimentDataStructure.timeOfFastKineticsMeasurements = zeros(2, numberOfWells);
for well = 1 : numberOfWells
    experimentDataStructure.timeOfFastKineticsMeasurements(1, well) = well/numberOfWells;
    experimentDataStructure.timeOfFastKineticsMeasurements(1, well) = 1 + (well/numberOfWells);
end
experimentDataStructure.measurements = cell(1, numberOfWells);
for well = 1 : numberOfWells
    experimentDataStructure.measurements{well} = NaN(experimentDataStructure.numberOfChannels*2, 1);
end

alphabet = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
[unused1, unsused2, wellID, unused3] = generateGhostplate({[alphabet(plateHeight), num2str(plateWidth)]});
reshapedWellID = reshape(wellID, 1, numel(wellID));
experimentDataStructure.wellID = reshapedWellID;
end

