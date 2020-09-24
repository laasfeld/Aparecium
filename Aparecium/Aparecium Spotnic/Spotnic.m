function varargout = Spotnic(varargin)
% SPOTNIC MATLAB code for Spotnic.fig
%      SPOTNIC, by itself, creates a new SPOTNIC or raises the existing
%      singleton*.
%
%      H = SPOTNIC returns the handle to a new SPOTNIC or the handle to
%      the existing singleton*.
%
%      SPOTNIC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPOTNIC.M with the given input arguments.
%
%      SPOTNIC('Property','Value',...) creates a new SPOTNIC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Spotnic_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Spotnic_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Edit the above text to modify the response to help Spotnic
 
% Last Modified by GUIDE v2.5 24-Sep-2020 17:59:56
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Spotnic_OpeningFcn, ...
                   'gui_OutputFcn',  @Spotnic_OutputFcn, ...
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
 
 
% --- Executes just before Spotnic is made visible.
function Spotnic_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Spotnic (see VARARGIN)
 
addApareciumToPath();
% Choose default command line output for Spotnic

handles.output = hObject;
handles.mainImageFolder = [];
handles.subDirNames = [];
handles.imageNamesOfFolder = cell(0,0);
handles.histogramsOfFolder = cell(0,0);
handles.imageIndecesOfFolder = cell(0,0);
handles.spotAnalysisResults = cell(0,0);
handles.imageStatisticsResults = cell(0,0);
handles.SDO = [];
toolboxLocation = fileparts(mfilename('fullpath'));
filename = mfilename('fullpath');
thisPath = fileparts(filename);
handles.metricToDisplay = 'spot count';
handles.recommendedThreshold = nan;

handles.experimentDataStructure = [];
handles.dimensionality = 1;
handles.fastKinetics = [];
handles.outputChannelNames = [];
handles.treatments_TableData = {'', '', ''}; 
handles.MIDAS_tableData = {};
handles.midasTableController = MidasTableController('empty'); % Create a new MIDAS table controller but don´t assign an actual table for it to control
handles.midasTableController.addTreatmentColumn(' ', '', ''); % Set up the standard parameters for the MIDAS table 
handles.apareciumExperimentInput = ApareciumExperimentInput();
handles.plateSimulatorInterface = PlateSimulatorInterface();
handles.simPlateHandle = [];
handles.fileName = [];
% for i=numel(subdirs):-1:1
%     subdirs{i} = fullfile(thisPath, subdirs{i}{:});
%     if ~isdir(subdirs{i})
%         subdirs(i) = [];
%     end
% end
% addpath(subdirs{:});
addpath(genpath(toolboxLocation));
handles.analysisMode = '';
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes Spotnic wait for user response (see UIRESUME)
% uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = Spotnic_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
 
 
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.analysisMode = 'images';
set(handles.checkbox6, 'Enable', 'on');
handles.imageNamesOfFolder = cell(0,0);
 
handles.mainImageFolder = uigetdir('\\OMERO\Users\Karl Rene');
subDirectories = dir(handles.mainImageFolder);
subDirectories(1:2) = [];
realSubDirs = cell(0,0);
for subDirIndex = 1 : numel(subDirectories)
    if isequal(subDirectories(subDirIndex).isdir, 1)
       realSubDirs{end+1} = subDirectories(subDirIndex).name;
    end
end
handles.imageIndecesOfFolder = cell(numel(realSubDirs),0);
handles.subDirNames = realSubDirs;
set(handles.wellNames, 'String', handles.subDirNames);
imageNames = cell(0,0);
for subDirIndex = 1 : numel(handles.subDirNames)
    dirContents = dir([handles.mainImageFolder,'/',handles.subDirNames{subDirIndex}]);
    dirContents(1:2) = [];
    folderImageNames = cell(0,0);
    handles.imageIndecesOfFolder{subDirIndex} = [];
    for itemIndex = 1 : numel(dirContents)
       if strcmp(dirContents(itemIndex).name(end-2:end), 'tif')
           imageNames{end+1} = dirContents(itemIndex).name;
           folderImageNames{end+1} = dirContents(itemIndex).name;
           handles.imageIndecesOfFolder{subDirIndex} = [handles.imageIndecesOfFolder{subDirIndex}, numel(imageNames)];
       end
    end
    handles.imageNamesOfFolder{end+1} = folderImageNames;
end
handles.imageNamesOfFolder 
set(handles.imageNames, 'String', imageNames);
for dirIndex = 1 : numel(handles.subDirNames)  
    result = calculateImageStatistics(0, [handles.mainImageFolder,'/', handles.subDirNames{dirIndex}], false, 'max');
    waitbar(dirIndex/numel(handles.subDirNames));
    handles.imageStatisticsResults{dirIndex} = cell2mat(result(:,2:end));
end
guidata(hObject, handles);

function handles = calculateRecommendedThreshold(handles, indices)
allMeans = [];
allSTDs = [];
allMedians = [];
for i = 1 : numel(handles.imageStatisticsResults)
    allMeans = [allMeans; handles.imageStatisticsResults{i}(:, 1)];
    try
        allSTDs = [allSTDs; handles.imageStatisticsResults{i}(:, 3)];
    catch
        %skip
    end
    allMedians = [allMedians; handles.imageStatisticsResults{i}(:, 2)];
end
generalSTD = pooledSTD(ones(numel(indices), 1), allMeans(indices), allSTDs(indices));
generalMedian = mean(allMedians(indices));
set(handles.text13, 'String', ['Recommended threshold (~median + 1*sigma)=', num2str(generalMedian + 1*generalSTD)]);
handles.recommendedThreshold = generalMedian + 1*generalSTD;


% --- Executes on selection change in imageNames.
function imageNames_Callback(hObject, eventdata, handles)
% hObject    handle to imageNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = cellstr(get(hObject,'String')) returns imageNames contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imageNames
handles = calculateRecommendedThreshold(handles, get(hObject,'Value'));
try
    contents = cellstr(get(hObject,'String'));
    imageNames = contents(get(hObject,'Value'));
    values = get(hObject,'Value');
    spotNumber = zeros(numel(values), 1);
    switch handles.metricToDisplay
        case 'spot count'
            parameterIndex = 1;
            header1 = 'Nr of spots';
            header2 = 'Average nr of spots';
        case 'image intensity'
            parameterIndex = 2;
            header1 = 'Image intensity';
            header2 = 'Average image intensity';
        case 'spot intensity'
            parameterIndex = 3;
            header1 = 'spot intensity';
            header2 = 'Average spot intensity';
        case 'spot total intensity'
            parameterIndex = 4;
            header1 = 'spot total intensity';
            header2 = 'average total intensity';
        case 'Spot total intensity over image background'
            parameterIndex = 5;
            header1 = 'spot total intensity over image background';
            header2 = 'average spot total intensity over image background';
            
    end
    for imageIndex = 1 : numel(values)
       for subDir = 1 : numel(handles.imageIndecesOfFolder)
          for imageIndexInFolder = 1 : numel(handles.imageIndecesOfFolder{subDir})
             if isequal(values(imageIndex), handles.imageIndecesOfFolder{subDir}(imageIndexInFolder))
                parameterValue(imageIndex) = handles.spotAnalysisResults{subDir}(imageIndexInFolder, parameterIndex);
             end
          end
       end
    end
    dataTable = cell(numel(parameterValue)+1, 6);
    dataTable{1, 1} = 'Threshold:';
    dataTable{1, 2} = get(handles.threshold, 'String');
    dataTable{2, 1} = 'File name';

    dataTable{2, 2} = header1;
    dataTable{2, 3} = header2;
    dataTable{2, 4} = 'Standard deviation';
    dataTable{2, 5} = 'Standard error of the mean';
    dataTable{2, 6} = 'Voronoi standard deviation of spots per pixel';
    dataTable{3, 3} = nanmean(parameterValue);
    dataTable{3, 4} = nanstd(parameterValue);
    dataTable{3, 5} = nanstd(parameterValue)/sqrt(numel(parameterValue));
    for row = 1 : numel(parameterValue)
        dataTable{row+2, 1} = imageNames{row};
        dataTable{row+2, 2} = parameterValue(row);
    end
    set(handles.uitable1, 'Data', dataTable);
    

    
catch
    
end

% If single image is selected, visualize it

if strcmp(handles.analysisMode, 'images') && isequal(numel(imageNames), 1);
    for imageIndex = 1 : numel(values)
       for subDir = 1 : numel(handles.imageIndecesOfFolder)
          for imageIndexInFolder = 1 : numel(handles.imageIndecesOfFolder{subDir})
             if isequal(values(imageIndex), handles.imageIndecesOfFolder{subDir}(imageIndexInFolder))
                imageDir = subDir;
                imageIndexInFolder_final = imageIndexInFolder;
                break;
             end
          end
       end
    end
    
    % construct the full path
    fileEndIndex = strfind(handles.imageNamesOfFolder{imageDir}{imageIndexInFolder_final}, '.tif');
    fileName = handles.imageNamesOfFolder{imageDir}{imageIndexInFolder_final}(1 : fileEndIndex(end)+3);
    subfolderNames = get(handles.wellNames, 'String');
    fullPath = fullfile(handles.mainImageFolder, subfolderNames{imageDir}, fileName);
    info = imfinfo(fullPath);
    baseFrame = zeros(info(1).Height, info(1).Width, numel(handles.spotAnalysisLayerToRead{imageDir}{imageIndexInFolder_final}));
    if get(handles.showImage, 'Value')
        for k = 1 : numel(handles.spotAnalysisLayerToRead{imageDir}{imageIndexInFolder_final})
            baseFrame(:,:,k) = imread(fullPath, handles.spotAnalysisLayerToRead{imageDir}{imageIndexInFolder_final}(k));
        end
    end
    baseFrame = mean(baseFrame, 3);
    baseFrame = baseFrame/max(max(baseFrame)); % normalize
    baseFrame = repmat(baseFrame, [1 1 3]); % make RGB compatible
    finalFrame = baseFrame;
    
    if get(handles.showMask, 'Value') 
        if get(handles.showSimpleMask, 'Value')
            finalFrame(:,:,1) = max(cat(3, finalFrame(:,:,1), double(handles.spotAnalysisBinaryMasks{imageDir}{imageIndexInFolder_final})), [], 3);
        elseif get(handles.showThresholdedMask, 'Value')
            baseMask = 0;
        end
        
        if get(handles.showStencilMask, 'Value')
            
        end
    end
    hold off
    imshow(finalFrame, 'Parent', handles.axes9);
    hold on
    if get(handles.showSpotCentroids, 'Value')
        spotXLoc = handles.spotAnalysisSpotLocations{imageDir}{imageIndexInFolder_final}.x;
        spotYLoc = handles.spotAnalysisSpotLocations{imageDir}{imageIndexInFolder_final}.y;
        plot(spotXLoc, spotYLoc, 'rO', 'Parent', handles.axes9)
    end
    if get(handles.showSurroundingPolygon, 'Value')
        [vx, vy] = voronoi(handles.spotAnalysisSpotLocations{imageDir}{imageIndexInFolder_final}.x, handles.spotAnalysisSpotLocations{imageDir}{imageIndexInFolder_final}.y);
        plot(vx,vy,'r-', 'Parent', handles.axes9);
    end
end
guidata(hObject, handles);
 
 
% --- Executes during object creation, after setting all properties.
function imageNames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imageNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'max', 2);
guidata(hObject, handles);
 
 
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
 
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
 
 
function threshold_Callback(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of threshold as text
%        str2double(get(hObject,'String')) returns contents of threshold as a double
 
 
% --- Executes during object creation, after setting all properties.
function threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
% --- Executes on button press in startAnalysis.
function startAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to startAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.spotAnalysisResults = cell(numel(handles.subDirNames),1);
handles.spotAnalysisBinaryMasks = cell(numel(handles.subDirNames),1);
handles.spotAnalysisSpotLocations = cell(numel(handles.subDirNames),1);
handles.spotAnalysisLayerToRead = cell(numel(handles.subDirNames),1);
threshold = str2double(get(handles.threshold, 'String'));
f = waitbar(0, 'Detecting spots');
for dirIndex = 1 : numel(handles.subDirNames)
    if strcmp(handles.analysisMode, 'images');
        sigma = str2double(get(handles.spotSigma, 'String')); % get the expected spot size for the spot detector.
        [result, binaryMask, spotLocations, layersToRead] = spotDetection(threshold, [handles.mainImageFolder,'/', handles.subDirNames{dirIndex}], false, 'max', 0, [], sigma);
        waitbar(dirIndex/numel(handles.subDirNames));
        handles.spotAnalysisResults{dirIndex} = cell2mat(result(:,2:end));
        handles.spotAnalysisBinaryMasks{dirIndex} = binaryMask;
        handles.spotAnalysisSpotLocations{dirIndex} = spotLocations;
        handles.spotAnalysisLayerToRead{dirIndex} = layersToRead;
    elseif strcmp(handles.analysisMode, 'histograms')
        result = spotHistogramStatistics(threshold, handles.histogramsOfFolder{dirIndex});
        waitbar(dirIndex/numel(handles.subDirNames));
        handles.spotAnalysisResults{dirIndex} = cell2mat(result(:,2:end));
    end
end
close(f);
handles.result = result;
imageNames_Callback(handles.imageNames, eventdata, handles);
handles = generateExperimentDataStructureFromResults(handles);
guidata(hObject, handles);
 
function handles = generateExperimentDataStructureFromResults(handles)

experimentDataStructure.wellID = get(handles.wellNames, 'String')';
experimentDataStructure.channelNames = handles.apareciumExperimentInput.getChannelNames;
experimentDataStructure.numberOfChannels = handles.apareciumExperimentInput.getNumberOfChannels;
experimentDataStructure.cycleTime = 0;
experimentDataStructure.readingDirection = -1;
experimentDataStructure.timeOfMeasurements = 0;
experimentDataStructure.temperature = 0;

for wellIndex = (1 : numel(experimentDataStructure.wellID))
    imageIndices = handles.imageIndecesOfFolder{wellIndex};
    parameterValue = cell(numel(get(handles.parameterList, 'Value')), 1);
    for imageIndex = 1 : numel(imageIndices)
        for subDir = 1 : numel(handles.imageIndecesOfFolder)
            for imageIndexInFolder = 1 : numel(handles.imageIndecesOfFolder{subDir})
                if isequal(imageIndices(imageIndex), handles.imageIndecesOfFolder{subDir}(imageIndexInFolder))
                    for parameterIndex = get(handles.parameterList, 'Value')
                        parameterValue{parameterIndex}(imageIndex) = handles.spotAnalysisResults{subDir}(imageIndexInFolder, parameterIndex);
                    end
                end
            end
        end
    end
    statisticVectorFunctions = cell(4, 1);
    statisticVectorFunctions{1} = @mean;
    statisticVectorFunctions{2} = @std;
    statisticVectorFunctions{3} = @(a) std(a)/sqrt(numel(a));
    statisticVectorFunctions{4} = @numel;
    wellMeasurements = zeros(experimentDataStructure.numberOfChannels, 1);
    counter = 1;
    for parameterIndex = get(handles.parameterList, 'Value')
        for statisticIndex = get(handles.statisticsList, 'Value')
            wellMeasurements(counter) = statisticVectorFunctions{statisticIndex}(parameterValue{parameterIndex});
            counter = counter + 1;
        end
    end
    experimentDataStructure.measurements{wellIndex} = wellMeasurements;
    
end

experimentDataStructure.channelNames = handles.apareciumExperimentInput.getChannelNames;
experimentDataStructure.numberOfChannels = handles.apareciumExperimentInput.getNumberOfChannels;

handles.experimentDataStructure = experimentDataStructure;
handles.apareciumExperimentInput.setMeasurements(experimentDataStructure.measurements);
handles = generateApareciumExperimentInput(handles, handles.experimentDataStructure);
numberOfChannels = handles.apareciumExperimentInput.getNumberOfChannels;
if isequal(numberOfChannels, 1)
    handles.midasTableController.startWithOneMeasurementColumnOneTreatmentColumn();
end
updateMidasChannels(handles);
rawData = sendDataToMidasTable(handles.experimentDataStructure, handles.dimensionality);
%handles.apareciumExperimentInput.setChannelNames({''});
handles = changeDimensionality(handles, handles.dimensionality);
handles.midasTableController.setData(rawData);
updateMidasChannels(handles);
%handles.midasTableController.setEventDataEqualToData();
''





% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3
 
 
% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
% --- Executes on button press in addToNS.
function addToNS_Callback(hObject, eventdata, handles)
% hObject    handle to addToNS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
possibleValues = get(handles.wellNames, 'String');
set(handles.NSList, 'String', unique([get(handles.NSList, 'String'); possibleValues(get(handles.wellNames, 'Value'))]));
guidata(hObject, handles);
 
% --- Executes on button press in addToSpecific.
function addToSpecific_Callback(hObject, eventdata, handles)
% hObject    handle to addToSpecific (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
possibleValues = get(handles.wellNames, 'String');
set(handles.specificList, 'String', unique([get(handles.specificList, 'String'); possibleValues(get(handles.wellNames, 'Value'))]));
guidata(hObject, handles);
 
% --- Executes on selection change in wellNames.
function wellNames_Callback(hObject, eventdata, handles)
% hObject    handle to wellNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = cellstr(get(hObject,'String')) returns wellNames contents as cell array
%        contents{get(hObject,'Value')} returns selected item from wellNames
wellIndex = get(hObject, 'Value');
set(handles.imageNames, 'Value', horzcat(handles.imageIndecesOfFolder{wellIndex}));
imageNames_Callback(handles.imageNames, eventdata, handles);
guidata(hObject, handles);
 
% --- Executes during object creation, after setting all properties.
function wellNames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wellNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'max', 2);
guidata(hObject, handles);
 
 
% --- Executes on selection change in specificList.
function specificList_Callback(hObject, eventdata, handles)
% hObject    handle to specificList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = cellstr(get(hObject,'String')) returns specificList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from specificList
 
 
% --- Executes during object creation, after setting all properties.
function specificList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to specificList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'max', 2);
guidata(hObject, handles);
 
% --- Executes on button press in optimize.
function optimize_Callback(hObject, eventdata, handles)
% hObject    handle to optimize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.SDO = spotDetectionOptimizer(handles.mainImageFolder, get(handles.specificList, 'String'), get(handles.NSList, 'String'));
SDO = handles.SDO;
options = optimset('fminbnd');
options.MaxFunEvals = 20;
options.TolX = 10;
options.TypicalX = 5000;
[bestX, bestY, status, summaryStruct] = fminbnd(@SDO.calculateRatio,2000,9000,options);
set(handles.optimisationSummary, 'String', ['Completed. Best threshold: ', num2str(bestX),' .Best achieved ratio: ', num2str(-bestY), ' . Number of iterations:'... 
    , num2str(summaryStruct.iterations)]);
 
guidata(hObject, handles);
 
% --- Executes on selection change in NSList.
function NSList_Callback(hObject, eventdata, handles)
% hObject    handle to NSList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = cellstr(get(hObject,'String')) returns NSList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NSList
 
 
% --- Executes during object creation, after setting all properties.
function NSList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NSList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'max', 2);
guidata(hObject, handles);
 
% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lowerLimit = str2double(get(handles.edit2, 'String'));
step = str2double(get(handles.edit3, 'String'));
upperLimit = str2double(get(handles.edit4, 'String'));
SDO = spotDetectionOptimizer(handles.mainImageFolder, get(handles.specificList, 'String'), get(handles.NSList, 'String'));
thresholds = lowerLimit:step:upperLimit;
 
for i = 1 : numel(thresholds)
    SDO.calculateRatio(thresholds(i));
end
 
table = cell(numel(SDO.usedThresholds), size(SDO.folderNameMatrix, 2)*2 + 1);
table(:, 1) = num2cell(SDO.usedThresholds);
colNames = cell(1, size(SDO.folderNameMatrix, 2)*2 + 1);
colNames{1} = 'Threshold';
for col = 2 : size(SDO.folderNameMatrix, 2) + 1
    table(:, col*2-2) = num2cell(SDO.foundSpecificSpotMatrix(:, col-1));
    table(:, col*2-1) = num2cell(SDO.foundSpecificSpotSTDMatrix(:, col-1));
    colNames{col*2-2} = ['Mean ', SDO.folderNameMatrix{1, col-1}];
    colNames{col*2-1} = ['STD ', SDO.folderNameMatrix{1, col-1}];
end
set(handles.uitable2, 'data', table, 'ColumnName', colNames);
% hint to divide vectors use ./
plot(handles.axes1, SDO.usedThresholds, SDO.foundRatios,'*r','MarkerSize',10);
xlabel(handles.axes1,'Threshold');
ylabel(handles.axes1,'TOT/NS ratio');
plot(handles.axes2, SDO.usedThresholds, SDO.foundSpecificSpots,'*r','MarkerSize',10);
xlabel(handles.axes2,'threshold');
ylabel(handles.axes2,'TOT spots');
plot(handles.axes3, SDO.usedThresholds, SDO.foundNSSpots,'*r','MarkerSize',10);
xlabel(handles.axes3,'threshold');
ylabel(handles.axes3,'NS spots');
plot(handles.axes4, SDO.usedThresholds, SDO.specificSpotSTD,'*r','MarkerSize',10);
xlabel(handles.axes4,'threshold');
ylabel(handles.axes4,'TOT spots STD');
plot(handles.axes5, SDO.usedThresholds, SDO.NSSpotSTD,'*r','MarkerSize',10);
xlabel(handles.axes5,'threshold');
ylabel(handles.axes5,'NS spots STD');
plot(handles.axes6, SDO.usedThresholds, SDO.ZPrime,'*r','MarkerSize',10);
xlabel(handles.axes6,'threshold');
ylabel(handles.axes6,'Z-faktor');
plot(handles.axes7, SDO.usedThresholds, 100.*SDO.specificSpotSTD./SDO.foundSpecificSpots,'*r','MarkerSize',10);
xlabel(handles.axes7,'threshold');
ylabel(handles.axes7,'TOT spots relSTD');
plot(handles.axes8, SDO.usedThresholds, 100.*SDO.NSSpotSTD./SDO.foundNSSpots,'*r','MarkerSize',10);
xlabel(handles.axes8,'threshold');
ylabel(handles.axes8,'NS spots relSTD');
 
axisHandles = cell(8,1);
axisHandles{1} = handles.axes1;
axisHandles{2} = handles.axes2;
axisHandles{3} = handles.axes3;
axisHandles{4} = handles.axes4;
axisHandles{5} = handles.axes5;
axisHandles{6} = handles.axes6;
axisHandles{7} = handles.axes7;
axisHandles{8} = handles.axes8;
 
fileNames = cell(8,1);
fileNames{1} = 'Ratio.png';
fileNames{2} = 'TOT punktid.png';
fileNames{3} = 'MS punktid.png';
fileNames{4} = 'TOT stdev.png';
fileNames{5} = 'MS stdev.png';
fileNames{6} = 'Z-faktor.png';
fileNames{7} = 'TOT relstdev.png';
fileNames{8} = 'MS relstdev.png';
 
for i = 1 : 8
    handle = figure;
    copyobj(axisHandles{i}, handle);
    set(handle, 'Position', [0 0 650 600]);
    handle.Children.Position = [10 , 5 , 100,38];
    saveas(handle, fileNames{i});
    close(handle);
end
handles.SDO = SDO;
guidata(hObject, handles);
 
 
function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
 
 
% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
 
function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
 
 
% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
 
function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
 
 
% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
'a'
maxImages = 0;
for wellIndex = 1 : size(handles.SDO.imageSpotCounts, 2)
    maxImages = max([maxImages, numel(handles.SDO.imageSpotCounts{wellIndex})]);
end
 
table = cell(maxImages, size(handles.SDO.imageSpotCounts, 2));
colNames = cell(1, size(handles.SDO.folderNameMatrix, 2));
for col = 1 : size(handles.SDO.folderNameMatrix, 2)
    table(1:numel(handles.SDO.imageSpotCounts{col}), col) = num2cell(handles.SDO.imageSpotCounts{col});
    colNames{col} = ['Counts ', handles.SDO.folderNameMatrix{1, col}];
end
set(handles.uitable2, 'data', table, 'ColumnName', colNames);
 
% --- Executes on button press in removeFromSpecific.
function removeFromSpecific_Callback(hObject, eventdata, handles)
% hObject    handle to removeFromSpecific (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wellNames = get(handles.specificList, 'String');
removableIndeces = get(handles.specificList, 'Value');
wellNames(removableIndeces) = [];
set(handles.specificList, 'String', wellNames);
set(handles.specificList, 'Value', 1);
guidata(hObject, handles);
 
% --- Executes on button press in removeFromNS.
function removeFromNS_Callback(hObject, eventdata, handles)
% hObject    handle to removeFromNS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wellNames = get(handles.NSList, 'String');
removableIndeces = get(handles.NSList, 'Value');
wellNames(removableIndeces) = [];
set(handles.NSList, 'String', wellNames);
set(handles.NSList, 'Value', 1);
guidata(hObject, handles);
 
 
% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
   plot(handles.axes1, handles.SDO.usedThresholds, handles.SDO.foundRatios,'*r','MarkerSize',10); 
catch
    
end
 
 
% --- Executes on button press in loadImageStacks.
function loadImageStacks_Callback(hObject, eventdata, handles)
% hObject    handle to loadImageStacks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.analysisMode = 'images';
set(handles.checkbox6, 'Enable', 'on');
handles.imageNamesOfFolder = cell(0,0);
 
handles.mainImageFolder = uigetdir();
subDirectories = dir(handles.mainImageFolder);
subDirectories(1:2) = [];
realSubDirs = cell(0,0);
for subDirIndex = 1 : numel(subDirectories)
    if isequal(subDirectories(subDirIndex).isdir, 1)
       realSubDirs{end+1} = subDirectories(subDirIndex).name;
    end
end
handles.imageIndecesOfFolder = cell(numel(realSubDirs),0);
handles.subDirNames = realSubDirs;
set(handles.wellNames, 'String', handles.subDirNames);
imageNames = cell(0,0);
for subDirIndex = 1 : numel(handles.subDirNames)
    dirContents = dir([handles.mainImageFolder,'/',handles.subDirNames{subDirIndex}]);
    dirContents(1:2) = [];
    folderImageNames = cell(0,0);
    handles.imageIndecesOfFolder{subDirIndex} = [];
    for itemIndex = 1 : numel(dirContents)
       if strcmp(dirContents(itemIndex).name(end-2:end), 'tif')
           
           [imageLocationIndices, timeIndexVector] = imageLocExtractor([handles.mainImageFolder, '\', realSubDirs{subDirIndex}, '\', dirContents(itemIndex).name]);
           uniqueLocations = unique(imageLocationIndices);
           for imageLayer = 1 : numel(uniqueLocations)
               
               if isequal(numel(imageLocationIndices), 1)
                   imageNames{end+1} = dirContents(itemIndex).name;
               else
                   imageNames{end+1} = [dirContents(itemIndex).name, '_', num2str(imageLayer), '_1-',num2str(sum(imageLocationIndices == imageLayer)) ];
               end
               folderImageNames{end+1} = imageNames{end};
               handles.imageIndecesOfFolder{subDirIndex} = [handles.imageIndecesOfFolder{subDirIndex}, numel(imageNames)];
           end
           
       end
    end
    handles.imageNamesOfFolder{end+1} = folderImageNames;
end
handles.imageNamesOfFolder 
set(handles.imageNames, 'String', imageNames);
for dirIndex = 1 : numel(handles.subDirNames)  
    result = calculateImageStatistics(0, [handles.mainImageFolder,'/', handles.subDirNames{dirIndex}], false, 'max');
    waitbar(dirIndex/numel(handles.subDirNames));
    handles.imageStatisticsResults{dirIndex} = cell2mat(result(:,2:end));
end
handles = folderNamesToExperimentDataStructure(handles);

% Find the layers to read for each image

handles.spotAnalysisLayerToRead = cell(numel(handles.subDirNames),1);
threshold = str2double(get(handles.threshold, 'String'));
f = waitbar(0, 'Detecting spots');
for dirIndex = 1 : numel(handles.subDirNames)
    if strcmp(handles.analysisMode, 'images');
        layersToRead = getLayersToRead([handles.mainImageFolder,'/', handles.subDirNames{dirIndex}], 'max');
        handles.spotAnalysisLayerToRead{dirIndex} = layersToRead;
    end
end

guidata(hObject, handles);

function handles = folderNamesToExperimentDataStructure(handles)
handles = generateChannelNames(handles);
experimentDataStructure.wellID = get(handles.wellNames, 'String')';
experimentDataStructure.channelNames = handles.apareciumExperimentInput.getChannelNames;
experimentDataStructure.numberOfChannels = handles.apareciumExperimentInput.getNumberOfChannels;
experimentDataStructure.cycleTime = 0;
experimentDataStructure.readingDirection = -1;
experimentDataStructure.timeOfMeasurements = 0;
experimentDataStructure.temperature = 0;
experimentDataStructure.measurements = {0};

handles.experimentDataStructure = experimentDataStructure;
handles = generateApareciumExperimentInput(handles, handles.experimentDataStructure);
numberOfChannels = handles.apareciumExperimentInput.getNumberOfChannels;
if isequal(numberOfChannels, 1)
    handles.midasTableController.startWithOneMeasurementColumnOneTreatmentColumn();
end
rawData = sendDataToMidasTable(handles.experimentDataStructure, handles.dimensionality);

%handles.apareciumExperimentInput.setChannelNames({''});
handles.midasTableController.setData(rawData);


function handles = generateChannelNames(handles)

parameters = get(handles.parameterList, 'String');
includedParameters = get(handles.parameterList, 'Value');

statistics = get(handles.statisticsList, 'String');
includedStatistics = get(handles.statisticsList, 'Value');

channelNames = cell(numel(includedParameters) * numel(includedStatistics), 1);

counter = 1;
for param = includedParameters
    for statistic = includedStatistics
        channelNames{counter} = [parameters{param}, ' ', statistics{statistic}];
        counter = counter + 1;
    end
end
handles.apareciumExperimentInput.setChannelNames(channelNames);
updateMidasChannels(handles);


function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in displaySpotCount.
function displaySpotCount_Callback(hObject, eventdata, handles)
% hObject    handle to displaySpotCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displaySpotCount
handles.metricToDisplay = 'spot count';
imageNames_Callback(handles.imageNames, eventdata, handles)
guidata(hObject, handles);

% --- Executes on button press in displayImageIntensity.
function displayImageIntensity_Callback(hObject, eventdata, handles)
% hObject    handle to displayImageIntensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayImageIntensity
handles.metricToDisplay = 'image intensity';
imageNames_Callback(handles.imageNames, eventdata, handles)
guidata(hObject, handles);


% --- Executes on button press in displaySpotIntensity.
function displaySpotIntensity_Callback(hObject, eventdata, handles)
% hObject    handle to displaySpotIntensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displaySpotIntensity
handles.metricToDisplay = 'spot intensity';
imageNames_Callback(handles.imageNames, eventdata, handles)
guidata(hObject, handles);


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
''


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4
handles.metricToDisplay = 'spot total intensity';
imageNames_Callback(handles.imageNames, eventdata, handles)
guidata(hObject, handles);


% --- Executes on button press in OpenPlateSimulator.
function OpenPlateSimulator_Callback(hObject, eventdata, handles)
% hObject    handle to OpenPlateSimulator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputStruct.data = handles.midasTableController.getMidasTable(); % get the data from the MidasTableController
inputStruct.fileName = ''; 
saveMidasFile(inputStruct); % allow the user save the MIDAS file

% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.midasTableController.setEventDataEqualToData(); % prepare midasTableController for moving to export wizard
ExportTools(handles.midasTableController); % move the object to export wizard

% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in loadConfigurationFile.
function loadConfigurationFile_Callback(hObject, eventdata, handles)
% hObject    handle to loadConfigurationFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SaveConfigurationFile.
function SaveConfigurationFile_Callback(hObject, eventdata, handles)
% hObject    handle to SaveConfigurationFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function ChooseDimensionality_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseDimensionality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ChooseDimensionality as text
%        str2double(get(hObject,'String')) returns contents of ChooseDimensionality as a double
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function ChooseDimensionality_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChooseDimensionality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function treatments_Table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to treatments_Table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Data', {'', '', '', 'false', 'false'});
guidata(hObject, handles);


% --- Executes on button press in showImage.
function showImage_Callback(hObject, eventdata, handles)
% hObject    handle to showImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showImage
imageNames_Callback(handles.imageNames, eventdata, handles)

% --- Executes on button press in showMask.
function showMask_Callback(hObject, eventdata, handles)
% hObject    handle to showMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showMask
imageNames_Callback(handles.imageNames, eventdata, handles)

% --- Executes on button press in showSpotCentroids.
function showSpotCentroids_Callback(hObject, eventdata, handles)
% hObject    handle to showSpotCentroids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showSpotCentroids
imageNames_Callback(handles.imageNames, eventdata, handles)

% --- Executes on button press in showSurroundingPolygon.
function showSurroundingPolygon_Callback(hObject, eventdata, handles)
% hObject    handle to showSurroundingPolygon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showSurroundingPolygon
imageNames_Callback(handles.imageNames, eventdata, handles)

% --- Executes on button press in showStencilMask.
function showStencilMask_Callback(hObject, eventdata, handles)
% hObject    handle to showStencilMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showStencilMask


% --- Executes on button press in showThresholdedMask.
function showThresholdedMask_Callback(hObject, eventdata, handles)
% hObject    handle to showThresholdedMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showThresholdedMask


% --- Executes on button press in displaySpotTotalIntensity.
function displaySpotTotalIntensity_Callback(hObject, eventdata, handles)
% hObject    handle to displaySpotTotalIntensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displaySpotTotalIntensity
handles.metricToDisplay = 'spot total intensity';
imageNames_Callback(handles.imageNames, eventdata, handles)
guidata(hObject, handles);

% --- Executes on button press in displaySpotIntensity.
function checkbox15_Callback(hObject, eventdata, handles)
% hObject    handle to displaySpotIntensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displaySpotIntensity


% --- Executes on button press in displayImageIntensity.
function checkbox16_Callback(hObject, eventdata, handles)
% hObject    handle to displayImageIntensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayImageIntensity


% --- Executes on button press in displaySpotCount.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to displaySpotCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displaySpotCount


% --- Executes on selection change in parameterList.
function parameterList_Callback(hObject, eventdata, handles)
% hObject    handle to parameterList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns parameterList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from parameterList
handles = generateChannelNames(handles);
handles = generateExperimentDataStructureFromResults(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function parameterList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameterList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'max', 2)% this allows selection of multiple lines
guidata(hObject, handles);


% --- Executes on selection change in statisticsList.
function statisticsList_Callback(hObject, eventdata, handles)
% hObject    handle to statisticsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns statisticsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from statisticsList
handles = generateChannelNames(handles);
handles = generateExperimentDataStructureFromResults(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function statisticsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to statisticsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'max', 2)% this allows selection of multiple lines
guidata(hObject, handles);


% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles, varargin)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.analysisMode = 'histograms';
set(handles.checkbox6, 'Value', false);
set(handles.checkbox6, 'Enable', 'off');
handles.imageNamesOfFolder = cell(0,0);

if numel(varargin) < 1
    handles.mainImageFolder = uigetdir();
    regexFilter = get(handles.histogramRegexFilter, 'String');
elseif numel(varargin) < 2
    handles.mainImageFolder = varargin{1};
    regexFilter = get(handles.histogramRegexFilter, 'String');
else
    handles.mainImageFolder = varargin{1};
    regexFilter = varargin{2};
end

subDirectories = dir(handles.mainImageFolder);
subDirectories(1:2) = [];
realSubDirs = cell(0,0);
for subDirIndex = 1 : numel(subDirectories)
    if isequal(subDirectories(subDirIndex).isdir, 1)
        realSubDirs{end+1} = subDirectories(subDirIndex).name;
    end
end

handles.imageIndecesOfFolder = cell(numel(realSubDirs),0);
handles.subDirNames = realSubDirs;
set(handles.wellNames, 'String', handles.subDirNames);
imageNames = cell(0,0);


handles.imageNamesOfFolder = cell(0,0);
handles.histogramsOfFolder = cell(0,0);
handles.imageIndecesOfFolder = cell(0,0);

for subDirIndex = 1 : numel(handles.subDirNames)
    dirContents = dir([handles.mainImageFolder,'/',handles.subDirNames{subDirIndex}]);
    dirContents(1:2) = [];
    folderImageNames = cell(0,0);
    handles.imageIndecesOfFolder{subDirIndex} = [];
    
    % filter the correct histogram files
    for itemIndex = numel(dirContents): -1 : 1
        if ~isempty(strfind(dirContents(itemIndex).name, regexFilter)) && (~isempty(strfind(dirContents(itemIndex).name, 'imagePixelHistogram')) || ...
                ~isempty(strfind(dirContents(itemIndex).name, 'nonspotPixelHistogram')) || ...
                ~isempty(strfind(dirContents(itemIndex).name, 'spotHistogram')) || ...
                ~isempty(strfind(dirContents(itemIndex).name, 'spotPixelHistogram')) || ...
                ~isempty(strfind(dirContents(itemIndex).name, 'Sigma')))
        
        else
            dirContents(itemIndex) = [];
        end 
    end
    
    for itemIndex = 1 : numel(dirContents)
        load([handles.mainImageFolder,'/',handles.subDirNames{subDirIndex}, '/', dirContents(itemIndex).name]);
    end
    % Collect the data into a structure
    histograms.spotHistogramX = spotHistogramX;
    histograms.spotHistogramHeights = spotHistogramHeights;
    
    histograms.spotPixelHistogramX = spotPixelHistogramX;
    histograms.spotPixelHistogramHeights = spotPixelHistogramHeights;
    
    histograms.imagePixelHistogramX = imagePixelHistogramX;
    histograms.imagePixelHistogramHeights = imagePixelHistogramHeights;
    
    histograms.nonspotPixelHistogramX = nonspotPixelHistogramX;
    histograms.nonspotPixelHistogramHeights = nonspotPixelHistogramHeights;
    
    histograms.imageCount = numel(locations);
    
    handles.histogramsOfFolder{end + 1} = histograms;
    handles.imageNamesOfFolder{end + 1} = realSubDirs{subDirIndex};
    handles.imageIndecesOfFolder{subDirIndex} = subDirIndex;
end
handles.imageNamesOfFolder 
set(handles.imageNames, 'String', handles.subDirNames);
for dirIndex = 1 : numel(handles.subDirNames)
    result = calculateImageStatisticsFromHistogram(handles.histogramsOfFolder{dirIndex});
    waitbar(dirIndex/numel(handles.subDirNames));
    handles.imageStatisticsResults{dirIndex} = cell2mat(result(:,2:end));
end
handles = folderNamesToExperimentDataStructure(handles);
guidata(hObject, handles);


function histogramRegexFilter_Callback(hObject, eventdata, handles)
% hObject    handle to histogramRegexFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of histogramRegexFilter as text
%        str2double(get(hObject,'String')) returns contents of histogramRegexFilter as a double


% --- Executes during object creation, after setting all properties.
function histogramRegexFilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to histogramRegexFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in displaySpotCountOverImageBackground.
function displaySpotCountOverImageBackground_Callback(hObject, eventdata, handles)
% hObject    handle to displaySpotCountOverImageBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displaySpotCountOverImageBackground
handles.metricToDisplay = 'Spot total intensity over image background';
imageNames_Callback(handles.imageNames, eventdata, handles)
guidata(hObject, handles);


% --- Executes on button press in checkbox18.
function checkbox18_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox18



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spotSigma_Callback(hObject, eventdata, handles)
% hObject    handle to spotSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spotSigma as text
%        str2double(get(hObject,'String')) returns contents of spotSigma as a double


% --- Executes during object creation, after setting all properties.
function spotSigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spotSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showSimpleMask.
function showSimpleMask_Callback(hObject, eventdata, handles)
% hObject    handle to showSimpleMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showSimpleMask
imageNames_Callback(handles.imageNames, eventdata, handles)
