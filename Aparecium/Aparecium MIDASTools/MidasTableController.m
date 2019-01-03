classdef MidasTableController < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    
    % kasuta kindlasti ära concat meetodeid stiilis data =
    % [data(1:6),newDawa,data(7:end)] et mugavamalt ilma for loopita lisada
    % ridu ja veerge
    properties
        rawExperimentData;
        fileName;
        columnHeaders = {'ID:plate', 'ID:well', 'DA:ALL', 'DV:Channel1', 'DV:Channel2'};
        tableData = {'', '', '', '' ,''};
        eventData = [];
        midasTableHandle;
        informativeColumns = 2;
        treatmentColumns = 0;
        timeColumns = 1;
        measurementColumns = 2;
        inputTimeUnit = 's';
        outputTimeUnit = 's';
        timeShift = 0;
        includeEvents = 0;
        treatmentStructure = [];
        activeUpdate = 'on';
        rawExcelNumericalData = [];
        fullFilePath = [];
        isExampleTable = false;
        
    end
    
    properties (SetAccess = private)
        MIDASMode = 'DA:ALL' % Enum, can be 'DA:ALL' or 'Standard'
    end
    
    methods
        
        function this = MidasTableController(midasTableHandle)
            if isequal(midasTableHandle, 'empty')
                this.activeUpdate = 'off';
            elseif isequal(midasTableHandle, 'example')
                this.activeUpdate = 'off';
                this.isExampleTable = true;
            else
                this.midasTableHandle = midasTableHandle;
            end
        end  
        
        function startWithOneMeasurementColumn(this)
            this.columnHeaders = {'ID:plate', 'ID:well', 'DA:ALL', 'DV:Channel1'};
            this.tableData = {'', '', '', ''};
            this.measurementColumns = 1;
            this.treatmentColumns = 0;
        end
        
        function startWithOneMeasurementColumnOneTreatmentColumn(this)
            this.columnHeaders = {'ID:plate', 'ID:well', 'TR:_' 'DA:ALL', 'DV:Channel1'};
            this.tableData = {'', '', '', ''};
            this.measurementColumns = 1;
            this.treatmentColumns = 1;
        end
        
        function setActiveUpdateOff(this)
           this.activeUpdate = 'off'; 
        end
        
        function data = getColumnData(this, index)
           data = this.tableData(:, index);
        end
        
        function data = getEventTableColumnData(this, index)
           data = this.eventData(:, index);
        end
        
        function setMidasTableHandle(this, midasTableHandle)
            this.midasTableHandle = midasTableHandle;
             this.activeUpdate = 'on';
        end
        
        function setEventDataEqualToData(this)
            if ~this.includeEvents;
                this.eventData = this.tableData;               
            else

            end
            % New version
            this.rawExcelNumericalData = cell2mat(this.eventData(:, this.informativeColumns + 1:end));
            
            % OLDER VERSION, Very slow for large dataset
%             columns = size(this.eventData(:, this.informativeColumns + 1:end), 1);
%             rows = size(this.eventData(:, this.informativeColumns + 1:end), 2);
%             for a = 1 : columns
%                 for b = 1 : rows
%                     if isempty(this.eventData{a, this.informativeColumns + b})
%                         this.rawExcelNumericalData(a, b) = NaN;
%                     else
%                         this.rawExcelNumericalData(a, b) = this.eventData{a, this.informativeColumns + b};
%                     end
%                 end
%             end    
        end
        
        function setDataEqualToEventData(this)
            % use with caution
            this.tableData = this.eventData;
        end
           
        function recalculateTimeShift(this, timeShift)
           this.timeShift = timeShift;
           this.recalculateTimeUnits(this.inputTimeUnit, this.outputTimeUnit);
        end
        
        function recalculateTimeUnits(this, inputUnit, outputUnit)
            this.inputTimeUnit = inputUnit;
            this.outputTimeUnit = outputUnit;
            timeMoments = cell2mat(this.rawExperimentData(:, 3));
            timeMoments = timeMoments + this.timeShift;
            switch inputUnit
                case 'ms'
                    timeMoments = timeMoments/1000;
                case 's'

                case 'min' 
                    timeMoments = timeMoments*60;
                case 'm'
                    timeMoments = timeMoments*60;
                case 'h'
                    timeMoments = timeMoments*3600;
            end
            %%%%%%%%%%%%%%%%%% IMPRTANT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %since MIDAS format by default does not allow to use units for
            %time conveniently then in MIDAS file no unit is used and
            %second as the SI base unit for time is always used.
            outputUnit = 's';
            switch outputUnit
                case 'ms'
                    timeMoments = timeMoments*1000;
                case 's'

                case 'min' 
                    timeMoments = timeMoments/60;
                case 'm'
                    timeMoments = timeMoments/60;
                case 'h'
                    timeMoments = timeMoments/3600;
            end
            timeMoments = num2cell(timeMoments);
            this.updateTimeColumn(timeMoments);
        end
        
        function updateTimeColumn(this, timeMoments)
            this.tableData(:, this.informativeColumns + this.treatmentColumns + 1) = timeMoments;
            if this.includeEvents;
                this.useEvents();
            else
                this.addData();
            end
        end
        
        function useSlowKinetics(this)
            
        end
        
        function useFastKinetics(this)
            
        end
        
        function setTimeUnit(this, unit)
            %warndlg('MIDAS now allows only the use of second as time unit. Time unit in MIDAS is assumed to be second at all times and no fruther unit is added')
            this.columnHeaders{this.informativeColumns + this.treatmentColumns + 1} = 'DA:ALL';
            %this.columnHeaders{this.informativeColumns + this.treatmentColumns + 1} = ['DA:All_', unit];
            %this.updateHeader();
        end
        
        function changeTreatmentHeader(this, name, treatmentIndex, unit)
            this.columnHeaders{treatmentIndex + this.informativeColumns} = ['TR:',name,'_', unit];
            this.addData();
        end
        
        function headers = getColumnHeaders(this)
            headers = this.columnHeaders;
        end
        
        function wellID = getWellID(this)
            for columnIndex = 1 : this.informativeColumns
                if strcmp(this.columnHeaders{columnIndex}, 'ID:well')
                   wellIDColIndex = columnIndex;
                   break;
                end             
            end
            wellID = unique(this.eventData(:,wellIDColIndex));
        end
        
        function changeChannelHeader(this, name, channelIndex)
            this.columnHeaders{channelIndex + this.informativeColumns + this.treatmentColumns + this.timeColumns} = ['DV:',name];
            this.addData();
        end
        
        function deleteChannelHeader(this, channelIndex)
            try
                this.columnHeaders(channelIndex + this.informativeColumns + this.treatmentColumns + this.timeColumns) = [];
            catch MException
                if strcmp(MException.identifier, 'MATLAB:subsdeldimmismatch')
                    
                else
                   rethrow(MException) 
                end
            end
        end
        
        function changePlateName(this, plateName)
            this.tableData(:,1) = {plateName};
            this.addData();
        end
  
        function addTreatmentColumn(this, treatmentName, treatmentIndex, treatmentUnit)
            if isequal(treatmentIndex, '')
               treatmentIndex = this.informativeColumns + this.treatmentColumns + 1;  
            end
            emptyColumn = cell(size(this.tableData, 1),1);
            emptyColumn(:,:) = {0};
            this.tableData = [this.tableData(:, 1 : treatmentIndex-1), emptyColumn, this.tableData(:, treatmentIndex : end)];
            this.columnHeaders = [this.columnHeaders(1 : treatmentIndex-1),['TR:' ,treatmentName,'_',treatmentUnit], this.columnHeaders(treatmentIndex : end)]; 

            this.treatmentColumns = this.treatmentColumns + 1;

            this.addData();            
        end
        
        function deleteTreatmentColumnByName(treatmentName)
            
        end
        
        function result = channelNamesAreValid(this)
           result = 1;
           for channelIndex = 1 : this.measurementColumns             
              channelName = this.columnHeaders{this.informativeColumns + this.treatmentColumns + this.timeColumns + channelIndex};
              channelName = regexprep(channelName,  'DV:', '');
              if ~isvarname(channelName)
                  result = 0;
                  break;
              end
           end
        end
        
        function deleteTreatmentColumnByIndex(this, treatmentIndex)
            this.columnHeaders(this.informativeColumns + treatmentIndex) = [];
            this.tableData(:, this.informativeColumns + treatmentIndex) = [];
            if ~isempty(this.eventData)
                this.eventData(:, this.informativeColumns + treatmentIndex) = [];
            end              
            this.treatmentColumns = this.treatmentColumns - 1;
            this.addData();
        end
        
        function deleteLastTreatmentColumn(this)
            this.columnHeaders(this.informativeColumns + this.treatmentColumns) = [];
            this.tableData(:, this.informativeColumns + this.treatmentColumns) = [];
            this.treatmentColumns = this.treatmentColumns - 1;
            this.addData();
        end
        
        function deleteTreatmentColumns(this)
            this.columnHeaders(this.informativeColumns+1 : this.informativeColumns + this.treatmentColumns) = [];
            this.tableData(this.informativeColumns+1 : this.informativeColumns + this.treatmentColumns) = [];
            this.treatmentColumns = 0;
            this.addData();
        end
        
        function setData(this, data)
            this.rawExperimentData = data;
            this.rawExperimentData(:,3) = [];
            this.tableData = data;
            this.addData();
        end
        
        function setFullMidasTable(this, headers, data)
            this.columnHeaders = headers;
            this.calculateColumnTypesFromHeader();
            this.eventData = data;
            this.addEventsData();
            this.includeEvents = 1;
        end
        
        function setNewTimeData(this, timeColumn)
            this.rawExperimentData(:, this.informativeColumns + 1) = timeColumn;
            this.recalculateTimeShift(this.timeShift);           
        end
        
        function data = getMidasTable(this)
            if this.includeEvents
                data = [this.columnHeaders; this.eventData];
            elseif ~this.includeEvents
                data = [this.columnHeaders; this.tableData];
            end
        end
        
        function updateHeader(this)
            set(this.midasTableHandle, 'columnName', this.columnHeaders);
        end
        
        function addData(this)
            if isequal(this.activeUpdate, 'on')
                set(this.midasTableHandle, 'columnName', this.columnHeaders);
                this.midasTableHandle.setData(this.tableData); 
            end
        end
        
        function showTable(this)
           if this.includeEvents
               this.addEventsData;
           elseif isequal(this.includeEvents, 0)
               this.addData; 
           end
        end
        
        function addEventsData(this)
            if isequal(this.activeUpdate, 'on')
                set(this.midasTableHandle, 'columnName', this.columnHeaders);
                this.midasTableHandle.setData(this.eventData); 
            end
        end
        
        function success = useEvents(this)
            if ~isempty(this.treatmentStructure)
                this.includeEvents = 1;         
                eventTimes = this.switchUnit(this.treatmentStructure.eventTimes);
                cycleBeginningTimes = this.calculateCycleBeginningTimes();
                eventBlocks = this.generateEventBlocks(eventTimes);
                this.eventData = this.tableData;
                noOfWells = numel(this.treatmentStructure.resultWells);
                for event = size(eventTimes, 1) : -1 : 1
                    eventFound = 0;
                    for cycleBeginningTime = size(cycleBeginningTimes, 1): -1 : 1
                       if eventTimes(event) > cycleBeginningTimes(cycleBeginningTime)
                           
                           this.eventData = [this.eventData(1 : cycleBeginningTime*noOfWells, :) ; eventBlocks{event}; this.eventData(cycleBeginningTime*noOfWells + 1 : end, :)];
                           eventFound = 1;
                           break;
                       end
                    end
                    if isequal(eventFound, 0)
                        this.eventData = [eventBlocks{event}; this.eventData(1 : end, :)];
                    end
                end
                cycleBeginningTimesWithEvents = sort([cycleBeginningTimes; eventTimes]);
                for event = 1 : size(eventTimes, 1)
                    for cycleBeginningTime = 1 : size(cycleBeginningTimesWithEvents, 1)
                        if eventTimes(event) == cycleBeginningTimesWithEvents(cycleBeginningTime)
                           treatmentData = eventBlocks{event}(:, this.informativeColumns + 1:this.informativeColumns + this.treatmentColumns);
                           for remainingBlocks = cycleBeginningTime + 1 : size(cycleBeginningTimesWithEvents, 1)
                              treatmentData = [treatmentData; eventBlocks{event}(:, this.informativeColumns + 1:this.informativeColumns+this.treatmentColumns)];
                           end
                           this.eventData( (cycleBeginningTime - 1)*noOfWells + 1 : end, this.informativeColumns + 1:this.informativeColumns+this.treatmentColumns)  = treatmentData;      
                        end
                    end
                end
                this.addEventsData();
                success = 1;
            else
               warndlg('No events are defined, use PlateSimulator to create events'); 
               success = 0;
            end
        end
        
        function eventBlocks = generateEventBlocks(this, eventTimes)
            wells = this.treatmentStructure.resultWells;
            plateName = this.tableData{1, 1};
            eventBlocks = cell(size(eventTimes, 1), 1);
            for event = 1 : size(eventTimes, 1)
               eventBlocks{event} = cell(1, this.informativeColumns + this.treatmentColumns + this.timeColumns + this.measurementColumns);
               for well = 1 : size(wells, 2)
                    treatments = num2cell(this.treatmentStructure.eventStruct{event}{well});
                    measurements = cell(1, this.measurementColumns);
                    measurements(1, :) = {NaN};
                    time = {eventTimes(event)};
                    column =[{plateName}, wells{well}, treatments, time, measurements]; 
                    eventBlocks{event} = [eventBlocks{event}; column];
               end
               eventBlocks{event}(1, :) = [];
            end
        end
        
        function timeMoments = switchUnit(this, timeMoments)
             switch this.inputTimeUnit
                case 'ms'
                    timeMoments = timeMoments/1000;
                case 's'

                case 'min' 
                    timeMoments = timeMoments*60;
                case 'h'
                    timeMoments = timeMoments*3600;
            end
            switch this.outputTimeUnit
                case 'ms'
                    timeMoments = timeMoments*1000;
                case 's'

                case 'min' 
                    timeMoments = timeMoments/60;
                case 'h'
                    timeMoments = timeMoments/3600;
            end 
        end
        
        function cycleBeginningTimes = calculateCycleBeginningTimes(this)
            noOfWells = numel(this.treatmentStructure.resultWells);
            time = this.tableData(:, this.informativeColumns + this.treatmentColumns + 1);
            cycleBeginningTimes = zeros(size(this.tableData, 1)/noOfWells, 1);
            for cycle = 1 : size(this.tableData, 1)/noOfWells;
                cycleTime = zeros(noOfWells, 1);
                for row = 1 : noOfWells
                    cycleTime(row) = time{(cycle - 1)*noOfWells + row};
                end
                cycleBeginningTimes(cycle)=min(cycleTime);
            end
        end
        
        function cycleBeginningRow = findFirstRowWithTime(this, time)
           cycleBeginningRow = find(cell2mat(this.eventData(:, this.informativeColumns + this.treatmentColumns + 1))==time, 1);
        end
        
        function doNotUseEvents(this)
            this.includeEvents = 0;
            this.addData();
        end
        
        function updateTreatments(this, treatmentStructure)
            this.treatmentStructure = treatmentStructure;
            numberOfRows = size(this.tableData, 1);
            %% this code could use serious optimization
            noOfWells = numel(treatmentStructure.resultWells);
            noOfTreatments = size(treatmentStructure.results{1}, 2);
            wells = reshape(treatmentStructure.resultWells,1,noOfWells);
            treatments = treatmentStructure.results;
            
            connectionMatrix = zeros(numel(treatmentStructure.resultWells),1);
            if isequal(size(this.tableData, 1), 1) 
                for i = 1 : numel(treatmentStructure.resultWells)
                    connectionMatrix(i) = i;
                end

            else
                for row = 1 : noOfWells
                    wellName = this.tableData(row, 2);
                    for i = 1 : numel(treatmentStructure.resultWells)
                       if strcmp(regexprep(wellName,' ', ''), treatmentStructure.resultWells{i}{1})
                          connectionMatrix(row) = i;
                          break;
                       end
                    end
                end
            end
            
            for block = 1 :  size(this.tableData, 1)/noOfWells;
                for row = 1 : noOfWells
                    wellName = this.tableData( (block-1) + row, 2);
                    tempData( (block-1)*noOfWells + row,  1 : noOfTreatments) = treatments{connectionMatrix(row)};
                    %this.tableData( (block-1)*noOfWells + row, this.informativeColumns + 1 : this.informativeColumns + noOfTreatments) = num2cell(treatments(row, :));       
                end
            end
            if exist('tempData', 'var')
                tempCellData = num2cell(tempData);
                this.tableData(:, this.informativeColumns + 1 : this.informativeColumns + noOfTreatments) = tempCellData;
                this.addData();
            else
                
            end
            
            if this.isExampleTable
                
            else            
                this.useEvents();
            end
        end
        
        function readMidasFile(this, fullFilePath)
            this.fileName = this.findFileName(fullFilePath);
            this.fullFilePath = fullFilePath;
            [data, textData] = loadFromMIDAS(fullFilePath);
            this.rawExcelNumericalData = data;
            this.columnHeaders = textData(1,:);
            this.calculateColumnTypesFromHeader();
            numberOfEmptyTreatmentColumns = this.treatmentColumns + this.timeColumns + this.measurementColumns - size(data, 2);
            emptyCells = cell(size(textData, 1) - 1, numberOfEmptyTreatmentColumns);
            emptyCells(:, :) = {0};
            this.eventData = [textData(2:end, 1:this.informativeColumns), emptyCells,  num2cell(data)];
            this.addEventsData();
            this.includeEvents = 1;
            
        end
       
        function data = getRawExcelNumericalData(this)
           data = this.rawExcelNumericalData; 
        end
        
        function wellID = getPresentWellID(this)
            
        end
        
        function numberOfEmptyTreatmentColumns = calculateNumberOfEmptyTreatmentColumns(this, textData)
            numberOfEmptyTreatmentColumns = this.treatmentColumns;
            for treatmentColumn = this.informativeColumns + 1 : this.informativeColumns + this.treatmentColumns + 1
               for row = 2 : size(textData, 1)
                  if ~isempty(textData{row, treatmentColumn})
                      numberOfEmptyTreatmentColumns = numberOfEmptyTreatmentColumns - 1;
                      break;
                  end
               end
            end
        end
        
        function fileName = findFileName(this, fullFilePath)
            startingIndexOfFileName = strfind(fullFilePath, '\');
            fileName = fullFilePath(startingIndexOfFileName(end)+1 : end);
        end
        
        function fileName = getFileName(this)
           fileName = this.fileName;
        end
        
        function calculateColumnTypesFromHeader(this)
            informativeColumns = 0;
            treatmentColumns = 0;
            timeColumns = 0;
            measurementColumns = 0;
            for column = 1 : numel(this.columnHeaders)
               if strfind(this.columnHeaders{column}, 'ID')
                   informativeColumns = informativeColumns + 1;
               elseif strfind(this.columnHeaders{column}, 'TR')
                   treatmentColumns = treatmentColumns + 1;
               elseif strfind(this.columnHeaders{column}, 'DA')
                   timeColumns = timeColumns + 1;    
               elseif strfind(this.columnHeaders{column}, 'DV')
                   measurementColumns = measurementColumns + 1;
               end
            end
            this.informativeColumns = informativeColumns;
            this.treatmentColumns = treatmentColumns;
            this.timeColumns = timeColumns;
            this.measurementColumns = measurementColumns;
        end
        
        function tableData = getTableData(this)
            tableData = this.tableData;
        end
        
        function eventData = getEventData(this)
           eventData = this.eventData; 
        end
        
        function removeDuplicates(this)
            sameColumns = [1 : this.informativeColumns, this.informativeColumns+this.treatmentColumns + 1];
            sameNaNColumns = [this.informativeColumns + 1 : this.informativeColumns + this.treatmentColumns, this.informativeColumns + this.treatmentColumns + this.timeColumns + 1 : this.informativeColumns + this.treatmentColumns + this.timeColumns + this.measurementColumns];
            timeMap = containers.Map('KeyType','double', 'ValueType', 'any');
            wellMap = containers.Map('KeyType','char', 'ValueType', 'any');
            for rowToChange = 1 : size(this.eventData, 1)
                if(timeMap.isKey(this.eventData{rowToChange,this.informativeColumns+this.treatmentColumns + 1}))
                    equalTimeIndices = timeMap(this.eventData{rowToChange,this.informativeColumns+this.treatmentColumns + 1});
                else
                    equalTimeIndices = find(cell2mat(this.eventData(:,this.informativeColumns+this.treatmentColumns + 1)) == this.eventData{rowToChange,this.informativeColumns+this.treatmentColumns + 1});
                    timeMap(this.eventData{rowToChange,this.informativeColumns+this.treatmentColumns + 1}) = equalTimeIndices;
                end
                
                if(wellMap.isKey(this.eventData{rowToChange, 2}))
                    equalWellNameIndices = wellMap(this.eventData{rowToChange, 2});
                else
                    equalWellNameIndices = find(strcmp(this.eventData(:,2), this.eventData{rowToChange, 2}));
                    wellMap(this.eventData{rowToChange, 2}) = equalWellNameIndices;
                end
                equalIndices = intersect(equalWellNameIndices, equalTimeIndices);
                equalIndices(equalIndices == rowToChange) = [];
                for rowToCompareWith = equalIndices'                                                                
                   for column = sameNaNColumns
                      if isnan(this.eventData{rowToChange, column}) && ~isnan(this.eventData{rowToCompareWith, column})
                         this.eventData{rowToChange, column} = this.eventData{rowToCompareWith, column};
                      end
                   end
                end                       
            end
            [table, I, J] = uniqueRowsCA(this.eventData);
            this.eventData = this.eventData(sort(I), :);
            this.rawExcelNumericalData = cell2mat(this.eventData(:, this.informativeColumns + 1:end));
            this.showTable();
        end
        
        function convertToSlowKinetics(this)
            for column = 1 : numel(this.columnHeaders)
               if(strcmp(this.columnHeaders{column}, 'ID:well'))
                   wellIDColumn = this.getEventTableColumnData(column);
                   % remove spaces after wellID so 'E10 ' turns to 'E10', why this kind
                   % of space is in the MIDAS file is currently unknown
                   wellIDColumn = regexprep(wellIDColumn,' ','');
                   break;
               end
            end
            
            noOfWells = 0;

            for i = 2 : numel(wellIDColumn)
                if(isequal(strcmp(wellIDColumn(i), wellIDColumn(1)), 1))
                    noOfWells = i - 1;
                    break;
                else
                    noOfWells = numel(wellIDColumn);
                end
            end
            
            originalWellID = wellIDColumn(1 : noOfWells);
            numberOfCycles = numel(this.getEventTableColumnData(1))/numel(originalWellID);
            
            for column = 1 : numel(this.columnHeaders)
                if isequal(strfind(this.columnHeaders{column}, 'DA:ALL'),1) || isequal(strfind(this.columnHeaders{column}, 'DA:All'), 1)% "DA:All" is for loading older MIDAS files
                    for cycle = 1 : numberOfCycles
                       try
                            this.eventData((cycle-1)*noOfWells+1:cycle*noOfWells, column) = {nanmin(cell2mat(this.eventData((cycle-1)*noOfWells+1:cycle*noOfWells, column)))}; 
                       catch
                           
                       end
                       try
                            this.tableData((cycle-1)*noOfWells+1:cycle*noOfWells, column) = {nanmin(cell2mat(this.tableData((cycle-1)*noOfWells+1:cycle*noOfWells, column)))};
                       catch
                           
                       end
                    end
                end   
            end
        end
        
        function convertToStandardMIDASTable(this)         
            if strcmp(this.MIDASMode, 'DA:ALL')
                this.timeColumns = this.measurementColumns;
                newTimeColumn = this.eventData(:, this.informativeColumns + this.treatmentColumns + 1);
                for timeColumnIndex = 2 : this.timeColumns% make new columns                 
                    this.eventData = [this.eventData(:, 1 : this.informativeColumns + this.treatmentColumns + timeColumnIndex - 1), newTimeColumn, this.eventData(:, this.informativeColumns + this.treatmentColumns + timeColumnIndex : end)]; 
                end
                newTimeHeaders = cell(1, this.timeColumns);
                for timeColumnIndex = 1 : this.timeColumns
                    newTimeHeaders{timeColumnIndex} = regexprep(this.columnHeaders{this.informativeColumns + this.treatmentColumns + 1 + timeColumnIndex}, 'DV', 'DA');
                end
                this.columnHeaders = [this.columnHeaders(1 : this.informativeColumns + this.treatmentColumns), newTimeHeaders, this.columnHeaders(this.informativeColumns + this.treatmentColumns + 2 : end)];
            end
            this.showTable();
            this.MIDASMode = 'Standard';
            
        end
        
        function convertToALLMidasTable(this)
            if strcmp(this.MIDASMode, 'Standard') 
                this.timeColumns = 1;
            end
            this.MIDASMode = 'DA:ALL';
        end
        
        function treatmentStructure = getTreatmentStructure(this)
            
            %locate event times
            inputStructure.data = this.getRawExcelNumericalData();
            inputStructure.noOfWells = numel(this.getWellID());
            inputStructure.noOfCycles = size(this.getRawExcelNumericalData(), 1)/inputStructure.noOfWells;
            inputStructure.numberOfChannels = this.measurementColumns;
            [concChangeEvent, eventTimes] = eventReader(inputStructure);
            noEvents = cellfun(@isempty, eventTimes);
            
            treatmentStructure.eventTimes = this.eventData{1, this.informativeColumns + this.treatmentColumns + 1}; % check if it hold when time shift is used
            resultWells = ImageImporter.sortWellID(this.getWellID()');
            results = cell(1, numel(resultWells));
            for i = 1 : numel(resultWells)
               resultWells{i} = {resultWells{i}};
               results{i} = cell2mat(this.eventData(i, this.informativeColumns + 1: this.informativeColumns + this.treatmentColumns));
            end
            if isequal(sum(noEvents), numel(noEvents))
                % no events so we can simplify
                eventStructure = cell(1,1);
                eventStructure{1} = results;
                treatmentStructure.eventStruct = eventStructure;               
                treatmentStructure.resultWells = resultWells;
                treatmentStructure.results = results;               
            else
                combined = []; 
                for well = 1 : numel(eventTimes)
                    combined = [combined, eventTimes{well}];
                end
                uniqueEventTimes = unique(combined);
                combinedNumberOfEvents = numel(uniqueEventTimes);
                eventStructure = cell(combinedNumberOfEvents, 1);
                for eventIndex = 1 : combinedNumberOfEvents
                    eventResults = cell(1, numel(resultWells));
                    startingRow = this.findFirstRowWithTime(uniqueEventTimes(eventIndex));
                    for i = 1 : numel(resultWells)
                       eventResults{i} = cell2mat(this.eventData(startingRow + i - 1, this.informativeColumns + 1: this.informativeColumns + this.treatmentColumns));
                    end
                    eventStructure{eventIndex} = eventResults;
                end
                treatmentStructure.eventTimes = uniqueEventTimes';
                treatmentStructure.eventStruct = eventStructure;               
                treatmentStructure.resultWells = resultWells;
                treatmentStructure.results = results;
            end           
        end
        
        function replaceTreatmentValuesFromTreatmentAndMeasurementConverter(this, results)
            originalValues = results{1};
            newValues = results{3};
            for row = 1 : size(this.eventData, 1)
               for col = 1 : this.treatmentColumns
                   for value = 1 : size(originalValues, 1)
                       if ~isempty(originalValues{value, col})
                           if isequal(this.eventData{row, col + this.informativeColumns}, str2double(originalValues{value, col}))
                               this.eventData{row, col + this.informativeColumns} = str2double(newValues{value, col});
                               break;
                           end
                       end
                   end
               end
            end
            this.setDataEqualToEventData
            this.showTable();
        end
    end    
end

