% a=fileChooser()
% a.chooseMIDASFile()
% file=ans
% midasTableController = MidasTableController(uitable())
% midasTableController.readMidasFile(file)
function handles = MidasToApareciumExperimentInput(midasTableController, handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
columnHeaders = midasTableController.getColumnHeaders();

for column = 1 : numel(columnHeaders)
   if(strcmp(columnHeaders{column}, 'ID:well'))
       wellIDColumn = midasTableController.getEventTableColumnData(column);
       % remove spaces after wellID so 'E10 ' turns to 'E10', why this kind
       % of space is in the MIDAS file is currently unknown
       wellIDColumn = regexprep(wellIDColumn,' ','');
       break;
   end
end

noOfWells = 0;

if isequal(numel(wellIDColumn), 1)
    noOfWells = 1;
else
    for i = 2 : numel(wellIDColumn)
        if(isequal(strcmp(wellIDColumn(i), wellIDColumn(1)), 1))
            noOfWells = i - 1;
            break;
        else
            noOfWells = numel(wellIDColumn);
        end
    end
end



%% get Well ID-s from MIDAS file

originalWellID = wellIDColumn(1 : noOfWells);
numberOfCycles = numel(midasTableController.getEventTableColumnData(1))/numel(originalWellID);
reindexingColumn = blockAlignIndex(originalWellID, wellIDColumn);
wellIDColumn = wellIDColumn(reindexingColumn);    

%% get time of measurements from MIDAS file
for column = 1 : numel(columnHeaders)
    if isequal(strfind(columnHeaders{column}, 'DA:ALL'),1) || isequal(strfind(columnHeaders{column}, 'DA:All'), 1)% "DA:All" is for loading older MIDAS files
        time = [];
        fastKinetics = 0;
        timeColumn = midasTableController.getEventTableColumnData(column);
        
        % reindex in case the order is not preserved across all time-points
        timeColumn = timeColumn(reindexingColumn);
        for cycle = 1 : numberOfCycles
            if ~isequal(1, size(unique(cell2mat(timeColumn( (cycle-1) * noOfWells + 1 : cycle * noOfWells))), 1))
                fastKinetics = 1;
                break;
            end
            time = [time, unique(cell2mat(timeColumn( (cycle-1) * noOfWells + 1 : cycle * noOfWells)))];
        end
        if numel(time) > numberOfCycles || fastKinetics % indicates that each cycle does not have a common timepoint, then this MIDAS will be considered to be fastKinetics experiment
            time = zeros(noOfWells, numberOfCycles);        
            for cycle = 1 : numberOfCycles
                time(1 : noOfWells, cycle) = cell2mat(timeColumn( (cycle-1) * noOfWells + 1 : cycle * noOfWells));
            end
%           Older version of the algoritm 
%           time = [];           
%           for cycle = 1 : numberOfCycles
%               time = [time, cell2mat(timeColumn( (cycle-1) * noOfWells + 1 : cycle * noOfWells))]; 
%           end
            
        end
        break;
    end   
end

%% get treatment names and no of Treatments
namesTR = [];
units = [];
treatments = cell(noOfWells, numel(wellIDColumn)/noOfWells, 0);
for i = 1 : size(columnHeaders, 2)
    if(isequal(strfind(columnHeaders(i),'TR:'),{1}));%% checks if the particular column contains treatment data
        treatmentNameWithUnit = regexprep(columnHeaders(i), 'TR:', '');
        underscoreIndices = cell2mat(strfind(treatmentNameWithUnit, '_'));
        namesTR{end+1} = {treatmentNameWithUnit{1}(1 : underscoreIndices(end) - 1)};%% adds the name of the data to last index of variable namesTR
        units{end+1} = treatmentNameWithUnit{1}(underscoreIndices(end) + 1  : end);
        treatmentColumn = cellstr(num2str(cell2mat(midasTableController.getEventTableColumnData(i))));
        
        % reindex in case the order is not preserved across all time-points
        treatmentColumn = treatmentColumn(reindexingColumn);
        if isequal(numel(treatmentColumn), numel(midasTableController.getEventTableColumnData(i)))
            treatments(:,:,end+1) = reshape(treatmentColumn, noOfWells, numberOfCycles);
        else
            treatments(:,:,end+1) = reshape(cellstr(midasTableController.getEventTableColumnData(i)), noOfWells, numberOfCycles);
        end
    end
end
noOfTreatments = size(namesTR,2);
measurements = cell(0,0);
channelNames = [];
for i = 1 : size(columnHeaders, 2)
    if(isequal(strfind(columnHeaders(i),'DV:'),{[1]}))%% checks if the particular column contains measurement data
        channelNames{end+1} = regexprep(columnHeaders{i}, 'DV:', '');%% adds the name of the data to last index of variable channelsDV
        measurementsCellArray = midasTableController.getEventTableColumnData(i);
        measurementsCellArray = measurementsCellArray(reindexingColumn);

        measurementsMatrix = zeros(numel(measurementsCellArray), 1);
        for measurement = 1 : numel(measurementsCellArray)
            if isempty(measurementsCellArray{measurement})
                measurementsMatrix(measurement, 1) = NaN;
            else
                measurementsMatrix(measurement, 1) = measurementsCellArray{measurement};
            end
        end
        measurements{end+1} = measurementsMatrix;
        %measurements{end+1} = cell2mat(midasTableController.getEventTableColumnData(i));

    end
end



numberOfChannels = size(channelNames,2);

%timeUnit = regexprep(columnHeaders{end-numberOfChannels}, 'DA:All', '');




[height, width, wellID, inUse] = generateGhostplate(originalWellID);
finalTreatments = cell(height, width, numberOfCycles, size(treatments, 3));
finalTreatments(1 : height, 1 : width, 1 : numberOfCycles, 1 : size(treatments, 3)) = cell({'0'});
for row = 1 : width
    for col = 1 : height
        for origRow = 1 : numel(originalWellID)
           if strfind(wellID{row, col}, originalWellID{origRow})
               finalTreatments(col, row, :, 1:size(treatments, 3)) = reshape(treatments(origRow, :, :), numberOfCycles, size(treatments, 3));
           end
        end
    end
end
concentrations = cell(noOfTreatments, 1);
for treatment = 1 : noOfTreatments
    uniqueConcentrations = unique(strtrim(finalTreatments( :, :, :, treatment)));
    for conc = 1 : numel(uniqueConcentrations)
       uniqueConcentrations{conc} = str2double(uniqueConcentrations{conc}); 
    end
    concentrations{treatment} = sort(cell2mat(uniqueConcentrations));
    %concentrations{treatment} = str2num(cell2mat(unique(finalTreatments( :, :, :, treatment))));
end

%% Get events
inputStructure.data = midasTableController.getRawExcelNumericalData();
inputStructure.noOfWells = noOfWells;
inputStructure.noOfCycles = numberOfCycles;
inputStructure.numberOfChannels = numberOfChannels;
[concChangeEvent, eventTimes] = eventReader(inputStructure);%% this refers to the event reader inside this function, not the separate EventReader function that may exist

measurements = generateMeasurements(originalWellID, wellID, measurements, numberOfCycles, numberOfChannels, width, height);
handles.apareciumExperimentInput.setMode('groupWells')
handles.apareciumExperimentInput.setWells(wellID);
handles.apareciumExperimentInput.setOriginalWells(originalWellID);
handles.apareciumExperimentInput.setInUse(inUse);
handles.apareciumExperimentInput.setTreatments(namesTR);
handles.apareciumExperimentInput.setNumberOfCycles(numberOfCycles);
handles.apareciumExperimentInput.setMeasurements(measurements);
handles.apareciumExperimentInput.setChannelNames(channelNames);
handles.apareciumExperimentInput.setPredefinedConcentrations(finalTreatments);
handles.apareciumExperimentInput.updateConcentrations(concentrations);
handles.apareciumExperimentInput.updateUnits(units);
handles.apareciumExperimentInput.setCycleTimeMoments(time);
handles.apareciumExperimentInput.setConcentrationChangeEvents(concChangeEvent);
handles.apareciumExperimentInput.setEventTimes(eventTimes);
handles.apareciumExperimentInput.setFastKinetics(fastKinetics);
end

function reshapedMeasurements = generateMeasurements(originalID, wellID, measurements, numberOfCycles, numberOfChannels, width, height)
    reshapedMeasurements = zeros(width, height, numberOfCycles, numberOfChannels);
    for col = 1 :  width 
        for row = 1 : height
            wellIndex =  find(strcmp(originalID, wellID{col, row}));
            if isempty(wellIndex)
                reshapedMeasurements(col, row, 1 : numberOfCycles, 1 : numberOfChannels) = 0;
            else
                for cycle = 1 : numberOfCycles
                    for channel = 1 : numberOfChannels
                        %disp(['cycle:', num2str(cycle)]);
                        %disp(['channel:', num2str(channel)]);
                        reshapedMeasurements(col, row, cycle, channel) = measurements{channel}((cycle-1)*numel(originalID) + wellIndex); 
                        %reshapedMeasurements(col, row, cycle, channel) = measurements{channel}{(cycle-1)*numel(originalID) + wellIndex}; 
                    end
                end
            end
        end
    end
end

function [ concChangeEvent, eventTimes ] = eventReader(handles)
    data = handles.data;
    noOfWells = handles.noOfWells;
    timepoints = handles.noOfCycles;
    noOfChannels = handles.numberOfChannels;
    data = reshape(data, noOfWells, timepoints, size(data, 2));
    previousConcentration(:,:) = data(:,1,:);
    previousConcentration(:,:) = 0;
    eventList = cell(noOfWells,1);
    isevent = cell(noOfWells,1);
    eventTimes = cell(noOfWells,1);
    eventData = zeros(noOfWells, size(data, 3));
    for well = 1:noOfWells
       eventList{well} = cell(0); 
       event{well} = 0;
    end
    for timepoint = 1:timepoints
       eventData(:,:) = data(:,timepoint,:);
       for well = 1:noOfWells
          % first event
         if isempty(eventList{well})
             isevent{well} = true;
         else
             newConcs = eventData(well,1 : size(data,3)-noOfChannels-1);
             deltaConcentrations = diff([eventList{well}{end}; newConcs]);
             somethingChanged = ~all(deltaConcentrations == 0);
             if somethingChanged
                 for channel = 1:noOfChannels
                     if isequal(num2str(eventData(well,end+1-channel)),'NaN')                
                         isevent{well} = true;
                     else
                         isevent{well} = false;
                         break;
                     end
                 end
             else
                 isevent{well} = false;
             end
         end
       end
       for well = 1:noOfWells
            if isequal(isevent{well},1)
                event{well} = event{well} + 1;
                eventTimes{well}(end + 1) = eventData(well,end-noOfChannels);
                for substance = 1 : size(data,3)-noOfChannels-1
                    eventList{well}{event{well}}(substance) = eventData(well,substance);    
                end
            end
       end
    end
    concChangeEvent = cell(noOfWells,1);
    for well = 1:noOfWells
       concChangeEvent{well} = cell(0); 
    end
    for well = 1 : noOfWells   
        if ~isempty(eventList{well})
            for event = 2 : size(eventList{well}, 2)
                for substance = 1:size(data,3)-noOfChannels-1
                    concChangeEvent{well}{event-1} = eventList{well}{event} - eventList{well}{event-1};   
                end
            end
        end
    end
end

function idx = blockAlignIndex(arr1, arr2)
    % arr1: 1×n unique strings
    % arr2: 1×(n*m) strings; each block of length n is a permutation of arr1

    % Map arr2 elements to indices of arr1
    [~, loc] = ismember(arr2, arr1);  % loc(i) in 1..n

    n = numel(arr1);
    N = numel(arr2);

    % Sanity checks
    assert(all(loc > 0), 'All elements of arr2 must appear in arr1.');
    assert(mod(N, n) == 0, 'Length of arr2 must be a multiple of length of arr1.');

    m = N / n;  % number of blocks

    % Reshape into n×m matrix: each column = one block (as codes 1..n)
    locMat = reshape(loc, n, m);

    % We want, for each block, the row index where code 1,2,...,n appears.
    % That’s the inverse permutation of each column.

    rows = repmat((1:n)', 1, m);      % row indices
    cols = repmat(1:m,      n, 1);    % column indices

    invMat = zeros(size(locMat));     % will hold inverse permutations
    invMat(sub2ind(size(invMat), locMat, cols)) = rows;
    % Now invMat(k,j) = row r where locMat(r,j) == k

    % Convert (row,block) positions back to linear indices in arr2
    blockOffsets = 0:n:(N-1);         % [0 n 2n ...]
    idxMat = invMat + repmat(blockOffsets, n, 1);

    % Final linear index into arr2
    idx = idxMat(:);
end