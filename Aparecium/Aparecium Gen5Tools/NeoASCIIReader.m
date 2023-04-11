classdef NeoASCIIReader < handle
    %This class can read Synergy Neo ASCII files if they are defined as
    %described in the Aparecium Documentation
    %   Detailed explanation goes here
    
    properties (SetAccess = public)
        experimentDataStructure
        fileHandle
        fileName = '';
        version = '';
        kinetics
        reads
        plateType
        lastLineOfHeader
        lastLineOfFile
        readAtKineticMode = 0;
        firstLineOfReads;
        totalNumberOfReads = 0;
        lineShiftFromVersion = 0;
        nextLine = 1; % indicates what line number will be read when getNextLine() is called
        lineToByteArray = zeros(1);
        stopwatchTimes = [];
        stopwatchLabels = [];
    end
    
    methods
        function this = NeoASCIIReader()
            
        end
        
        function readFile(this, fileName)
           this.readFileWithoutDatastruct(fileName);
           this.generateExperimentDataStructure();
        end
        
        function readFileWithoutDatastruct(this, fileName)
            this.fileName = fileName;
            this.readHeader();
        end
        
        function readHeader(this)
            this.mapBytesToLines();
            this.initializeFileHandle();
            this.readVersion();
            if(this.checkIfHeaderIsPresent())
                if this.checkIfOnlyOnePlateIsInFile()
                   errordlg('More than one plate found in the input file. Only a single plate is allowed in the input');
                   error('More than one plate found in the input file. Only a single plate is allowed in the input');
                end
                this.findLastLineOfHeader();
                this.findLastLineOfFile();
                this.readPlateType();
                this.findReads();
                this.findMeasurements();
                this.fixStartTimesOfNonKineticReads();
            end
        end
        
        function fixStartTimesOfNonKineticReads(this)
            for nonKineticReadIndex = 1 : numel(this.reads)
                if isequal(this.reads{nonKineticReadIndex}.orderIndex, 1)
                    continue
                end
                
                orderIndexToFind = this.reads{nonKineticReadIndex}.orderIndex - 1;
                matchFound = 0;
                
                for nonKineticReadIndexToMatch = 1 : numel(this.reads)
                    if isequal(this.reads{nonKineticReadIndexToMatch}.orderIndex, orderIndexToFind)
                        this.reads{nonKineticReadIndex}.measurementTimepoints = this.reads{nonKineticReadIndexToMatch}.measurementTimepoints;
                        matchFound = 1;
                        break
                    end
                end
                
                if matchFound
                   continue 
                end
                
                for kineticReadIndex = 1 : numel(this.kinetics)
                    for readIndexInKinetics = 1 : numel(this.kinetics{kineticReadIndex}.listOfReads)
                        if isequal(this.kinetics{kineticReadIndex}.listOfReads{readIndexInKinetics}.orderIndex, orderIndexToFind)
                            this.reads{nonKineticReadIndex}.measurementTimepoints = this.kinetics{kineticReadIndex}.listOfReads{readIndexInKinetics}.timepointForAppendStorage...
                                + this.kinetics{kineticReadIndex}.listOfReads{readIndexInKinetics}.interval;
                            matchFound = 1;
                            break
                        end
                    end
                    if matchFound
                        break
                    end
                end
                
            end
        end
        
        function mapBytesToLines(this)
           this.initializeFileHandle();
           line = '';
           while this.notAtEndOfTheFile(line)
               position = ftell(this.fileHandle);
               this.lineToByteArray(this.nextLine) = position;
               line = this.getNextLine();
           end
           fclose(this.fileHandle);           
        end
        
        function readVersion(this)
           this.goToBeginningOfTheFile();
           this.skipLines(2);
           line = this.getNextLine();
           if strfind(line, 'Software Version')
                this.version = regexprep(line, 'Software Version	', '');
                this.lineShiftFromVersion = 0;
           else
              warndlg('Warning! Gen5Software version is not present in the file, reader might not work properly');
              this.lineShiftFromVersion = -4;
           end
           this.goToBeginningOfTheFile();
        end
        
        function headerIsPresent = checkIfHeaderIsPresent(this)
            this.goToBeginningOfTheFile();
            this.skipLines(4 + this.lineShiftFromVersion);
            line = this.getNextLine();
            headerIsPresent = strcmp(line, 'Procedure Details');
            this.goToBeginningOfTheFile();
        end
        
        function morePlatesPresent = checkIfOnlyOnePlateIsInFile(this)
            this.goToBeginningOfTheFile();
            this.skipLines(4 + this.lineShiftFromVersion);
            line = this.getNextLine();
            firstPlateFound = strcmp(line, 'Procedure Details');
            morePlatesPresent = false;
            while notAtEndOfTheFile(this, line)
               line = this.getNextLine();
               if strcmp(line, 'Procedure Details')
                   morePlatesPresent = true;
                   break;
               end
            end
            this.goToBeginningOfTheFile();            
        end
        
        function readPlateType(this)
            this.goToBeginningOfTheFile();
            this.skipLines(6 + this.lineShiftFromVersion);
            line = this.getNextLine();
            this.plateType = regexprep(line, 'Plate Type', '');            
        end
        
        function findLastLineOfHeader(this)
            this.goToBeginningOfTheFile();
            startingLineIndex = 7 + this.lineShiftFromVersion;
            this.skipLines(startingLineIndex - 1);
            line = this.getNextLine();
            lineNumber = startingLineIndex;
            while this.lineIsNotEmpty(line)
                lineNumber = lineNumber + 1;
                line = this.getNextLine();
            end
            this.lastLineOfHeader = lineNumber - 1;
            this.firstLineOfReads = lineNumber;
        end
        
        function findLastLineOfFile(this)
            this.goToBeginningOfTheFile();
            line = this.getNextLine();
            this.lastLineOfFile = 1;
            procedureDetailsFound = false; % in case two or more experiments or plates have been exported to the same file, it is possible that end of quality part of file is not actual end of file
            while this.notAtEndOfTheFile(line) 
                this.lastLineOfFile = this.lastLineOfFile + 1;
                line = this.getNextLine();
                if ~isempty(strfind(line, 'Procedure Details')) && procedureDetailsFound
                    this.lastLineOfFile = this.lastLineOfFile - 2;
                    break;
                elseif ~isempty(strfind(line, 'Procedure Details'))
                    procedureDetailsFound = true;
                end
            end
        end
        
        function findReads(this)
            startingLine = 9 + this.lineShiftFromVersion;
            this.readAtKineticMode = 0;
            this.goToBeginningOfTheFile();
            this.skipLines(startingLine - 1);
            readIndex = 0;
            expectingFilterSet1 = 0;
            expectingFilterSet2 = 0;
            expectingReadType = 0;
            for currentLine = startingLine : this.lastLineOfHeader
                line = this.getNextLine();
                if strfind(line, 'Start Kinetic')
                    this.kinetics{end + 1} = Gen5Kinetic(line);
                    this.readAtKineticMode = 1;
                elseif strfind(line, 'End Kinetic')
                    this.readAtKineticMode = 0;
                elseif strfind(line, sprintf('Read	'))
                    if this.readAtKineticMode
                        currentRead = this.kinetics{end}.addEmptyRead();
                    else
                        this.reads{end + 1} = Gen5Read;
                        currentRead = this.reads{end};
                        currentRead.numberOfCycles = 1;
                        currentRead.runtime = 0;
                        currentRead.interval = 0;  
                    end
                    %line = this.getNextLine();
                    acceptedReadTypes = {'Fluorescence Spectrum', 'Image Endpoint', 'Fluorescence Endpoint', 'Image Montage'};
                    for readTypeCounter = 1 : numel(acceptedReadTypes)
                       if strfind(line, acceptedReadTypes{readTypeCounter})
                           currentRead.setReadType(line);
                           currentRead.setReadName(['Read ', num2str(readIndex + 1), ':'])
                           expectingReadType = 0;
                           break;
                       else
                          name = regexprep(line, 'Read', '');
                          name = regexprep(name, '\t', '');
                          if isequal(this.readAtKineticMode, 1)
                              for a = 1 : 4
                                 name = regexprep(name, ' ', ''); 
                              end
                          end
                          currentRead.setReadName([name, ':']); 
                          expectingReadType = 1; 
                       end
                    end              
                    readIndex = readIndex + 1;
                    currentRead.orderIndex = readIndex;
                    
                elseif strfind(line, 'Filter Set 1')
                    expectingFilterSet1 = 1;
                elseif strfind(line, 'Filter Set 2')
                    expectingFilterSet2 = 1;
                elseif strfind(line, 'Excitation') 
                    if expectingFilterSet1
                        currentRead.setChannel1(line);
                        expectingFilterSet1 = 0;
                    elseif expectingFilterSet2
                        currentRead.setChannel2(line);
                        expectingFilterSet2 = 0;
                    end
                elseif expectingReadType 
                    currentRead.setReadType(line);
                    expectingReadType = 0;
                elseif contains(line, 'Wavelengths') && strcmp(currentRead.readType, 'Absorbance Endpoint')
                    splitLine = strsplit(line, ':');
                    wavelengths = strsplit(splitLine{2}, ',');
                    for wavelengthIndex = 1 : numel(wavelengths)
                        currentRead.setChannel(wavelengths{wavelengthIndex}, wavelengthIndex)
                    end                    
                end
            end
            this.totalNumberOfReads = readIndex;
        end        
        
        function findMeasurements(this) % this function is long and has a lot of code duplications, refactor if possible
            this.mapMeasurementLines();
            sortedListOfReads = this.generateSortedListOfReads;
            activeReadIndex = 0;
            while activeReadIndex < this.totalNumberOfReads
                activeReadIndex = activeReadIndex + 1;
                if sortedListOfReads{activeReadIndex}.getIsAppendsIndex > 1 % this read will take it´s measurements from the first read of the append, no need to go through with the loop
                   continue; 
                end
                %disp(activeReadIndex);
                if (~strcmp(sortedListOfReads{activeReadIndex}.readType, 'Fluorescence Spectrum')&&~strcmp(sortedListOfReads{activeReadIndex}.readType, 'Image Endpoint')&&~strcmp(sortedListOfReads{activeReadIndex}.readType, 'Image Montage'))
                    channelNames = cell(0, 0);
                    this.goToBeginningOfTheFile();
                    startingLine = sortedListOfReads{activeReadIndex}.firstLineOfMeasurements;
                    endingLine = sortedListOfReads{activeReadIndex}.lastLineOfMeasurements;
                    this.skipLines(startingLine - 1);
                    measurementLineExpected = 0;
                    activeChannel = 0;
                    timePoint = 0;
                    if sortedListOfReads{activeReadIndex}.isKineticRead
                        for lineIndex = startingLine : endingLine
                            line = this.getNextLine();
                            if size(strfind(line, sortedListOfReads{activeReadIndex}.readName), 1)  && ~size(strfind(line, 'Time'), 1)  % old comparator size(strfind(line, 'Read'), 1) && ~size(strfind(line, 'Time'), 1)
                                timePoint = 0;
                                channelNames{end + 1} = regexprep(line, sortedListOfReads{activeReadIndex}.readName, '');
                                activeChannel = activeChannel + 1;
                            elseif (isequal(this.totalNumberOfReads, 1) || isequal(sortedListOfReads{activeReadIndex}.getIsAppendsIndex, 1))  && this.lineIsNotEmpty(line) && ~size(strfind(line, '	'), 1)
                                timePoint = 0;
                                channelNames{end + 1} = line;
                                activeChannel = activeChannel + 1;
                            elseif strfind(line, 'Time')
                                for scrapCols = 1 : 2
                                    scrap = textscan(line, '%s %*[^\n]','delimiter', '\t');
                                    line = regexprep(line, scrap{1,1}, '', 'once');
                                    line = regexprep(line, '\t', '', 'once');
                                end
                                well = 0;
                                wellID = cell(0, 0);
                                while (size(line, 2) > 0)
                                    well = well + 1;
                                    tempID = textscan(line, '%s %*[^\n]','delimiter', '\t');
                                    line = regexprep(line, tempID{1,1}, '', 'once');
                                    line = regexprep(line, '\t', '', 'once');
                                    wellID{end + 1} = tempID{1,1};    
                                end
                                measurementLineExpected = 1;
                            elseif measurementLineExpected
                                 if this.lineIsNotEmpty(line) && this.lineIsNotZero(line);

                                    timePoint = timePoint + 1;
                                    tempCellValueOfTime = textscan(line, '%s %*[^\n]','delimiter', '\t');
                                    time(timePoint) = str2double(tempCellValueOfTime{1, 1});
                                    line = regexprep(line, tempCellValueOfTime{1, 1}, '', 'once');
                                    line = regexprep(line, '\t', '', 'once');                                
                                    tempCellValueOfTemperature = textscan(line, '%s %*[^\n]','delimiter', '\t');
                                    temperature(activeChannel, timePoint) = str2double(regexprep(tempCellValueOfTemperature{1, 1}, ',', '.'));
                                    line = regexprep(line, tempCellValueOfTemperature{1,1}, '', 'once');
                                    line = regexprep(line, '\t', '', 'once');
                                    wellIndex = 0;
                                    while (size(line, 2)>0 && ~strcmp(line,''))
                                        wellIndex = wellIndex + 1;
                                        tempMeasurement = textscan(line, '%s %*[^\n]','delimiter', '\t');
                                        line = regexprep(line, tempMeasurement{1,1}, '', 'once');
                                        line = regexprep(line, '\t', '', 'once');
                                        measurements(activeChannel, timePoint, wellIndex) = tempMeasurement{1,1};
                                        if strcmp(line, '')
                                            measurements(activeChannel, timePoint, wellIndex + 1) = {''}; 
                                        end
                                    end 
                                 elseif isequal(timePoint, 0) 
                                     sortedListOfReads{activeReadIndex}.setReadWasEmpty('Yes');
                                     measurementLineExpected = 0;
                                 else
                                    measurementLineExpected = 0; 
                                 end
                            end
                        end

                    else
                        time = 0;
                        timePoint = 1;
                        activeChannel = 0;
                        for lineIndex = startingLine : endingLine

                            line = this.getNextLine();
                            if size(strfind(line, sortedListOfReads{activeReadIndex}.readName), 1) && ~size(strfind(line, '	'), 1) % old comparator size(strfind(line, 'Read'), 1) && ~size(strfind(line, '	'), 1)
                                channelNames{end + 1} = regexprep(line, sortedListOfReads{activeReadIndex}.readName, '');                            
                            elseif (isequal(this.totalNumberOfReads, 1) || isequal(sortedListOfReads{activeReadIndex}.getIsAppendsIndex, 1))  && this.lineIsNotEmpty(line) && ~size(strfind(line, '	'), 1)
                                channelNames{end + 1} = line;
                            elseif strfind(line, 'Actual Temperature:')
                                temperature = regexprep(line, 'Actual Temperature:	', '');
                                temperature = str2double(regexprep(temperature, ',','.'));
                                activeChannel = activeChannel + 1;
                            elseif size(strfind(line, 'Well'), 1) && ~size(strfind(line, 'ID'), 1)
                                line = regexprep(line, 'Well	', '');
                                well = 0;
                                wellID = cell(0, 0);
                                while (size(line, 2) > 0)
                                    well = well + 1;
                                    tempID = textscan(line, '%s %*[^\n]','delimiter', '\t');
                                    line = regexprep(line, tempID{1,1}, '', 'once');
                                    line = regexprep(line, '\t', '', 'once');
                                    wellID{end + 1} = tempID{1,1};    
                                end
                                measurementLineExpected = 1;
                            elseif size(strfind(line, sortedListOfReads{activeReadIndex}.readName), 1) || measurementLineExpected % old comparator size(strfind(line, 'Read'), 1) || measurementLineExpected
                                    measurementLineExpected = 0;
                                    tempID = textscan(line, '%s %*[^\n]','delimiter', '\t');
                                    % take regex special character ] into
                                    % account since Neo channels may be
                                    % [Parallel] or something similar
                                    tempID{1}{1}=regexprep(tempID{1}{1}, ']', '\\\]');
                                    line = regexprep(line, tempID{1,1}{1}, '', 'once');
                                    line = regexprep(line, '\t', '', 'once');
                                    wellIndex = 0;
                                    while (size(line, 2)>0 && ~strcmp(line,''))
                                        wellIndex = wellIndex + 1;
                                        tempMeasurement = textscan(line, '%s %*[^\n]','delimiter', '\t');
                                        line = regexprep(line, tempMeasurement{1,1}, '', 'once');
                                        line = regexprep(line, '\t', '', 'once');                                    
                                        measurements(activeChannel, timePoint, wellIndex) = tempMeasurement{1,1}; 
                                        if strcmp(line, '')
                                            measurements(activeChannel, timePoint, wellIndex + 1) = {''}; 
                                        end
                                    end                            
                            end
                        end
                    end
                
                    sortedListOfReads{activeReadIndex}.setMeasurements(measurements);
                    sortedListOfReads{activeReadIndex}.setWellIDs(wellID);
                    sortedListOfReads{activeReadIndex}.setTimepoints(time);
                    sortedListOfReads{activeReadIndex}.setTemperature(temperature);
                    sortedListOfReads{activeReadIndex}.channels = channelNames;
                    sortedListOfReads{activeReadIndex}.removeUnmeasuredWells();
                    
                    clear measurements time temperature
                elseif strcmp(sortedListOfReads{activeReadIndex}.readType, 'Image Endpoint')||strcmp(sortedListOfReads{activeReadIndex}.readType, 'Image Montage')
                    channelNames = cell(0, 0);
                    this.goToBeginningOfTheFile();
                    startingLine = sortedListOfReads{activeReadIndex}.firstLineOfMeasurements;
                    endingLine = sortedListOfReads{activeReadIndex}.lastLineOfMeasurements;
                    this.skipLines(startingLine - 1);
                    measurementLineExpected = 0;
                    activeChannel = 0;
                    timePoint = 0;
                    startNotFound = 1;
                    if sortedListOfReads{activeReadIndex}.isKineticRead
                        for lineIndex = startingLine : endingLine
                            line = this.getNextLine();
                            if this.lineIsNotEmpty(line)&&(isequal(strfind(line, 'Time'), []))&&startNotFound
                                timePoint = 0;
                                channelNames{end + 1} = regexprep(line, sortedListOfReads{activeReadIndex}.readName, '');
                                activeChannel = activeChannel + 1;
                            elseif strfind(line, 'Time')                                
                                scrap = textscan(line, '%s %*[^\n]','delimiter', '\t');
                                line = regexprep(line, scrap{1,1}, '', 'once');
                                line = regexprep(line, '\t', '', 'once');
                                well = 0;
                                wellID = cell(0, 0);
                                while (size(line, 2) > 0)
                                    well = well + 1;
                                    tempID = textscan(line, '%s %*[^\n]','delimiter', '\t');
                                    line = regexprep(line, tempID{1,1}, '', 'once');
                                    line = regexprep(line, '\t', '', 'once');
                                    wellID{end + 1} = tempID{1,1};    
                                end
                                measurementLineExpected = 1;
                                startNotFound = 0;
                            elseif measurementLineExpected
                                if this.lineIsNotEmpty(line) && this.lineIsNotZero(line);
                                    timePoint = timePoint + 1;
                                    if strfind(line, 'variable')                                        
                                        line = regexprep(line, 'variable', '');
                                        line = regexprep(line, '\t', '', 'once');
                                    else
                                        tempCellValueOfTime = textscan(line, '%s %*[^\n]','delimiter', '\t');
                                        time(timePoint) = str2double(tempCellValueOfTime{1, 1});
                                        line = regexprep(line, tempCellValueOfTime{1, 1}, '', 'once');
                                        line = regexprep(line, '\t', '', 'once');
                                    end
                                    wellIndex = 0;
                                    while (size(line, 2)>0 && ~strcmp(line,''))
                                        wellIndex = wellIndex + 1;
                                        tempMeasurement = textscan(line, '%s %*[^\n]','delimiter', '\t');
                                        %disp(tempMeasurement);
                                        tempMeasurement{1, 1} = regexprep(tempMeasurement{1,1}, '\+', '\\+');
                                        tempMeasurement{1, 1} = regexprep(tempMeasurement{1,1}, '\?', '\\?');
                                        line = regexprep(line, tempMeasurement{1,1}, '', 'once');                                        
                                        line = regexprep(line, '\t', '', 'once');
                                        tempMeasurement{1, 1} = regexprep(tempMeasurement{1,1}, '\\', '');
                                        measurements(activeChannel, timePoint, wellIndex) = tempMeasurement{1,1};
                                        if strcmp(line, '')
                                            %measurements(activeChannel, timePoint, wellIndex + 1) = {''}; 
                                        end
                                    end 
                                 elseif isequal(timePoint, 0) 
                                     sortedListOfReads{activeReadIndex}.setReadWasEmpty('Yes');
                                     measurementLineExpected = 0;
                                     startNotFound = 1;
                                 else
                                    startNotFound = 1;
                                    measurementLineExpected = 0; 
                                 end
                            end
                        end
                    else %% the else case below is not functioning correctly for Gen5 2.09.1 version. Functionality not checked for other versions
                        time = 0;
                        timePoint = 1;
                        activeChannel = 0;
                        temperature = NaN;
                        
                        for lineIndex = startingLine : endingLine

                            line = this.getNextLine();
                            if size(strfind(line, sortedListOfReads{activeReadIndex}.readName), 1) && ~size(strfind(line, '	'), 1) % old comparator size(strfind(line, 'Read'), 1) && ~size(strfind(line, '	'), 1)
                                channelNames{end + 1} = regexprep(line, sortedListOfReads{activeReadIndex}.readName, '');                            
                            elseif this.lineIsNotEmpty(line) && ~size(strfind(line, '	'), 1)
                                channelNames{end + 1} = line;                               
                            elseif strfind(line, 'Actual Temperature:')
                                temperature = regexprep(line, 'Actual Temperature:	', '');
                                temperature = str2double(regexprep(temperature, ',','.'));
                                activeChannel = activeChannel + 1;
                            elseif size(strfind(line, 'Well'), 1) && ~size(strfind(line, 'ID'), 1)

                                activeChannel = activeChannel + 1;
                                temperature = NaN;

                                line = regexprep(line, 'Well	', '');
                                well = 0;
                                wellID = cell(0, 0);
                                while (size(line, 2) > 0)
                                    well = well + 1;
                                    tempID = textscan(line, '%s %*[^\n]','delimiter', '\t');
                                    line = regexprep(line, tempID{1,1}, '', 'once');
                                    line = regexprep(line, '\t', '', 'once');
                                    wellID{end + 1} = tempID{1,1};    
                                end
                                measurementLineExpected = 1;
                            elseif size(strfind(line, sortedListOfReads{activeReadIndex}.readName), 1) || measurementLineExpected % old comparator size(strfind(line, 'Read'), 1) || measurementLineExpected
                                measurementLineExpected = 0;
                                tempID = textscan(line, '%s %*[^\n]','delimiter', '\t');
                                % take regex special character ] into
                                % account since Neo channels may be
                                % [Parallel] or something similar
                                tempID{1}{1}=regexprep(tempID{1}{1}, ']', '\\\]');
                                line = regexprep(line, tempID{1,1}{1}, '', 'once');
                                line = regexprep(line, '\t', '', 'once');
                                wellIndex = 0;
                                while (size(line, 2)>0 && ~strcmp(line,''))
                                    wellIndex = wellIndex + 1;
                                    tempMeasurement = textscan(line, '%s %*[^\n]','delimiter', '\t');
                                    line = regexprep(line, regexptranslate('escape', tempMeasurement{1,1}), '', 'once');
                                    line = regexprep(line, '\t', '', 'once');
                                    try
                                        %if isequal(tempMeasurement{1,1}, {'?????'})
                                        %   tempMeasurement{1,1} = {NaN}; 
                                        %end
                                        measurements(activeChannel, timePoint, wellIndex) = tempMeasurement{1,1};
                                    catch MException
                                        try
                                            measurements(activeChannel, timePoint, wellIndex) = str2num(tempMeasurement{1,1}{1});
                                        catch
                                            measurements(activeChannel, timePoint, wellIndex) = {NaN};
                                        end
                                    end
                                    if strcmp(line, '')
                                        %measurements(activeChannel, timePoint, wellIndex + 1) = {''}; 
                                    end
                                end                            
                            end
                        end
                    end
                    
                    sortedListOfReads{activeReadIndex}.setWellIDs(wellID);
                    sortedListOfReads{activeReadIndex}.channels = channelNames;
                    
                    
                    if(sortedListOfReads{activeReadIndex}.numberOfCycles == timePoint)
                        
                        try
                            sortedListOfReads{activeReadIndex}.calculateTheoreticalTimepoints(timePoint);% this might have to be timpoint + 1 instead in some cases
                            sortedListOfReads{activeReadIndex}.setMeasurements(measurements);
                            sortedListOfReads{activeReadIndex}.setWellIDs(wellID);
                            sortedListOfReads{activeReadIndex}.channels = channelNames;
                            sortedListOfReads{activeReadIndex}.removeUnmeasuredWells();
                            clear measurements time temperature
                        catch MException
                            MException
                        end
                    elseif sortedListOfReads{activeReadIndex}.numberOfCycles <= timePoint
                        counter = 0;
                        while counter < timePoint
                            prevCounter = counter;
                            counter = counter + sortedListOfReads{activeReadIndex}.numberOfCycles;
                            sortedListOfReads{activeReadIndex}.calculateTheoreticalTimepoints(sortedListOfReads{activeReadIndex}.numberOfCycles);
                            sortedListOfReads{activeReadIndex}.setMeasurements(measurements(:,prevCounter+1 :counter,:));
                            sortedListOfReads{activeReadIndex}.setWellIDs(wellID);
                            sortedListOfReads{activeReadIndex}.channels = channelNames;
                            sortedListOfReads{activeReadIndex}.removeUnmeasuredWells();                           
                            activeReadIndex = activeReadIndex + 1;
                            
                        end
                        clear measurements time temperature
                    end
                end
            end
            
            activeReadIndex = 0;
            while activeReadIndex < this.totalNumberOfReads
                activeReadIndex = activeReadIndex + 1;
                if isequal(sortedListOfReads{activeReadIndex}.getIsAppendsIndex, 1) % this read will take it´s measurements from the first read of the append, no need to go through with the loop
                   leadingRead = sortedListOfReads{activeReadIndex}; 
                elseif sortedListOfReads{activeReadIndex}.getIsAppendsIndex > 1
                   measurements = leadingRead.getAndDeleteAppendMeasurements(sortedListOfReads{activeReadIndex}.getNumberOfCycles());
                   temperature = leadingRead.getAndDeleteAppendTemperatures(sortedListOfReads{activeReadIndex}.getNumberOfCycles());
                   time = leadingRead.getAndDeleteTimepoints(sortedListOfReads{activeReadIndex}.getNumberOfCycles());
                   %time = time - leadingRead.measurementTimepoints(end) - leadingRead.interval; % this subtraction will make the read such that it would be equivalent to the case when no append was used. The time between reads is still recorded in the measurement time data of the first read.
                   time = time - leadingRead.getCorrespondingTimepointForAppendSubtraction() - leadingRead.interval;              
                   if isequal(numel(measurements), 0) 
                       warndlg('One of the reads in appended kinetics has no associated measurements and has been removed.');
                       for kinetic = numel(this.kinetics):-1:1
                            index = find([this.kinetics{kinetic}.listOfReads{:}] == sortedListOfReads{activeReadIndex});
                            if ~isempty(index)
                                this.kinetics{kinetic}.listOfReads(index) = [];
                                if isequal(numel(this.kinetics{kinetic}.listOfReads), 0)
                                    this.kinetics(kinetic) = [];
                                end
                            end
                       end
                   else
                       sortedListOfReads{activeReadIndex}.setMeasurements(measurements);
                       sortedListOfReads{activeReadIndex}.setWellIDs(leadingRead.getWellIDs());
                       sortedListOfReads{activeReadIndex}.setTimepoints(time);
                       sortedListOfReads{activeReadIndex}.setTemperature(temperature);
                   end
                end
            end
        end
        
        function mapMeasurementLines(this)
            warning('off', 'MATLAB:nonIntegerTruncatedInConversionToChar');
            sortedListOfReads = this.generateSortedListOfReads;
            this.goToBeginningOfTheFile();
            this.skipLines(this.lastLineOfHeader);
            currentLine = this.lastLineOfHeader;
            endOfFileReached = 0;
%             if exist('numberOfLines', 'var')
% 
%             else
%                 numberOfLines = inputdlg('Enter the number of lines per read');
%                 numberOfLines = str2num(numberOfLines{1});
%                 readNames = cell(numel(sortedListOfReads), 1);
%                 for i = 1 : numel(sortedListOfReads)
%                     readNames{i} = ['Read ', sortedListOfReads{i}.readName];
%                 end
%                 keepIndices = readRemover(readNames);
%                 keepReadsWithIndices(this, keepIndices);
%                 sortedListOfReads = this.generateSortedListOfReads();
%             end
            activeReadIndex = 0;
            while activeReadIndex < numel(sortedListOfReads)
                activeReadIndex = activeReadIndex + 1;
                if(activeReadIndex > numel(sortedListOfReads))
                   break;  % currently, number of reads may change upon user input so this is a quick failsafe
                end
                if(~strcmp(sortedListOfReads{activeReadIndex}.readType, 'Fluorescence Spectrum')) % the reader can´t read fluorescence spectrum type of tables yet
                    startStringNotFound = 1;
                    endStringNotFound = 1;
                    if activeReadIndex > 1
                        this.goToBeginningOfTheFile();
                        this.skipLines(sortedListOfReads{activeReadIndex - 1}.lastLineOfMeasurements);
                        currentLine = sortedListOfReads{activeReadIndex - 1}.lastLineOfMeasurements;
                    end
                    if sortedListOfReads{activeReadIndex}.isKineticRead 
                        while startStringNotFound
                            line = this.getNextLine();
                            currentLine = currentLine + 1;
                            if strfind(line, sortedListOfReads{activeReadIndex}.getReadName()) % old comparator ['Read ', num2str(activeReadIndex), ':']
                                startStringNotFound = 0;
                                sortedListOfReads{activeReadIndex}.firstLineOfMeasurements = currentLine;                               
                            elseif isequal(this.totalNumberOfReads, 1)
                                startStringNotFound = 0;
                                sortedListOfReads{activeReadIndex}.firstLineOfMeasurements = this.lastLineOfHeader + 2;
                            elseif strfind(line, 'Time') % this means that a read is actually on but the name was not detected. Ask user for manual conformation
                                startStringNotFound = 0;
                                sortedListOfReads{activeReadIndex}.firstLineOfMeasurements = currentLine - 2;  
                                %fseek(this.fileHandle, this.lineToByteArray(this.nextLine - 2), 'bof')
                            end
                        end

                        while endStringNotFound && this.nextLine <= this.lastLineOfFile
                            line = this.getNextLine();
                            currentLine = currentLine + 1;
                            if activeReadIndex < numel(sortedListOfReads) && ~isequal(line, -1)
                                if sortedListOfReads{activeReadIndex + 1}.isKineticRead || strcmp(sortedListOfReads{activeReadIndex + 1}.readType, 'Fluorescence Spectrum')
                                    if strfind(line, sortedListOfReads{activeReadIndex + 1}.getReadName()) % old comparator ['Read ', num2str(activeReadIndex + 1), ':']
                                        endStringNotFound = 0;
                                        sortedListOfReads{activeReadIndex}.lastLineOfMeasurements = currentLine - 2;
                                    end
                                else
                                    if strfind(line, sortedListOfReads{activeReadIndex + 1}.getReadName()) % old comparator ['Read ', num2str(activeReadIndex + 1), ':']
                                        endStringNotFound = 0;
                                        sortedListOfReads{activeReadIndex}.lastLineOfMeasurements = currentLine - 6;
                                    end
                                end
                            elseif isequal(line, -1) || isequal(this.nextLine, this.lastLineOfFile)    
                                endStringNotFound = 0; 
                                sortedListOfReads{activeReadIndex}.lastLineOfMeasurements = this.lastLineOfFile - 2;
                                endOfFileReached = 1;
                            else
                               endStringNotFound = 0; 
                               sortedListOfReads{activeReadIndex}.lastLineOfMeasurements = this.lastLineOfFile - 2;
                            end
                        end                   
                    else
                        if exist('result', 'var')
                            
                        else
                            result = questdlg('Do you want to open advanced settings for mapping. This may be required for Cytation5 files.');
                        end
                        if strcmp(result, 'No')
                            while startStringNotFound
                                line = this.getNextLine();
                                currentLine = currentLine + 1;
                                if strfind(line, 'Actual Temperature')
                                    startStringNotFound = 0;
                                end
                            end
                            sortedListOfReads{activeReadIndex}.firstLineOfMeasurements = currentLine;
                            while endStringNotFound && this.nextLine <= this.lastLineOfFile
                                line = this.getNextLine();
                                currentLine = currentLine + 1;
                                if activeReadIndex < numel(sortedListOfReads) && ~isequal(line, -1)
                                    if sortedListOfReads{activeReadIndex + 1}.isKineticRead || strcmp(sortedListOfReads{activeReadIndex + 1}.readType, 'Fluorescence Spectrum')
                                        if strfind(line, sortedListOfReads{activeReadIndex + 1}.getReadName()) % old comparator ['Read ', num2str(activeReadIndex + 1), ':']
                                            endStringNotFound = 0;
                                            sortedListOfReads{activeReadIndex}.lastLineOfMeasurements = currentLine - 2;
                                        end
                                    else
                                        if strfind(line, sortedListOfReads{activeReadIndex + 1}.getReadName()) % old comparator ['Read ', num2str(activeReadIndex + 1), ':']
                                            endStringNotFound = 0;
                                            sortedListOfReads{activeReadIndex}.lastLineOfMeasurements = currentLine - 6;
                                        end
                                    end
                                elseif isequal(line, -1) || isequal(this.nextLine, this.lastLineOfFile)     
                                   endStringNotFound = 0; 
                                   sortedListOfReads{activeReadIndex}.lastLineOfMeasurements = this.lastLineOfFile - 2; 
                                   endOfFileReached = 1;
                                else
                                   endStringNotFound = 0; 
                                   sortedListOfReads{activeReadIndex}.lastLineOfMeasurements = this.lastLineOfFile - 2;
                                end
                            end                   
                        
                        elseif strcmp(result, 'Yes')
                            if exist('numberOfLines', 'var')
                                
                            else
                                numberOfLines = inputdlg('Enter the number of lines per read');
                                numberOfLines = str2num(numberOfLines{1});
                                readNames = cell(numel(sortedListOfReads), 1);
                                for i = 1 : numel(sortedListOfReads)
                                    readNames{i} = ['Read ', sortedListOfReads{i}.readName];
                                end
                                keepIndices = readRemover(readNames);
                                keepReadsWithIndices(this, keepIndices);
                                sortedListOfReads = this.generateSortedListOfReads();
                            end
                            sortedListOfReads{activeReadIndex}.firstLineOfMeasurements = currentLine+1;
                            currentLine = currentLine + numberOfLines - 1;
                            sortedListOfReads{activeReadIndex}.lastLineOfMeasurements = currentLine+1;
                            currentLine =  currentLine + 1;                        
                        end
                    end
                else
                    startStringNotFound = 1;
                    endStringNotFound = 1;
                    
                    if activeReadIndex > 1
                        this.goToBeginningOfTheFile();
                        this.skipLines(sortedListOfReads{activeReadIndex - 1}.lastLineOfMeasurements);
                        currentLine = sortedListOfReads{activeReadIndex - 1}.lastLineOfMeasurements;
                    end
                    
                    while startStringNotFound                      
                        line = this.getNextLine();
                        currentLine = currentLine + 1;
                        if strfind(line, sortedListOfReads{activeReadIndex}.getReadName()) % old comparator ['Read ', num2str(activeReadIndex), ':']
                            startStringNotFound = 0;
                            sortedListOfReads{activeReadIndex}.firstLineOfMeasurements = currentLine;
                        elseif isequal(this.totalNumberOfReads, 1)
                            startStringNotFound = 0;
                            sortedListOfReads{activeReadIndex}.firstLineOfMeasurements = this.lastLineOfHeader + 2;
                        end
                    end
                    
                    while endStringNotFound && this.nextLine <= this.lastLineOfFile
                        line = this.getNextLine();
                        currentLine = currentLine + 1;
                        if activeReadIndex < numel(sortedListOfReads) && ~isequal(line, -1)
                            if sortedListOfReads{activeReadIndex + 1}.isKineticRead || strcmp(sortedListOfReads{activeReadIndex + 1}.readType, 'Fluorescence Spectrum')
                                if strfind(line, sortedListOfReads{activeReadIndex + 1}.getReadName()) % old comparator ['Read ', num2str(activeReadIndex + 1), ':']
                                    endStringNotFound = 0;
                                    sortedListOfReads{activeReadIndex}.lastLineOfMeasurements = currentLine - 2;
                                end
                            else
                                if strfind(line, sortedListOfReads{activeReadIndex + 1}.getReadName()) % old comparator ['Read ', num2str(activeReadIndex + 1), ':']
                                    endStringNotFound = 0;
                                    sortedListOfReads{activeReadIndex}.lastLineOfMeasurements = currentLine - 6;
                                end
                            end
                        elseif isequal(line, -1) || isequal(this.nextLine, this.lastLineOfFile)    
                           endStringNotFound = 0; 
                           sortedListOfReads{activeReadIndex}.lastLineOfMeasurements = this.lastLineOfFile - 2;
                           endOfFileReached = 1;
                        else
                           endStringNotFound = 0; 
                           sortedListOfReads{activeReadIndex}.lastLineOfMeasurements = this.lastLineOfFile - 2;
                        end
                    end
                end
                sortedListOfReads{activeReadIndex}.calculateCyclesByLineCount();
                if(~isequal(sortedListOfReads{activeReadIndex}.cyclesByLineCount, sortedListOfReads{activeReadIndex}.numberOfCycles)) && numel(sortedListOfReads) > 1 && ~strcmp(sortedListOfReads{activeReadIndex}.getReadType(), 'Fluorescence Spectrum')
                   % this read starts an appended list of reads
                   sortedListOfReads{activeReadIndex}.setIsAppendsIndex(1);
                   extraCycles = sortedListOfReads{activeReadIndex}.cyclesByLineCount - sortedListOfReads{activeReadIndex}.numberOfCycles;
                   counter = 1;
                   for checkReadIndex = activeReadIndex + 1 : numel(sortedListOfReads)
                       if ( sortedListOfReads{checkReadIndex}.numberOfCycles < extraCycles)
                           extraCycles = extraCycles - sortedListOfReads{checkReadIndex}.numberOfCycles;
                           counter = counter + 1;
                           sortedListOfReads{checkReadIndex}.setIsAppendsIndex(counter);
                           
                       elseif isequal(sortedListOfReads{checkReadIndex}.numberOfCycles, extraCycles)
                           extraCycles = extraCycles - sortedListOfReads{checkReadIndex}.numberOfCycles;
                           counter = counter + 1;
                           sortedListOfReads{checkReadIndex}.setIsAppendsIndex(counter);
                           break;
                       else
                          error('Could not process file. Reads in append do not match up'); 
                       end
                   end
                   if ~(isequal(extraCycles, 0) || strcmp(sortedListOfReads{activeReadIndex}.getReadType(), 'Image Montage'))
                      error('Could not process file. Reads in append do not match up') 
                   end                  
                   activeReadIndex = activeReadIndex + counter - 1;
                end
                if isequal(endOfFileReached, 1)
                   break; 
                end
                
            end
            warning('on', 'MATLAB:nonIntegerTruncatedInConversionToChar');
        end
        
        function sortedListOfReads = generateSortedListOfReads(this)
            listOfReads = cell(0, 0);
            for kineticIndex = 1 : numel(this.kinetics)
                listOfReads = [listOfReads, this.kinetics{kineticIndex}.listOfReads]; 
            end
            listOfReads = [listOfReads, this.reads];
            sortedListOfReads = cell(0, 0);
            for kineticIndex = 1 : numel(listOfReads)               
               sortedListOfReads{listOfReads{kineticIndex}.orderIndex} = listOfReads{kineticIndex}; 
            end
        end
        
        function keepReadsWithIndices(this, keepIndices)
            indices = 1:numel(this.generateSortedListOfReads());
            indices(keepIndices) = [];
            listOfReads = cell(0, 0);
            for kineticIndex = 1 : numel(this.kinetics)
                listOfReads = [listOfReads, this.kinetics{kineticIndex}.listOfReads];
                for i = 1 : numel(indices)
                   for j = 1 : numel(this.kinetics{kineticIndex}.listOfReads)
                      if isequal(this.kinetics{kineticIndex}.listOfReads{j}.orderIndex, indices(i))
                        this.kinetics{kineticIndex}.listOfReads(j) = [];
                        break;
                      end
                   end
                end
            end
            listOfReads = [listOfReads, this.reads];
            for i = 1 : numel(indices)
               for j = 1 : numel(this.reads)
                  if isequal(this.reads{j}.orderIndex, indices(i))
                    this.reads(j) = [];
                    break;
                  end
               end
            end
            for j = 1 : numel(this.reads)
                this.reads{j}.orderIndex = j;
            end
            this.totalNumberOfReads = numel(this.reads);
        end
        
        function isNotEmpty = lineIsNotEmpty(this, line)
            isNotEmpty = ~strcmp(line, ''); 
        end   
        
        function isNotZero = lineIsNotZero(this, line)
           line = regexprep(line, '	', '');
           isNotZero = ~strcmp(line, '0'); 
        end
        
        function skipLines(this, linesToSkip)
            for line = 1 : linesToSkip
                this.getNextLine();
            end
        end
        
        function goToBeginningOfTheFile(this)
            fseek(this.fileHandle, 0, 'bof');
            this.nextLine = 1;
        end                     
        
        function initializeFileHandle(this)
           this.fileHandle = fopen(this.fileName,'r', 'b');
           this.nextLine = 1;
        end       
        
        function line = getNextLine(this)
            line = fgetl(this.fileHandle);
            this.nextLine = this.nextLine + 1;
        end
        
        function result = notAtEndOfTheFile(this, line)
           if isequal(line, -1)
               result = 0;
           else
               result = 1;
           end
        end
        
        function calculateFastKinetics(this)
            try
                this.experimentDataStructure.timeOfFastKineticsMeasurements = fastKineticsCalculator(this.experimentDataStructure.wellID', this.experimentDataStructure.readingDirection, this.experimentDataStructure.cycleTime, this.experimentDataStructure.timeOfMeasurements')';
            catch
                
            end
        end
        
        function generateExperimentDataStructure(this)
            overflowStruct = [];
            if isequal(this.totalNumberOfReads, 1)
               sortedListOfReads = this.generateSortedListOfReads();
               read = sortedListOfReads{1};
               rawWellID = read.wellID;
               for wellIndex = 1 : numel(rawWellID)
                    wellID{wellIndex} = rawWellID{wellIndex}{1}; 
               end
               this.experimentDataStructure.numberOfChannels = numel(read.channels);
               this.experimentDataStructure.wellID = wellID;
               this.experimentDataStructure.cycleTime = read.interval;
               this.experimentDataStructure.timeOfMeasurements = read.measurementTimepoints';
               this.experimentDataStructure.channelNames = read.channels;
               this.experimentDataStructure.timeOfFastKineticsMeasurements = fastKineticsCalculator(wellID', 11 , read.interval, read.measurementTimepoints)';
               measurements = read.measurements;
               for wellIndex = 1 : numel(read.wellID)
                   rawWellMeasurements = measurements(:, :, wellIndex);
                   reshapedWellMeasurements = reshape(rawWellMeasurements, numel(rawWellMeasurements), 1);
                   measurementsAsDouble = zeros(numel(reshapedWellMeasurements), 1);
                   for measurementNumber = 1 : numel(reshapedWellMeasurements)
                      if strcmp(reshapedWellMeasurements{measurementNumber}, 'OVRFLW')
                        measurementsAsDouble(measurementNumber) = NaN;  
                        overflowStruct{end + 1} = [read.wellID{wellIndex}{1} ,'at read 1 ', 'at cycle ', num2str(floor(measurementNumber/numel(read.channels))+1)];
                      elseif ~isempty(strfind(reshapedWellMeasurements{measurementNumber},'>'))
                        measurementsAsDouble(measurementNumber) = NaN;  
                        overflowStruct{end + 1} = [read.wellID{wellIndex}{1} ,'at read 1 ', 'at cycle ', num2str(floor(measurementNumber/numel(read.channels))+1)]; 
                      else
                        measurementsAsDouble(measurementNumber) = str2double(regexprep(reshapedWellMeasurements{measurementNumber}, ',', '.'));
                      end
                   end
                   this.experimentDataStructure.measurements{wellIndex} = measurementsAsDouble;
               end
            else
                sortedListOfReads = this.generateSortedListOfReads();
                experimentDataStructureArray = cell(0, 0);
                legalReadIndex = 0;
                deleteReads = zeros(1, 0);
                for readIndex = 1 : numel(sortedListOfReads)
                    if(~strcmp(sortedListOfReads{readIndex}.readType, 'Fluorescence Spectrum'))
                        legalReadIndex = legalReadIndex + 1;
                        read = sortedListOfReads{readIndex};
                        rawWellID = read.wellID;
                        wellID = cell(1, 0);
                        for wellIndex = 1 : numel(rawWellID)
                             wellID{wellIndex} = rawWellID{wellIndex}{1}; 
                        end
                        experimentDataStructureArray{legalReadIndex}.readWasEmpty = read.getReadWasEmpty;
                        experimentDataStructureArray{legalReadIndex}.numberOfChannels = numel(read.channels);
                        experimentDataStructureArray{legalReadIndex}.wellID = wellID;
                        experimentDataStructureArray{legalReadIndex}.cycleTime = read.interval;
                        experimentDataStructureArray{legalReadIndex}.runtime = read.runtime;
                        experimentDataStructureArray{legalReadIndex}.timeOfMeasurements = read.measurementTimepoints';
                        if ~isempty(read.measurementTimepoints)
                             experimentDataStructureArray{legalReadIndex}.timeOfFastKineticsMeasurements = fastKineticsCalculator(wellID', 11 , read.interval, read.measurementTimepoints)';
                        else
                            try
                                experimentDataStructureArray{legalReadIndex}.timeOfFastKineticsMeasurements = fastKineticsCalculator(wellID', 11 , read.interval, 0)';
                            catch
                                'siin' 
                            end
                        end
                        experimentDataStructureArray{legalReadIndex}.channelNames = read.channels;
                        measurements = read.measurements;
                        for wellIndex = 1 : numel(read.wellID)
                            rawWellMeasurements = measurements(:, :, wellIndex);
                            reshapedWellMeasurements = reshape(rawWellMeasurements, numel(rawWellMeasurements), 1);
                            measurementsAsDouble = zeros(numel(reshapedWellMeasurements), 1);
                            for measurementNumber = 1 : numel(reshapedWellMeasurements)
                                if strcmp(reshapedWellMeasurements{measurementNumber}, 'OVRFLW')
                                    measurementsAsDouble(measurementNumber) = NaN; 
                                    overflowStruct{end + 1} = [read.wellID{wellIndex}{1},' at read ', num2str(legalReadIndex), ' at cycle ', num2str(floor(measurementNumber/numel(read.channels))+1)];
                                else
                                    measurementsAsDouble(measurementNumber) = str2double(regexprep(reshapedWellMeasurements{measurementNumber}, ',', '.')); 
                                end
                            end
                            experimentDataStructureArray{legalReadIndex}.measurements{wellIndex} = measurementsAsDouble;
                       end
                   else
                       deleteReads(end + 1) = readIndex;                       
                   end
               end 
               sortedListOfReads(deleteReads) = [];
               [this.experimentDataStructure, this.stopwatchTimes, this.stopwatchLabels] = ReadHandler(experimentDataStructureArray, sortedListOfReads, this.kinetics, this.reads, this.stopwatchTimes, this.stopwatchLabels);
               if ~isequal(overflowStruct, [])
                    ShowOverflow(overflowStruct);
               end
            end
            
        end
        
        function dataStructure = getExperimentDataStructure(this)
            dataStructure = this.experimentDataStructure;
        end
        
        function setStopwatchTimes(this, stopwatchTimes)
           this.stopwatchTimes = stopwatchTimes; 
        end
        
        function stopwatchTimes = getStopwatchTimes(this)
           stopwatchTimes = this.stopwatchTimes; 
        end
        
        function setStopwatchLabels(this, stopwatchLabels)
           this.stopwatchLabels = stopwatchLabels;
        end
        
        function stopwatchLabels = getStopwatchLabels(this)
           stopwatchLabels = this.stopwatchLabels;
        end
    end
    
    methods(Static)
        function [experimentDataStructure, stopwatchTimes, stopwatchLabels] = generateExperimentDataStructureFromArray(NeoASCIIReaders)
            experimentDataStructureArrayArray = cell(numel(NeoASCIIReaders), 1);
            sortedListOfReadsArray = cell(numel(NeoASCIIReaders), 1);
            kineticsArray = cell(numel(NeoASCIIReaders), 1);
            readsArray = cell(numel(NeoASCIIReaders), 1);
            stopwatchTimesArray = cell(numel(NeoASCIIReaders), 1);
            stopwatchLabelsArray = cell(numel(NeoASCIIReaders), 1);
            
            for readerIndex = 1 : numel(NeoASCIIReaders)
                this = NeoASCIIReaders{readerIndex};
                overflowStruct = [];
                if isequal(this.totalNumberOfReads, 1)
                   experimentDataStructureArray = cell(1,1);
                   sortedListOfReads = this.generateSortedListOfReads();
                   read = sortedListOfReads{1};
                   rawWellID = read.wellID;
                   for wellIndex = 1 : numel(rawWellID)
                        wellID{wellIndex} = rawWellID{wellIndex}{1}; 
                   end
                   experimentDataStructureArray{1}.numberOfChannels = numel(read.channels);
                   experimentDataStructureArray{1}.wellID = wellID;
                   experimentDataStructureArray{1}.cycleTime = read.interval;
                   experimentDataStructureArray{1}.timeOfMeasurements = read.measurementTimepoints';
                   experimentDataStructureArray{1}.channelNames = read.channels;
                   experimentDataStructureArray{1}.timeOfFastKineticsMeasurements = fastKineticsCalculator(wellID', 11 , read.interval, read.measurementTimepoints)';
                   experimentDataStructureArray{1}.readWasEmpty = read.getReadWasEmpty;
                   experimentDataStructureArray{1}.runtime = read.runtime;
                   measurements = read.measurements;
                   for wellIndex = 1 : numel(read.wellID)
                       rawWellMeasurements = measurements(:, :, wellIndex);
                       reshapedWellMeasurements = reshape(rawWellMeasurements, numel(rawWellMeasurements), 1);
                       measurementsAsDouble = zeros(numel(reshapedWellMeasurements), 1);
                       for measurementNumber = 1 : numel(reshapedWellMeasurements)
                          if strcmp(reshapedWellMeasurements{measurementNumber}, 'OVRFLW')
                            measurementsAsDouble(measurementNumber) = NaN;  
                            overflowStruct{end + 1} = [read.wellID{wellIndex}{1} ,'at read 1 ', 'at cycle ', num2str(floor(measurementNumber/numel(read.channels))+1)];
                          elseif ~isempty(strfind(reshapedWellMeasurements{measurementNumber},'>'))
                            measurementsAsDouble(measurementNumber) = NaN;  
                            overflowStruct{end + 1} = [read.wellID{wellIndex}{1} ,'at read 1 ', 'at cycle ', num2str(floor(measurementNumber/numel(read.channels))+1)]; 
                          else
                            measurementsAsDouble(measurementNumber) = str2double(reshapedWellMeasurements{measurementNumber}); 
                          end
                       end
                       
                       experimentDataStructureArray{1}.measurements{wellIndex} = measurementsAsDouble;
                   end
                   experimentDataStructureArrayArray{readerIndex} = experimentDataStructureArray;
                   sortedListOfReadsArray{readerIndex} = sortedListOfReads;
                   kineticsArray{readerIndex} = this.kinetics;
                   readsArray{readerIndex} = this.reads;
                   stopwatchTimesArray{readerIndex} = this.stopwatchTimes;
                   stopwatchLabelsArray{readerIndex} = this.stopwatchLabels;
               
                else
                   sortedListOfReads = this.generateSortedListOfReads();
                   experimentDataStructureArray = cell(numel(sortedListOfReads), 1);
                   legalReadIndex = 0;
                   deleteReads = zeros(1, 0);
                   for readIndex = 1 : numel(sortedListOfReads)
                       if(~strcmp(sortedListOfReads{readIndex}.readType, 'Fluorescence Spectrum'))
                           legalReadIndex = legalReadIndex + 1;
                           read = sortedListOfReads{readIndex};
                           rawWellID = read.wellID;
                           wellID = cell(1, 0);
                           for wellIndex = 1 : numel(rawWellID)
                                wellID{wellIndex} = rawWellID{wellIndex}{1}; 
                           end
                           experimentDataStructureArray{legalReadIndex}.readWasEmpty = read.getReadWasEmpty;
                           experimentDataStructureArray{legalReadIndex}.numberOfChannels = numel(read.channels);
                           experimentDataStructureArray{legalReadIndex}.wellID = wellID;
                           experimentDataStructureArray{legalReadIndex}.cycleTime = read.interval;
                           experimentDataStructureArray{legalReadIndex}.runtime = read.runtime;
                           experimentDataStructureArray{legalReadIndex}.timeOfMeasurements = read.measurementTimepoints';
                           if ~isempty(read.measurementTimepoints)
                                experimentDataStructureArray{legalReadIndex}.timeOfFastKineticsMeasurements = fastKineticsCalculator(wellID', 11 , read.interval, read.measurementTimepoints)';
                           else
                               try
                                experimentDataStructureArray{legalReadIndex}.timeOfFastKineticsMeasurements = fastKineticsCalculator(wellID', 11 , read.interval, 0)';
                               catch
                                  'siin' 
                               end
                           end
                           experimentDataStructureArray{legalReadIndex}.channelNames = read.channels;
                           measurements = read.measurements;
                           for wellIndex = 1 : numel(read.wellID)
                               rawWellMeasurements = measurements(:, :, wellIndex);
                               reshapedWellMeasurements = reshape(rawWellMeasurements, numel(rawWellMeasurements), 1);
                               measurementsAsDouble = zeros(numel(reshapedWellMeasurements), 1);
                               for measurementNumber = 1 : numel(reshapedWellMeasurements)
                                  if strcmp(reshapedWellMeasurements{measurementNumber}, 'OVRFLW')
                                    measurementsAsDouble(measurementNumber) = NaN; 
                                    overflowStruct{end + 1} = [read.wellID{wellIndex}{1},' at read ', num2str(legalReadIndex), ' at cycle ', num2str(floor(measurementNumber/numel(read.channels))+1)];
                                  else
                                    measurementsAsDouble(measurementNumber) = str2double(reshapedWellMeasurements{measurementNumber}); 
                                  end
                               end
                               experimentDataStructureArray{legalReadIndex}.measurements{wellIndex} = measurementsAsDouble;

                           end
                       else
                           deleteReads(end + 1) = readIndex;                       
                       end
                   end 
                   sortedListOfReads(deleteReads) = [];
                   
                   experimentDataStructureArrayArray{readerIndex} = experimentDataStructureArray;
                   sortedListOfReadsArray{readerIndex} = sortedListOfReads';
                   kineticsArray{readerIndex} = this.kinetics'; 
                   readsArray{readerIndex} = this.reads';
                   stopwatchTimesArray{readerIndex} = this.stopwatchTimes;
                   stopwatchLabelsArray{readerIndex} = this.stopwatchLabels;
                   
                   
                   if ~isequal(overflowStruct, [])
                        ShowOverflow(overflowStruct);
                   end
                end
                
            end
            [experimentDataStructure, stopwatchTimes, stopwatchLabels] = ReadHandler(vertcat(experimentDataStructureArrayArray{:}), vertcat(sortedListOfReadsArray{:}), vertcat(kineticsArray{:}), vertcat(readsArray{:}), vertcat(stopwatchTimesArray{:}), vertcat(stopwatchLabelsArray{:}));

        end
    end
    
end