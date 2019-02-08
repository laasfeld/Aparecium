function experimentDataStructure = ProtegradeLoader(filePath)
%PROTEGRADELOADER Summary of this function goes here
%   Detailed explanation goes here
%filePath = 'C:\Users\Kasutaja\Downloads\20190118_2_lysozyme.txt'; 
table = readtable(filePath, 'HeaderLines' ,2);
experimentDataStructure.numberOfChannels = 3;
experimentDataStructure.wellID = ImageImporter.sortWellID(table2cell(unique(table(:,1))));
experimentDataStructure.cycleTime = table{2, 7} - table{1, 7};
experimentDataStructure.timeOfMeasurements = table{1 : size(table, 1)/numel(experimentDataStructure.wellID), 8};
experimentDataStructure.channelNames = [{'Temperature'}, {'498-580'}, {'465-510'}];
experimentDataStructure.timeOfFastKineticsMeasurements = [];
experimentDataStructure.measurements = cell(1, numel(experimentDataStructure.wellID)); 
for well = 1 : numel(experimentDataStructure.wellID)
    experimentDataStructure.measurements{well} = zeros(numel(experimentDataStructure.timeOfMeasurements) * 3, 1);
    for timepoint = 1 : numel(experimentDataStructure.timeOfMeasurements)
        tableIndex = (well - 1)*numel(experimentDataStructure.timeOfMeasurements);
        experimentDataStructure.measurements{well}(timepoint*3 - 2) = table{tableIndex+timepoint, 8};
        experimentDataStructure.measurements{well}(timepoint*3 - 1) = table{tableIndex+timepoint, 9};
        experimentDataStructure.measurements{well}(timepoint*3) = table{tableIndex+timepoint, 10};
    end
end

end

