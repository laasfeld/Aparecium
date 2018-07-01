classdef PheraSTARASCIIReader < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = public)
    end
    
    properties (SetAccess = private)
        experimentDataStructure
        fileHandle;
    end
    
    methods
        function this = PheraSTARASCIIReader()
            
        end
        
        function readFile(this, fileName)
            this.fileHandle = this.getFileHandle(fileName);
            
            this.goToBeginningOfTheFile();
            this.experimentDataStructure.timeOfMeasurements = this.readTimeOfMeasurements(this.fileHandle);
            
            this.goToBeginningOfTheFile();
            this.experimentDataStructure.numberOfChannels = this.readNumberOfChannels(this.fileHandle);
            
            this.goToBeginningOfTheFile();
            this.experimentDataStructure.temperature = this.readTemperatureOfTheAparatus(this.fileHandle);

            location = ftell(this.fileHandle);
            this.goToLocation(location);
            this.experimentDataStructure.wellID = this.readWellID(this.fileHandle);
            
            this.goToLocation(location);
            this.experimentDataStructure.measurements = this.readMeasurements(this.fileHandle); 
            
            this.goToBeginningOfTheFile();
            this.experimentDataStructure.readingDirection = this.readPlateReadingDirection(this.fileHandle);
            
            this.goToBeginningOfTheFile();
            this.experimentDataStructure.cycleTime = this.findCycleTime(this.fileHandle);
            
            this.goToBeginningOfTheFile();
            this.experimentDataStructure.channelNames = this.findChannelNames(this.fileHandle, this.experimentDataStructure.numberOfChannels);
            
            this.closeFileHandle(this.fileHandle);
            
            this.removeUnmeasuredWells();
            
            this.calculateFastKinetics();
        end
        
        function calculateFastKinetics(this)
            try
                this.experimentDataStructure.timeOfFastKineticsMeasurements = fastKineticsCalculator(this.experimentDataStructure.wellID', this.experimentDataStructure.readingDirection, this.experimentDataStructure.cycleTime, this.experimentDataStructure.timeOfMeasurements')';
            catch
                
            end
        end
        
        function  goToBeginningOfTheFile(this)
            fseek(this.fileHandle, 0, 'bof');
        end
        
        function goToLocation(this, location)
            fseek(this.fileHandle, location, 'bof'); 
        end    
        
        function removeUnmeasuredWells(this)
            IDIndex = [];
            tempData = [];
            ID = this.experimentDataStructure.wellID;
            data = this.experimentDataStructure.measurements;
            for NaNChecker = 1 : size(data, 2)
                allowCopy = 1;
                for timePoint=1 : size(data{1,NaNChecker},1)
                    if(isnan(data{1, NaNChecker}(timePoint)))
                        allowCopy = 0;
                        break;
                    end
                end
                if(allowCopy)
                   tempData{end+1} = data{1,NaNChecker};
                   IDIndex(end+1) = NaNChecker;
                end

            end
            tempID={};
            this.experimentDataStructure.measurements = tempData;
            i = 0;
            for a = IDIndex
               i = i + 1;
               tempID(:,i) = ID(a); 
            end     
            this.experimentDataStructure.wellID = tempID;
        end
    end
    
    methods(Static)
        
        function fileHandle = getFileHandle(fileName)
            fileHandle = fopen(fileName,'r', 'b');
        end
        
        function closeFileHandle(fileHandle)
           fclose(fileHandle); 
        end
        
        function timeOfMeasurements = readTimeOfMeasurements(fileHandle)
            lineOfTimeMoments = PheraSTARASCIIReader.findLineWithTimeValues(fileHandle);
            timeOfMeasurements = sscanf(lineOfTimeMoments,'%d %*s');%conversts the time CSV values to a matrix
        end
        
        function lineOfTimeMoments = findLineWithTimeValues(fileHandle)
             PheraSTARASCIIReader.findFirstLineWithString(fileHandle, 'Time [s]:');
             lineOfTimeMoments = fgetl(fileHandle);
        end
        
        function line = findFirstLineWithString(fileHandle, string)
             indexOfScannedLine = 0;
             line = '';
             while strcmp(line, string)~=1 %"Time [s]:" indicates, that next line will contain measurement time moments
                line = fgetl(fileHandle);
                indexOfScannedLine = indexOfScannedLine + 1;
             end                  
        end
        
        function line = findFirstLineWithBeginning(fileHandle, string, firstNCharacters)
             indexOfScannedLine = 0;
             line = '';
             while strncmp(line, string, firstNCharacters)~=1 %"Time [s]:" indicates, that next line will contain measurement time moments
                line = fgetl(fileHandle);
                indexOfScannedLine = indexOfScannedLine + 1;
             end                  
        end  
        
        function numberOfChannels = readNumberOfChannels(fileHandle)
            lineOfChannelNumbers = PheraSTARASCIIReader.findFirstLineWithBeginning(fileHandle, 'No. of Channels / Multichromatics:', 10);
            numberOfChannels = sscanf(lineOfChannelNumbers, '%*s %*s %*s %*s %*s %d'); 
        end
        
        function temperatures = readTemperatureOfTheAparatus(fileHandle)
           PheraSTARASCIIReader.findFirstLineWithString(fileHandle, 'T[°C]:'); %"T[°C]:" indicates, that next line will contain temperatures at measurements cycles
           lineOfTemperatures = fgetl(fileHandle);
           temperatures = textscan(lineOfTemperatures, '%s',  'delimiter', ',');
           temperatures = temperatures{1};
        end
        
        function wellID = readWellID(fileHandle)
           i=0;
           while ~feof(fileHandle)
               i=i+1;
               temp_line = fgetl(fileHandle);
               try
                   try
                       tempID = textscan(temp_line, '%s %*[^\n]',  'delimiter', ',', 'BufSize', numel(temp_line));
                   catch
                       tempID = textscan(temp_line, '%s %*[^\n]',  'delimiter', ',');
                   end
                   wellID{i}=tempID{1,1}{1,1};
               catch
                   i = i - 1;
               end
           end 
        end
        
        function measurements = readMeasurements(fileHandle)
            i=0;
            while ~feof(fileHandle)
                i=i+1;
                temp_line = fgetl(fileHandle);
                if(isequal(numel(temp_line),0))
                    break;
                end
                try
                    tempData = textscan(temp_line, '%*s %[^\n]', 'delimiter', ',', 'BufSize', numel(temp_line));
                catch
                    tempData = textscan(temp_line, '%*s %[^\n]', 'delimiter', ',');
                end
                measurements{:,i}=sscanf(tempData{1,1}{1,1},['%f' ',']);
            end           
        end
    
        function plateReadingDirection = readPlateReadingDirection(fileHandle)
           lineWithReadingDirection = PheraSTARASCIIReader.findFirstLineWithBeginning(fileHandle, 'Reading direction:', 17);
           plateReadingDirection = sscanf(lineWithReadingDirection,'%*s %*s %d');
        end
        
        function cycleTime = findCycleTime(fileHandle)
            lineWithCycleTime = PheraSTARASCIIReader.findFirstLineWithBeginning(fileHandle, ' Cycle time [s]:', 10);% yes, the space in the beginning of  ' Cycle time [s]:' is needed
            cycleTime = sscanf(lineWithCycleTime,'%*s %*s %*s %d %*s %*s %*s');
        end
        
        function channelNames = findChannelNames(fileHandle, numberOfChannels)
            indexOfScannedLine = 0;
            line = '';
            channelNames = cell(1,numberOfChannels);
            channelIndex = 1;
            while isequal(strfind(line,'Used optic modules'),[])
                line = fgetl(fileHandle);
                indexOfScannedLine = indexOfScannedLine + 1;
            end
            while isequal(strfind(line,'Basic Parameters'),[])
                line = fgetl(fileHandle);
                indexOfScannedLine = indexOfScannedLine + 1;
                if isequal(strfind(line,' - '),[])&&~isequal(strfind(line,'Channel'),[])
                    channelNames{channelIndex} = line;
                    % remove the channel beginning
                    channelNames{channelIndex} = regexprep(channelNames{channelIndex},'  \w:','');
                    % search for the beginning of not used information
                    uselessIndex = strfind(channelNames{channelIndex}, ':');
                    channelNames{channelIndex} = channelNames{channelIndex}(1:uselessIndex-1);
                    channelIndex = channelIndex + 1;
                end
            end
        end
    end
end