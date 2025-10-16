classdef PheraStarDatabaseReader < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        experimentDataStructure;
        fileHandle;
    end
    
    methods
        
        function this = PheraStarDatabaseReader()
            
        end
        
        function readFile(this, fileName, parameterStructure)
            this.experimentDataStructure.readingDirection = parameterStructure.readingDirection;
            this.experimentDataStructure.cycleTime = parameterStructure.kineticTime;
            this.generateNumberOfChannels(parameterStructure);
            this.generateChannelNames(parameterStructure);
            
            table = this.createExperimentTable(fileName);
            table.open();
            experimentFields = table.getFields();
            fieldNames = this.generateFieldNames(experimentFields);
            numberOfCycles = this.generateNumberOfCycles(experimentFields, fieldNames);
            iterator = table.recordIterator();
            record = iterator.next(); 
            this.experimentDataStructure.timeOfMeasurements = this.generateTime(record, numberOfCycles, fieldNames);
            record = iterator.next();
            this.experimentDataStructure.temperature = this.generateTemperature(record, numberOfCycles, fieldNames);
            this.generateWellIDAndMeasurements(iterator, table, fieldNames, numberOfCycles, parameterStructure);
            
            this.calculateFastKinetics();
            table.close();
        end
        
        function calculateFastKinetics(this)
            this.experimentDataStructure.timeOfFastKineticsMeasurements = fastKineticsCalculator(this.experimentDataStructure.wellID', this.experimentDataStructure.readingDirection, this.experimentDataStructure.cycleTime, this.experimentDataStructure.timeOfMeasurements')';
        end
        
        function generateWellIDAndMeasurements(this, iterator, table, fieldNames, numberOfCycles, parameterStructure)
            iterationIndex = 0;
            nrOfWells = (table.getRecordCount()-2)/this.experimentDataStructure.numberOfChannels;
            this.experimentDataStructure.measurements = cell(1, nrOfWells);
            this.experimentDataStructure.wellID = cell(1, nrOfWells);
            %noc=2;% just a cheat for the time being.
            nrOfDualEmissionChannels = numel(unique(parameterStructure.emissionFilterChannel));

            channelsArray = 1 : this.experimentDataStructure.numberOfChannels;
            remappedChannelIndices = reshape(channelsArray(reshape(1:numel(channelsArray),[],nrOfDualEmissionChannels).'),[],1);  % remaps channel order as the order presented in the table does not come in the order of measurment or general logic
                        % the order is such that channel A-s of all blocks
                        % come before channel B-s of all blocks
            
            while(iterator.hasNext())
                recordChannelCell = cell(1, nrOfWells);
                for channelIndex = 1 : this.experimentDataStructure.numberOfChannels
                    if iterator.hasNext()
                        recordChannelCell{channelIndex} = iterator.next();
                    else
                        break
                    end
                end

                iterationIndex = iterationIndex + 1;
                this.experimentDataStructure.wellID{iterationIndex}=char(recordChannelCell{1}.getStringValue(fieldNames(1)));
                for fieldIndex = 4 : numberOfCycles
                    for channelIndex = 1 : this.experimentDataStructure.numberOfChannels
                        this.experimentDataStructure.measurements{1,iterationIndex}(end+1,1)=str2double(recordChannelCell{remappedChannelIndices(channelIndex)}.getNumberValue(fieldNames(fieldIndex)));
                    end
                end
            end
        end
        
        function temperature = generateTemperature(this, record, numberOfCycles, fieldNames)
            temperature = zeros(1, numberOfCycles - 3);
            for fieldIndex = 4 : numberOfCycles
                temperature(fieldIndex-3) = str2double(record.getNumberValue(fieldNames(fieldIndex)));
            end
            temperature = temperature';
        end
        
        function time = generateTime(this, record, numberOfCycles, fieldNames)
            time = zeros(1, numberOfCycles - 3);
            for fieldIndex = 4 : numberOfCycles
                time(1,fieldIndex-3) = str2double(record.getNumberValue(fieldNames(fieldIndex)));
            end
            time = time';
        end
        
        
        function cycles = generateNumberOfCycles(this, experimentFields, fieldNames)
            for fieldIndex = 1 : experimentFields.size()
                'KONZ_CHAR';
                if isequal(java.lang.String('KONZ_CHAR'), fieldNames(fieldIndex))
                    cycles = fieldIndex-1;
                    break;
                end   
            end        
        end
        
        function fieldNames = generateFieldNames(this, experimentFields)
            for field = 1 : experimentFields.size();
                fieldNames(field)=experimentFields.get(field-1).getName();
            end
        end
        
        function generateNumberOfChannels(this, parameterStructure)
             this.experimentDataStructure.numberOfChannels = length(parameterStructure.emissionFilter);             
        end
        
        function generateChannelNames(this, parameterStructure)

            nrOfDualEmissionChannels = numel(unique(parameterStructure.emissionFilterChannel));
            %nrOfMultichromaticChannels = numel(unique(parameterStructure.multichromaticIndex));
            channelsArray = 1 : this.experimentDataStructure.numberOfChannels;
            remappedChannelIndices = reshape(channelsArray(reshape(1:numel(channelsArray),[],nrOfDualEmissionChannels).'),[],1);  % remaps channel order as the order presented in the table does not come in the order of measurment or general logic

            
            
            for channel = 1 : this.experimentDataStructure.numberOfChannels
                channelLetter = parameterStructure.emissionFilterChannel{channel};
                multichromaticIndex =  parameterStructure.multichromaticIndex{channel};

                if strcmp(channelLetter, '')
                   channelLetter = 'A'; % It is for some reason that in the BMG database letter A is omitted and empty string is used instead and channels with letters start with B and so on. In ASCII files the first channel however is still named A. This line fixes this situation. 
                end
                
                %if strcmp(multichromaticLetter, 'A')
                this.experimentDataStructure.channelNames{remappedChannelIndices(channel)} = [parameterStructure.filterSetupName{multichromaticIndex}, ', Channel ', channelLetter];
                %elseif strcmp(multichromaticLetter, 'B')
                %    this.experimentDataStructure.channelNames{channel} = [parameterStructure.filterSetupName{fix((channel-1)/nrOfDualEmissionChannels) + 1}, ', Channel ',channelLetter];

                %end
                %this.experimentDataStructure.channelNames{channel} = [parameterStructure.exitationFilter{1},'/',parameterStructure.emissionFilter{channel}];
            end 
            this.experimentDataStructure.channelNames
        end
        
        function table = createExperimentTable(this, fileName)
            import java.lang.String
            import java.io.File
            import nl.knaw.dans.common.dbflib.*;
            
            string = String(fileName);
            file = File(string);
            table = Table(file);
        end
        
    end
    
end

