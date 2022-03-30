classdef Gen5Read < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        orderIndex %index, which shows the overall index of this read in the experiment
        runtime
        interval
        numberOfCycles
        readType
        channels
        readName
        wellID
        measurements
        measurementTimepoints = 0
        temperature
        firstLineOfMeasurements
        lastLineOfMeasurements
        readWasEmpty = 'No'
        cyclesByLineCount             
        fastKineticsMeasurementsTimepoints
        appendsIndex = 0; % 0 if not part of appended reads
        timepointForAppendSubtraction = 0;
        timepointForAppendStorage = 0;
        
    end
    
    methods
        function this = Gen5Read()
            
        end
        
        function readCopy = getCopy(this)
            readCopy = Gen5Read();
            props = properties(this);
            for propIndex = 1 : numel(props)
                readCopy.(props{propIndex}) = this.(props{propIndex});
            end
        end
        
        function setNumberOfCycles(this, cycles)
            this.numberOfCycles = cycles;
        end
        
        function cycles = getNumberOfCycles(this)
            cycles = this.numberOfCycles;
        end
        
        function setRuntime(this, runtime)
            this.runtime = runtime;
        end
        
        function setInterval(this, interval)
            this.interval = interval;
        end
        
        function interval = getInterval(this)
           interval = this.interval; 
        end
        
        function setOrderIndex(this, index)
           this.orderIndex = index; 
        end
        
        function index = getOrderIndex(this)
            index = this.orderIndex;
        end
        
        function setReadType(this, line)
            line = regexprep(line, sprintf('\t'), '');
            line = regexprep(line, '    ', '');
            this.readType = regexprep(line, 'Read', '');
        end
        
        function readType = getReadType(this)
            readType = this.readType;
        end
        
        function setChannel1(this, line)
            this.channels{1} = regexprep(line,'  ','');
        end
        
        function setChannel2(this, line)
            this.channels{2} = regexprep(line,'  ','');
        end
        
        function setChannel(this, line, index)
           this.channels{index} = regexprep(line,'  ','');
        end
        
        function setTemperature(this, temperature)
            this.temperature = temperature;
        end
        
        function temperature = getTemperature(this)
            temperature = this.temperature;
        end
        
        function isKinetic = isKineticRead(this)
            isKinetic = ~isequal(this.runtime, 0);
        end
        
        function setTimepoints(this, timepoints)
            this.measurementTimepoints = timepoints;
            this.timepointForAppendStorage = this.measurementTimepoints(min([this.numberOfCycles, numel(this.measurementTimepoints)]));
        end
        
        function setMeasurements(this, measurements)
            this.measurements = measurements;
        end
        
        function setTemperatures(this, temperatures)
            this.temperatures = temperatures;
        end
        
        function setWellIDs(this, IDs)
            this.wellID = IDs;
        end
        
        function wellIDs = getWellIDs(this)
            wellIDs = this.wellID;
        end
        
        function setReadWasEmpty(this, yesOrNo)
           this.readWasEmpty = yesOrNo; 
        end
        
        function answer = getReadWasEmpty(this)
            answer = this.readWasEmpty;
        end
        
        function removeUnmeasuredWells(this)
            notMeasuredWells = [];
            for wellIndex = 1 : numel(this.wellID)
                wellIsEmpty = 1;
                for channel = 1 : size(this.measurements, 1)
                    for timeMoment = 1 : size(this.measurements, 2)
                        if strcmp(this.measurements(channel, timeMoment, wellIndex), '') || strcmp(this.measurements(channel, timeMoment, wellIndex), '?????')
                            
                        else
                            wellIsEmpty = 0;
                        end
                    end
                end
                if wellIsEmpty
                   notMeasuredWells(end+1) = wellIndex; 
                end
            end
            if ~isempty(notMeasuredWells)
                this.measurements(:,:,notMeasuredWells) = [];
                this.wellID(notMeasuredWells) = [];
            end
        end
        
        function calculateTheoreticalTimepoints(this, runs)         
            this.measurementTimepoints = 0 : this.interval : this.interval*(runs - 1);
            if isempty(this.measurementTimepoints)
                this.measurementTimepoints = 0;
            end
        end
        
        function setReadName(this, readName)
           this.readName = readName; 
        end
        
        function readName = getReadName(this)
           readName = this.readName; 
        end
        
        function calculateCyclesByLineCount(this)
            % this is prone to error and not tested enough, be careful with
            % this check
            if(this.isKineticRead())
                this.cyclesByLineCount = ((this.lastLineOfMeasurements - this.firstLineOfMeasurements)-numel(this.channels)*3)/numel(this.channels);
                if isequal(numel(this.channels), 1)
                    this.cyclesByLineCount = this.cyclesByLineCount + 1;
                end
            else
                this.cyclesByLineCount = 1; 
            end
        end
        
        function experimentDataStructure = toExperimentDataStructure(read)
           rawWellID = read.wellID;
           wellID = cell(1, 0);
           for wellIndex = 1 : numel(rawWellID)
               wellID{wellIndex} = rawWellID{wellIndex}{1}; 
           end
           experimentDataStructure.readWasEmpty = read.getReadWasEmpty;
           experimentDataStructure.numberOfChannels = numel(read.channels);
           experimentDataStructure.wellID = wellID;
           experimentDataStructure.cycleTime = read.interval;
           experimentDataStructure.runtime = read.runtime;
           experimentDataStructure.timeOfMeasurements = read.measurementTimepoints';
           experimentDataStructure.timeOfFastKineticsMeasurements = fastKineticsCalculator(wellID', 11 , read.interval, read.measurementTimepoints)';
           experimentDataStructure.channelNames = read.channels;
           measurements = read.measurements;
           for wellIndex = 1 : numel(read.wellID)
               rawWellMeasurements = measurements(:, :, wellIndex);
               reshapedWellMeasurements = reshape(rawWellMeasurements, numel(rawWellMeasurements), 1);
               measurementsAsDouble = zeros(numel(reshapedWellMeasurements), 1);
               for measurementNumber = 1 : numel(reshapedWellMeasurements)
                   if strcmp(reshapedWellMeasurements{measurementNumber}, 'OVRFLW')                      
                        measurementsAsDouble(measurementNumber) = NaN;
                   elseif ~isempty(strfind(reshapedWellMeasurements{measurementNumber},'>'))
                        measurementsAsDouble(measurementNumber) = NaN;
                   elseif ~isempty(strfind(reshapedWellMeasurements{measurementNumber},'?????'))
                        measurementsAsDouble(measurementNumber) = NaN;
                   else
                      if isempty(reshapedWellMeasurements{measurementNumber})
                          measurementsAsDouble(measurementNumber) = NaN;
                      else
                          try
                            measurementsAsDouble(measurementNumber) = str2double(regexprep(reshapedWellMeasurements{measurementNumber}, ',', '.')); 
                          catch MException
                              
                          end
                      end
                   end
                end
                experimentDataStructure.measurements{wellIndex} = measurementsAsDouble;
            end
        end
        
        function appendsIndex = getIsAppendsIndex(this)
            appendsIndex = this.appendsIndex;
        end
        
        function setIsAppendsIndex(this, appendsIndex)
            this.appendsIndex = appendsIndex;
        end
        
        function measurements = getAndDeleteAppendMeasurements(this, nrOfCycles)
            measurements = this.measurements(:,this.numberOfCycles + 1: min([nrOfCycles + this.numberOfCycles, size(this.measurements, 2)]), :);
            this.measurements(:,this.numberOfCycles + 1: min([nrOfCycles + this.numberOfCycles, size(this.measurements, 2)]), :) = [];
        end
        
        function temperatures = getAndDeleteAppendTemperatures(this, nrOfCycles)
            temperatures = this.temperature(:, this.numberOfCycles + 1: min([nrOfCycles + this.numberOfCycles, size(this.temperature, 2)]));
            this.temperature(:, this.numberOfCycles + 1: min([nrOfCycles + this.numberOfCycles, size(this.temperature, 2)])) = [];
        end
        
        function timepoints = getAndDeleteTimepoints(this, nrOfCycles)
            timepoints = this.measurementTimepoints(this.numberOfCycles + 1: min([nrOfCycles + this.numberOfCycles, numel(this.measurementTimepoints)]));
            this.timepointForAppendSubtraction = this.timepointForAppendStorage;
            if ~isempty(timepoints)
                this.timepointForAppendStorage = timepoints(end);
            else
                this.timepointForAppendStorage = [];
            end
            this.measurementTimepoints(this.numberOfCycles + 1: min([nrOfCycles + this.numberOfCycles, numel(this.measurementTimepoints)])) = [];
        end
        
        function timepointForAppendSubtraction = getCorrespondingTimepointForAppendSubtraction(this)
            timepointForAppendSubtraction = this.timepointForAppendSubtraction;
        end
        
        function timeOfFirstRead = getTimeOfFirstRead(this)
           timeOfFirstRead = this.measurementTimepoints(1);
        end
    end    
end