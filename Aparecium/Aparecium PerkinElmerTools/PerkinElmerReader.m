classdef PerkinElmerReader < handle
    %PERKINELMERREADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private)
        experimentDataStructure
        measurementNumericData
        measurementTextData
        numberOfChannels = 1;
        numberOfCycles;
    end
    
    methods
        function this = PerkinElmerReader()
            
        end
        
        function readFile(this, fileName)
           [this.measurementNumericData, this.measurementTextData] = xlsread(fileName, 1); 
           [unneeded, textMetaData] = xlsread(fileName, 3)
           this.experimentDataStructure.channelNames = cell(0,0);
           for row = 1 : numel(textMetaData)
               if strfind(textMetaData{row}, 'Name of the label')
               %if strfind(textMetaData{row}, 'Label technology')
                    % a more precise information about channel could be
                    % obtained when searching for "Name of the label ................." 
                    this.experimentDataStructure.channelNames{end + 1} = regexprep(textMetaData{row}, 'Name of the label .................', '');
                    % this.experimentDataStructure.channelNames{end + 1} = regexprep(textMetaData{row}, 'Label technology .................. ', '');
               end
           end
           this.experimentDataStructure.wellID = PerkinElmerReader.findWellID(this.measurementTextData);          
           this.numberOfChannels = numel(this.experimentDataStructure.channelNames);
           this.calculateNumberOfCycles;
           this.experimentDataStructure.numberOfChannels = this.numberOfChannels;
           this.measurementNumericData = PerkinElmerReader.convertTimeFromDayToSec(this.measurementNumericData);
           this.calculateSlowAndFastKineticTimes();
           this.experimentDataStructure.measurements = this.readMeasurements(this.measurementNumericData);
           this.experimentDataStructure.temperature = this.readTemperature(fileName);
        end
        
        function calculateNumberOfCycles(this)
            this.numberOfCycles = this.numberOfChannels * size(this.measurementNumericData, 1) / numel(this.experimentDataStructure.wellID);
        end
        
        function measurements = readMeasurements(this, data)           
            measurements = cell(1, numel(this.experimentDataStructure.wellID));
            for wellIndex = 1 : numel(this.experimentDataStructure.wellID)
               measurements{wellIndex} = NaN(this.numberOfCycles*this.numberOfChannels, 1);
               endCycle = 0;
               for cycleIndex = 1 : this.numberOfCycles/this.numberOfChannels
                   for channelIndex = 1 : this.numberOfChannels  
                        endCycle = endCycle + 1;
                        measurements{wellIndex}((endCycle-1)*this.numberOfChannels + channelIndex) = this.measurementNumericData((cycleIndex-1)*numel(this.experimentDataStructure.wellID) + wellIndex, 6 + 2*(channelIndex - 1));               
                   end
               end
            end
        end
        
        function calculateSlowAndFastKineticTimes(this)
            for wellIndex = 1 : numel(this.experimentDataStructure.wellID)
                for cycleIndex = 1 : this.numberOfChannels : this.numberOfCycles
                    for channelIndex = 1 : this.numberOfChannels
                        fastKineticTimes((cycleIndex -1) + channelIndex, wellIndex) = this.measurementNumericData(((cycleIndex-1)/this.numberOfChannels)*numel(this.experimentDataStructure.wellID) + wellIndex, 5 + 2*(channelIndex - 1));
                    end
                end
            end
            slowKineticTimes = min(fastKineticTimes, [], 2);
            this.experimentDataStructure.timeOfMeasurements = slowKineticTimes;
            this.experimentDataStructure.timeOfFastKineticsMeasurements = fastKineticTimes;
            
        end
        
        function temperatureArray = readTemperature(this, fileName)
            [measurementNumericData, measurementTextData] = xlsread(fileName, 2);
            temperature = mean(measurementNumericData(1, 4:5));
            temperatureArray(1 : this.numberOfCycles, 1) = temperature;
        end
        
    end
    

    methods(Static) 
        function data = convertTimeFromDayToSec(data)
            data(:, 5 : 2 : end) = data(:, 5 : 2 : end) * 86400;
        end
        
        function wellID = findWellID(measurementTextData)
            wellIDColumn = measurementTextData(:, 3);
            for i = 3 : numel(wellIDColumn)
                if(isequal(strcmp(wellIDColumn(i), wellIDColumn(2)), 1))
                    noOfWells = i - 2;
                    break;
                else
                    noOfWells = numel(wellIDColumn) - 1;
                end
            end 
            wellID = wellIDColumn(2 : noOfWells + 1)';
        end
        

        

    end
  
    
end

