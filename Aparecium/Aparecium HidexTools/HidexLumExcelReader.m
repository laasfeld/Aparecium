classdef HidexLumExcelReader < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = public)
    end
    
    properties (SetAccess = private)
        experimentDataStructure
        fileHandle;
    end
    
    methods
        function this = HidexLumExcelReader()
            
        end

        function this = readFile(this, path)
            experimentDataStructure.timeOfMeasurements = [];
            experimentDataStructure.numberOfChannels = [];
            experimentDataStructure.temperature = [];
            experimentDataStructure.wellID = [];
            experimentDataStructure.measurements = [];
            experimentDataStructure.readingDirection = [];
            experimentDataStructure.cycleTime = [];
            experimentDataStructure.channelNames = [];
            experimentDataStructure.timeOfMeasurements = [];

            dataTable = readtable(path, 'Sheet', 'Luminescence');
            dataTable.Var1 = [];
            % Extract first row as headers (convert to cell array of strings)
            newHeaders = string(table2cell(dataTable(1,:)));

            % Assign as variable names
            dataTable.Properties.VariableNames = matlab.lang.makeValidName(newHeaders);

            % Remove the first row
            dataTable(1,:) = [];

            well_names = dataTable(:,'Well');

            unique_well_names = unique(table2cell(well_names));

            experimentDataStructure.wellID = ImageImporter.sortWellID(unique_well_names');

            nr_of_timepoints = numel(dataTable(1,3:end));

            times_matrix = zeros(nr_of_timepoints, numel(experimentDataStructure.wellID));
            experimentDataStructure.measurements = cell(1, numel(experimentDataStructure.wellID));
            counter = 1;
            for well_name = experimentDataStructure.wellID
               dataTable(:,'Well');
               times = dataTable(strcmp(dataTable.Well, well_name{1}) & strcmp(dataTable.Cycle_, {'Time (s)'}) , : );
               measurements = dataTable(strcmp(dataTable.Well, well_name{1}) & strcmp(dataTable.Cycle_, {'Result'}) , : );

               times_matrix(:, counter) = table2array(times(1, 3:end))';
               experimentDataStructure.measurements{counter} = table2array(measurements(1, 3:end))';

               counter = counter + 1;
            end

            experimentDataStructure.timeOfFastKineticsMeasurements = times_matrix;
            experimentDataStructure.timeOfMeasurements = min(experimentDataStructure.timeOfFastKineticsMeasurements, [], 2);
            experimentDataStructure.numberOfChannels = 1;
            experimentDataStructure.temperature = experimentDataStructure.timeOfMeasurements*NaN;
            experimentDataStructure.cycleTime = mean(diff(experimentDataStructure.timeOfMeasurements));
            experimentDataStructure.channelNames = {'Luminescence'};
            experimentDataStructure.readingDirection = NaN;
            this.experimentDataStructure = experimentDataStructure;
        end
    end
end