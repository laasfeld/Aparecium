function varargout = ReadHandler(varargin)
% READHANDLER M-file for ReadHandler.fig
%      READHANDLER, by itself, creates a new READHANDLER or raises the existing
%      singleton*.
%
%      H = READHANDLER returns the handle to a new READHANDLER or the handle to
%      the existing singleton*.
%
%      READHANDLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in READHANDLER.M with the given input arguments.
%
%      READHANDLER('Property','Value',...) creates a new READHANDLER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ReadHandler_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ReadHandler_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ReadHandler

% Last Modified by GUIDE v2.5 18-Aug-2016 16:20:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ReadHandler_OpeningFcn, ...
                   'gui_OutputFcn',  @ReadHandler_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ReadHandler is made visible.
function ReadHandler_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ReadHandler (see VARARGIN)

% Choose default command line output for ReadHandler
handles.output = hObject;
handles.experimentDataStructureArray = varargin{1};
handles.sortedListOfReads = varargin{2};
handles.listOfKinetics = varargin{3};
handles.listOfNonKineticReads = varargin{4};
handles.experimentDataStructure = [];
handles = mergeReadsInSameKinetics(handles);
% Update handles structure
handles = generateTable(hObject, handles);
guidata(hObject, handles);
uiwait(handles.figure1);


% UIWAIT makes ReadHandler wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ReadHandler_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.experimentDataStructure;
delete(handles.figure1);

function handles = mergeReadsInSameKinetics(handles)
    newListOfReads = cell(0,0)
    for kineticsIndex = 1 : numel(handles.listOfKinetics)
        counter = 1;
        orderIndeces = zeros(1, numel(handles.listOfKinetics{kineticsIndex}.listOfReads));
        orderIndeces(counter) = handles.listOfKinetics{kineticsIndex}.listOfReads{counter}.orderIndex;
        firstRead = handles.listOfKinetics{kineticsIndex}.listOfReads{1};
        newRead = Gen5Read();
        newRead.setNumberOfCycles(firstRead.getNumberOfCycles());
        newRead.setOrderIndex(firstRead.getOrderIndex());
        newRead.setInterval(firstRead.getInterval());
        newRead.setTemperature(firstRead.getTemperature());
        newRead.firstLineOfMeasurements = NaN;
        newRead.lastLineOfMeasurements = NaN;
        newRead.wellID = firstRead.wellID;
        newRead.measurementTimepoints = firstRead.measurementTimepoints;
        newRead.measurements = firstRead.measurements;
        newRead.readName = firstRead.getReadName();
        newRead.channels = firstRead.channels;
        newRead.readType = 'combination';
        for readIndex = 2 : numel(handles.listOfKinetics{kineticsIndex}.listOfReads)
            counter = counter + 1;
            orderIndeces(counter) = handles.listOfKinetics{kineticsIndex}.listOfReads{counter}.orderIndex;
            currentRead = handles.listOfKinetics{kineticsIndex}.listOfReads{readIndex};
            newRead = mergeGen5ReadsOfDifferentWells(newRead, currentRead);
            newRead.readName = [newRead.readName, '+', currentRead.readName];
            newRead.numberOfCycles = newRead.numberOfCycles + currentRead.numberOfCycles;
        end
        newRead.runtime = max(newRead.measurementTimepoints) - min(newRead.measurementTimepoints);
        for orderIndex = 1 : numel(orderIndeces)
            for index = 1 : numel(handles.sortedListOfReads)
               if isequal(handles.sortedListOfReads{index}.orderIndex, orderIndeces(orderIndex))
                  handles.sortedListOfReads(index) = [];
                  break;
               end
            end
        end
        
        finalIndex = numel(handles.sortedListOfReads) + 1;
        for index = 1 : numel(handles.sortedListOfReads)
           orderIndex = handles.sortedListOfReads{index};
           if orderIndex < newRead.orderIndex
              finalIndex = index;
           end
        end
        handles.sortedListOfReads = [handles.sortedListOfReads(1 : finalIndex - 1), {newRead}, handles.sortedListOfReads(finalIndex : end)]; 
    end
    handles.experimentDataStructureArray = [];
    for readIndex = 1 : numel(handles.sortedListOfReads)
        handles.experimentDataStructureArray{readIndex} = handles.sortedListOfReads{readIndex}.toExperimentDataStructure();
    end
    
    

function handles = generateTable(hObject, handles)

for readIndex = 1 : numel(handles.experimentDataStructureArray)
    tableData{readIndex, 1} = readIndex;
    tableData{readIndex, 2} = handles.sortedListOfReads{readIndex}.interval * handles.sortedListOfReads{readIndex}.numberOfCycles;
    tableData{readIndex, 3} = 0;
    if isequal(readIndex, 1)
        tableData{readIndex, 4} = 0;
        tableData{readIndex, 5} = 0;
        tableData{readIndex, 6} = true;
    else
        tableData{readIndex, 4} = handles.sortedListOfReads{readIndex - 1}.interval * handles.sortedListOfReads{readIndex - 1}.numberOfCycles;
        sum = 0;
        for sumIndex = 1 : readIndex - 1;           
            sum = sum + handles.sortedListOfReads{sumIndex}.interval * handles.sortedListOfReads{sumIndex}.numberOfCycles; 
        end
        tableData{readIndex, 5} = sum;
        if strcmp(handles.experimentDataStructureArray{readIndex}.readWasEmpty(), 'No')
            tableData{readIndex, 6} = true;
        else
            tableData{readIndex, 6} = false;
        end
    end
    
end
set(handles.experimentTable, 'data', tableData);
handles = generateDataStructure(handles);
guidata(hObject, handles);

% --- Executes when entered data in editable cell(s) in experimentTable.
function experimentTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to experimentTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
tableData = get(hObject, 'data');
for readIndex = eventdata.Indices(1) : numel(handles.experimentDataStructureArray)
    if isequal(readIndex, 1)
        if isequal(eventdata.Indices(2), 3)
            tableData{readIndex, 4} = tableData{readIndex, 3};
            tableData{readIndex, 5} = tableData{readIndex, 3};
        elseif isequal(eventdata.Indices(2), 4)
            tableData{readIndex, 3} = tableData{readIndex, 4};
            tableData{readIndex, 5} = tableData{readIndex, 4};
        elseif isequal(eventdata.Indices(2), 5)
            tableData{readIndex, 3} = tableData{readIndex, 5};
            tableData{readIndex, 4} = tableData{readIndex, 5};
        elseif isequal(eventdata.Indices(2), 6)
            if strcmp(handles.experimentDataStructureArray{readIndex}.readWasEmpty(), 'Yes')
                tableData{readIndex, 6} = false;
                warndlg('This read contains no measurements possibly due to aborted measurement. It can´t be included in MIDAS file')
            end
        end
    else
        if isequal(eventdata.Indices(2), 3)
            tableData{readIndex, 4} = tableData{readIndex, 3} + tableData{readIndex - 1, 2};
            tableData{readIndex, 5} = tableData{readIndex - 1, 2} + tableData{readIndex - 1, 5} + tableData{readIndex, 3};
        elseif isequal(eventdata.Indices(2), 4)
            tableData{readIndex, 3} = tableData{readIndex, 4} - tableData{readIndex - 1, 2};
            sum = 0;
            for sumIndex = 1 : readIndex - 1;
                sum = sum + tableData{sumIndex, 2} + tableData{sumIndex, 3}; 
            end
            tableData{readIndex, 5} = sum + tableData{readIndex, 3};
        elseif isequal(eventdata.Indices(2), 5)
            sum = 0;
            for sumIndex = 1 : readIndex - 1;
                
                sum = sum + tableData{sumIndex, 2} + tableData{sumIndex, 3}; 
            end
            tableData{readIndex, 3} = tableData{readIndex, 5} - sum;
            tableData{readIndex, 4} = tableData{readIndex, 3} + tableData{readIndex - 1, 2};            
        elseif isequal(eventdata.Indices(2), 6) && isequal(eventdata.Indices(1), readIndex)
            if strcmp(handles.experimentDataStructureArray{readIndex}.readWasEmpty, 'Yes')
                tableData{readIndex, 6} = false;
                warndlg('This read contains no measurements possibly due to aborted measurement. It can´t be included in MIDAS file')
            end
        end
    end
end
set(hObject, 'data', tableData);
%handles = generateDataStructure(handles);
guidata(hObject, handles);

function handles = generateDataStructure(handles)

tableData = get(handles.experimentTable, 'data');
handles.experimentDataStructure = [];
for readIndex = 1 : numel(handles.experimentDataStructureArray)
   if isequal(tableData{readIndex, 6}, 1);
       handles.experimentDataStructureArray{readIndex} = standardizeWellOrder(handles.experimentDataStructureArray{readIndex});
       if isequal(readIndex, 1)
           
           handles.experimentDataStructure = handles.experimentDataStructureArray{readIndex};
           handles.experimentDataStructure.timeOfMeasurements = handles.experimentDataStructure.timeOfMeasurements + tableData{1, 5};
           handles.experimentDataStructure.timeOfFastKineticsMeasurements = handles.experimentDataStructure.timeOfFastKineticsMeasurements + tableData{1, 5};
       elseif isequal(handles.experimentDataStructure, [])
           handles.experimentDataStructure = handles.experimentDataStructureArray{readIndex};
       else
           if isequal(numel(handles.experimentDataStructure.channelNames), numel(handles.experimentDataStructureArray{readIndex}.channelNames))
               channelsAreSame = 1;
               for channelIndex = 1 : numel(handles.experimentDataStructure.channelNames)
                    if strcmp(handles.experimentDataStructure.channelNames{channelIndex}, handles.experimentDataStructureArray{readIndex}.channelNames{channelIndex}) 
                    
                    else
                        channelsAreSame = 0;
                        %warndlg('Channels in all reads were not same, this may cause an error or unexpected results!');
                    end
               end
               if channelsAreSame
                   timesOfFirstRead = handles.experimentDataStructure.timeOfMeasurements;
                   fastKineticTimesOfFirstRead = handles.experimentDataStructure.timeOfFastKineticsMeasurements;
                   timesOfSecondRead = handles.experimentDataStructureArray{readIndex}.timeOfMeasurements;
                   fastKineticTimesOfSecondRead = handles.experimentDataStructureArray{readIndex}.timeOfFastKineticsMeasurements;
                   timeShift = tableData{readIndex, 5};
                   correctedTimesOfSecondRead = timesOfSecondRead + timeShift;
                   correctedFastKineticTimesOfSecondRead = fastKineticTimesOfSecondRead + timeShift;
                   handles.experimentDataStructure.timeOfMeasurements = [timesOfFirstRead; correctedTimesOfSecondRead];
                   if isequal(handles.experimentDataStructure.wellID, handles.experimentDataStructureArray{readIndex}.wellID)
                        handles.experimentDataStructure.timeOfFastKineticsMeasurements = [fastKineticTimesOfFirstRead; correctedFastKineticTimesOfSecondRead];
                   end 
                      %disp('Fast kinetics concatenation failed'); 
                      %disp(error);

               else
                   timesOfFirstRead = handles.experimentDataStructure.timeOfMeasurements;
                   fastKineticTimesOfFirstRead = handles.experimentDataStructure.timeOfFastKineticsMeasurements;
                   timesOfSecondRead = handles.experimentDataStructureArray{readIndex}.timeOfMeasurements;
                   fastKineticTimesOfSecondRead = handles.experimentDataStructureArray{readIndex}.timeOfFastKineticsMeasurements;
                   timeShift = tableData{readIndex, 5};
                   correctedTimesOfSecondRead = timesOfSecondRead + timeShift;
                   correctedFastKineticTimesOfSecondRead = fastKineticTimesOfSecondRead + timeShift;
                   handles.experimentDataStructure.timeOfMeasurements = [timesOfFirstRead; correctedTimesOfSecondRead];
                   if isequal(handles.experimentDataStructure.wellID, handles.experimentDataStructureArray{readIndex}.wellID)
                        handles.experimentDataStructure.timeOfFastKineticsMeasurements = [fastKineticTimesOfFirstRead; correctedFastKineticTimesOfSecondRead];
                   end 
               end
               
               if isequal(handles.experimentDataStructure.wellID, handles.experimentDataStructureArray{readIndex}.wellID)
                  for wellIndex = 1 : numel(handles.experimentDataStructure.wellID)
                      measurementsOfFirstRead = handles.experimentDataStructure.measurements{wellIndex};
                      measurementsOfSecondRead = handles.experimentDataStructureArray{readIndex}.measurements{wellIndex};
                      mergedMeasurements = [measurementsOfFirstRead; measurementsOfSecondRead];
                      handles.experimentDataStructure.measurements{wellIndex} = mergedMeasurements;
                  end
               else
                   [handles.experimentDataStructure, handles.experimentDataStructureArray{readIndex}] = mergeReadsOfDifferentWells(handles.experimentDataStructure, handles.experimentDataStructureArray{readIndex});
                   handles.experimentDataStructure = standardizeWellOrder(handles.experimentDataStructure);
                   handles.experimentDataStructureArray{readIndex} = standardizeWellOrder(handles.experimentDataStructureArray{readIndex});
                   
                   for wellIndex = 1 : numel(handles.experimentDataStructure.wellID)
                       measurementsOfFirstRead = handles.experimentDataStructure.measurements{wellIndex};
                       measurementsOfSecondRead = handles.experimentDataStructureArray{readIndex}.measurements{wellIndex};
                       mergedMeasurements = [measurementsOfFirstRead; measurementsOfSecondRead];
                       handles.experimentDataStructure.measurements{wellIndex} = mergedMeasurements;
                   end               
               end
           end
       end
   else
       
   end
end

function [dataStruct1, dataStruct2] = mergeReadsOfDifferentWells(dataStruct1, dataStruct2)
allWells = [dataStruct1.wellID, dataStruct2.wellID];
allUniqueWells = unique(allWells);
dataStruct1 = addNonMeasuredWells(dataStruct1, allUniqueWells);
dataStruct2 = addNonMeasuredWells(dataStruct2, allUniqueWells);

function [read1] = mergeGen5ReadsOfDifferentWells(read1, read2)
wellID1 = cell(numel(read1.wellID), 1);
wellID2 = cell(numel(read2.wellID), 1);
for index = 1 : numel(read1.wellID)
   wellID1{index} = read1.wellID{index}{1};
end

for index = 1 : numel(read2.wellID)
   wellID2{index} = read2.wellID{index}{1};
end

allWells = [wellID1; wellID2];
allUniqueWells = unique(allWells);
read1 = addNonMeasuredWellsToGen5Read(read1, allUniqueWells);
read2 = addNonMeasuredWellsToGen5Read(read2, allUniqueWells);
allChannels = unique([read1.channels, read2.channels]);
noOfWells = numel(read1.wellID);
counter = 1;
timeOfMeasurements = zeros(1, read1.numberOfCycles * 2);
timeOfMeasurementsMerge = zeros(1, read1.numberOfCycles, 1);
for cycleIndex = 1 : read1.numberOfCycles
   timeOfMeasurements(counter) = read1.measurementTimepoints(cycleIndex);
   timeOfFastKineticsMeasurements(counter, 1 : noOfWells) = read1.fastKineticsMeasurementsTimepoints(cycleIndex, :);
   for channelIndex = 1 : numel(read1.channels)
       channelName = read1.channels{channelIndex};
       finalChannelIndex = find(strcmp(allChannels, channelName));     
       finalMeasurementsMerge(finalChannelIndex, cycleIndex, 1 : noOfWells) = read1.measurements(channelIndex, cycleIndex, :);
       finalMeasurements(finalChannelIndex, counter, 1 : noOfWells) = read1.measurements(channelIndex, cycleIndex, :);
       
       
   end
   counter = counter + 1;
   timeOfMeasurements(counter) = read2.measurementTimepoints(cycleIndex);
   timeOfFastKineticsMeasurements(counter, 1 : noOfWells) = read2.fastKineticsMeasurementsTimepoints(cycleIndex, :);
 
   for channelIndex = 1 : numel(read2.channels)
       channelName = read2.channels{channelIndex};
       finalChannelIndex = find(strcmp(allChannels, channelName));     
       finalMeasurementsMerge(finalChannelIndex, cycleIndex , 1 : noOfWells) = read2.measurements(channelIndex, cycleIndex, :);
       finalMeasurements(finalChannelIndex, counter, 1 : noOfWells) = read2.measurements(channelIndex, cycleIndex, :);
       
   end
   timeOfMeasurementsMerge(cycleIndex) = mean([read1.measurementTimepoints(cycleIndex), read2.measurementTimepoints(cycleIndex)]);
   counter = counter + 1;

end
read1.fastKineticsMeasurementsTimepoints = timeOfFastKineticsMeasurements;
% currently the concatenation and not the merge version is used
read1.measurementTimepoints = timeOfMeasurements;
read1.measurements = finalMeasurements;
read1.channels = allChannels;
'test'

function endDataStruct = addNonMeasuredWells(dataStruct, allUniqueWells)
endDataStruct = dataStruct;
endDataStruct.timeOfFastKineticsMeasurements = [];
endDataStruct.wellID = allUniqueWells;
endDataStruct.timeOfMeasurements = dataStruct.timeOfMeasurements;
emptyMeasurements = dataStruct.measurements{1};
emptyMeasurements(:) = NaN;
for wellIndex = 1 : numel(allUniqueWells)    
   if wellIsPresentInExperiment(dataStruct, allUniqueWells{wellIndex})
       endDataStruct.measurements{wellIndex} = dataStruct.measurements{findWellIndex(dataStruct, allUniqueWells{wellIndex})};
       endDataStruct.timeOfFastKineticsMeasurements(wellIndex) = dataStruct.timeOfFastKineticsMeasurements(findWellIndex(dataStruct, allUniqueWells{wellIndex})); 
   else
       endDataStruct.measurements{wellIndex} = emptyMeasurements;
       endDataStruct.timeOfFastKineticsMeasurements(wellIndex) = NaN;
   end
end

function read = addNonMeasuredWellsToGen5Read(read, allUniqueWells)

timeOfFastKineticsMeasurements = [];
wellID = allUniqueWells;
timeOfMeasurements = read.measurementTimepoints;
timeOfFastKineticsMeasurements = fastKineticsCalculator(wellID, 11 , read.interval, read.measurementTimepoints)';
emptyMeasurements = read.measurements{1};
emptyMeasurements(:) = NaN;
for wellIndex = 1 : numel(allUniqueWells)    
   if wellIsPresentInGen5Read(read, allUniqueWells{wellIndex})
       
       measurements(:, :, wellIndex) = read.measurements(:,:,findGen5ReadWellIndex(read, allUniqueWells{wellIndex}));
       times = timeOfFastKineticsMeasurements(:, findGen5ReadWellIndex(read, allUniqueWells{wellIndex})); 
       endTimeOfFastKineticsMeasurements(1:numel(times),wellIndex) = times; 
   else
       measurements{wellIndex} = emptyMeasurements;
       endTimeOfFastKineticsMeasurements(1:read.numberOfCycles, wellIndex) = deal(NaN);
   end
end
read.measurements = measurements;
read.fastKineticsMeasurementsTimepoints = endTimeOfFastKineticsMeasurements;
wellID = wellID';
for index = 1 : numel(wellID)
   wellID(index) = {wellID(index)}; 
end
read.wellID = wellID;


function result = wellIsPresentInGen5Read(read, wellID)
wellIDs = cell(numel(read.wellID), 1);

for index = 1 : numel(read.wellID)
   wellIDs{index} = read.wellID{index}{1};
end

isPresentCell = strfind(wellIDs, wellID);
result = 0;
for cellIndex = 1 : numel(isPresentCell)
   if isequal(isPresentCell{cellIndex}, 1)
       result = 1;
       return
   end
end

function result = findGen5ReadWellIndex(read, wellID)
wellIDs = cell(numel(read.wellID), 1);

for index = 1 : numel(read.wellID)
   wellIDs{index} = read.wellID{index}{1};
end

isPresentCell = strfind(wellIDs, wellID);
result = 0;
for cellIndex = 1 : numel(isPresentCell)
   if isequal(isPresentCell{cellIndex}, 1)
       result = cellIndex;
       return
   end
end

function result = wellIsPresentInExperiment(dataStruct, wellID)
isPresentCell = strfind(dataStruct.wellID, wellID);
result = 0;
for cellIndex = 1 : numel(isPresentCell)
   if isequal(isPresentCell{cellIndex}, 1)
       result = 1;
       return
   end
end

function index = findWellIndex(dataStruct, wellID)
isPresentCell = strfind(dataStruct.wellID, wellID);
for cellIndex = 1 : numel(isPresentCell)
   if isequal(isPresentCell{cellIndex}, 1)
       index = cellIndex;
       return
   end
end


function reorganizedExperimentDataStructure = standardizeWellOrder(experimentDataStructure)
    
    % organise the wells into a certain order (A1, A2, ...., A12, B1, B2,
    % ...., H11, H12)
    wellID = experimentDataStructure.wellID;
%     for wellIndex = 1 : numel(rawWellID)
%        wellID{wellIndex} = rawWellID{wellIndex}{1}; 
%     end
    [height,width, ghostplateWellID, inUse] = generateGhostplate(wellID');
    ghostplateWellID = reshape(ghostplateWellID, 1, numel(ghostplateWellID));
    
    for wellIndex = 1 : numel(wellID)
       trueWellIndexMatrix = strcmp(ghostplateWellID, wellID{wellIndex});
       for wellIndex2 = 1 : numel(trueWellIndexMatrix);
           if isequal(trueWellIndexMatrix(wellIndex2), 1)
              trueWellIndex(wellIndex) = wellIndex2;
           end
       end
    end
    reorganizedFastKinetics = zeros(size(experimentDataStructure.timeOfFastKineticsMeasurements, 1), size(experimentDataStructure.timeOfFastKineticsMeasurements, 2));
    sortedTrueWellIndex = sort(trueWellIndex);
    for wellIndex = 1 : numel(wellID)
       order(wellIndex) = find(sortedTrueWellIndex == trueWellIndex(wellIndex));
       orderedWellIndeces{order(wellIndex)} = wellID{wellIndex}; 
       reorganizedMeasurements{order(wellIndex)} = experimentDataStructure.measurements{wellIndex};
       reorganizedFastKinetics(:, order(wellIndex)) = experimentDataStructure.timeOfFastKineticsMeasurements(:, wellIndex);
    end
    reorganizedExperimentDataStructure = experimentDataStructure;
%     for wellIndex = 1 : numel(rawWellID)
%        finalWellID{wellIndex}{1} = orderedWellIndeces{wellIndex};
%     end
    reorganizedExperimentDataStructure.wellID = orderedWellIndeces;
    reorganizedExperimentDataStructure.measurements = reorganizedMeasurements;
    reorganizedExperimentDataStructure.timeOfFastKineticsMeasurements = reorganizedFastKinetics;

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(handles.figure1, 'waitstatus'),'waiting')
    uiresume(handles.figure1)
else
    delete(handles.figure1);
end

guidata(hObject, handles);
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = generateDataStructure(handles);
if isequal(get(handles.figure1, 'waitstatus'),'waiting')
    uiresume(handles.figure1);
    guidata(hObject, handles);
else
    delete(handles.figure1);
    guidata(hObject, handles);
end
