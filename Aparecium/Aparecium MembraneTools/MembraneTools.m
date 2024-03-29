%% Copyright (C) 2016 Tõnis Laasfeld
%   
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

function varargout = MembraneTools(varargin)
% MEMBRANETOOLS M-file for MembraneTools.fig
%      MEMBRANETOOLS, by itself, creates a new MEMBRANETOOLS or raises the existing
%      singleton*.
%
%      H = MEMBRANETOOLS returns the handle to a new MEMBRANETOOLS or the handle to
%      the existing singleton*.
%
%      MEMBRANETOOLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MEMBRANETOOLS.M with the given input
%      arguments.
%
%      MEMBRANETOOLS('Property','Value',...) creates a new MEMBRANETOOLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MembraneTools_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MembraneTools_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MembraneTools

% Last Modified by GUIDE v2.5 23-May-2023 19:04:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MembraneTools_OpeningFcn, ...
                   'gui_OutputFcn',  @MembraneTools_OutputFcn, ...
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


% --- Executes just before MembraneTools is made visible.
function MembraneTools_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MembraneTools (see VARARGIN)

% Choose default command line output for MembraneTools
addApareciumToPath();  % Add all required folders to the MATLAB path
handles.imageImporter = []; % Create a new object that can import the images correctly
handles.imageProcessingParameters = ImageProcessingParameters(); % Create a new object that holds parameters of image analysis
handles.imageProcessingParameters.membraneToolsBackgroundCorrection = MembraneToolsBackgroundCorrection();
handles.imageProcessingParameters.imageSegmentationMode = handles.imageProcessingParameters.Slopes;
handles.imageProcessingParameters.setAutoSaveMasks('on');
handles.imageAnalyzer = MembraneImageAnalyzer(); % Create a new object that analyzes the images
handles.imageAnalyzer.ICSEOrMembrane = 'Membrane';
handles.output = hObject;
handles.dimensionality = 1; % Start off with only one treatment
handles.fastKinetics = [];
handles.outputChannelNames = [];
handles.midasTableController = MidasTableController('empty'); % Create a new MIDAS table controller but don´t assign an actual table for it to control
handles.midasTableController.addTreatmentColumn(' ', '', ''); % Set up the standard parameters for the MIDAS table 
handles.apareciumExperimentInput = ApareciumExperimentInput(); % Create a new object that holds information about treatments and wells
handles.plateSimulatorInterface = PlateSimulatorInterface(); % Create a new object that can commonicate with PlateSimulator which is written in Java
handles.cameraAndLensParameters = CameraAndLensParameters(); % Create a new object that holds information about the camera and the lens that were used
handles.cameraAndLensParameters.pixelSize = str2double(get(handles.pixelLength,'String'));
handles.cameraAndLensParameters.magnification = str2double(get(handles.magnification,'String'));
handles.cameraAndLensParameters.fromImage = get(handles.fromImageTickBox, 'Value');
handles.simPlateHandle = []; % a handle to the PlateSimulator
handles.analysisMode = 'Completed'; % A standard parameter
handles.observationStarted = 0; % No observation is started when the program is launched
handles.TextFieldCellEditor = [];

%% Change the appearance of the GUI 
%set(handles.figure1, 'Color', [225/255, 226/255, 251/255]); 
set(handles.figure1, 'name', 'Membrane Tools')
%%

%% Check the presence of parallel computing toolbox
if isequal(license('test', 'Distrib_Computing_Toolbox'), 1)           
    handles.imageProcessingParameters.setParallelComputing('on'); % use parallel computing
    set(handles.useParallelComputing, 'Value', 1);
else
    set(handles.useParallelComputing, 'Value', 0);
    handles.imageProcessingParameters.setParallelComputing('off');
end

thresholdFunctionNames = ['None', ICSEThresholdManager.getThresholdFunctionNames()];
set(handles.popupmenu1, 'String', thresholdFunctionNames);
handles.imageAnalyzer.thresholdFunctionHandle = eval(['@',thresholdFunctionNames{1}]);
%%

% InitializeCustomCallbacks
set(handles.loadStopwatchTime, 'Callback', createCallback('loadStopwatchTime_Callback'));


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MembraneTools wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MembraneTools_OutputFcn(hObject, eventdata, handles) 
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
if isempty(handles.imageImporter)
    handles.imageImporter = ImageImporter(); % Create a new object that can import the images correctly
    guidata(hObject, handles);
    answer = 'Load new';
else
    answer = questdlg('Images already loaded. Would you like to edit data loading or load new data?', 'question', 'Edit', 'Load new', 'Edit');
    if strcmp(answer, 'Load new')
        handles.imageImporter = ImageImporter();
        guidata(hObject, handles);
    elseif strcmp(answer, 'Edit')
        % pass
    end
end

% set the image name filter options
regexString = get(handles.quantificationChannelRegex,'String');
handles.imageImporter.setQuantificationChannelRegex(regexString);
regexString = get(handles.detectionChannelRegex,'String');
handles.imageImporter.setDetectionChannelRegex(regexString);
lowerStackBound = str2num(get(handles.lowerStackBound,'String'));
handles.imageImporter.setLowerBound(lowerStackBound);
higherStackBound = str2num(get(handles.higherStackBound,'String'));
handles.imageImporter.setHigherBound(higherStackBound);



handles.imageImporter.analyzeQuality = 1;
fileChooser = FileChooser();
if strcmp(answer, 'Load new')
    startingPath = fileChooser.chooseMembraneToolsFolder(); % get the preferred starting folder
    handles.imageImporter.userChooseImageFolders(startingPath); % Ask the user to choose the folder where the folders are that contain images
elseif strcmp(answer, 'Edit')
    handles.imageImporter.editImport();
end
handles.experimentDataStructure = handles.imageImporter.experimentDataStructure; % Get information about which wells were used
handles = generateApareciumExperimentInput(handles, handles.experimentDataStructure); % Generate the ApareciumExperimentInput object based the information from images 
handles.imageProcessingParameters.setFullImageMode();
% enable the options to save masks and focal plane names after quality
% control
set(handles.saveQualityMaskNow, 'enable', 'on');
set(handles.saveBrightFieldFocusNow, 'enable', 'on');
set(handles.saveFluorescenceFocusNow, 'enable', 'on');
guidata(hObject, handles);


% --- Executes on button press in OpenPlateSimulator.
function OpenPlateSimulator_Callback(hObject, eventdata, handles)
% hObject    handle to OpenPlateSimulator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.plateSimulatorInterface.addExperiment(handles.apareciumExperimentInput); % Add information about experiment to the PlateSimulator interface
handles.simPlateHandle = handles.plateSimulatorInterface.generatePlateSimulator(handles); % Create a new PlateSimulator based on the experiment data
handles = setUIModeToPlateSim(handles); % Make the PlateSimulator visible
guidata(hObject, handles);


function handles = setUIModeToPlateSim(handles)
%% Make panels that are not related to the PlateSimulator invisible
set(handles.importImages, 'visible', 'off'); 
set(handles.analysisOptions, 'visible', 'off');
set(handles.analysisStatusPanel, 'visible', 'off');
set(handles.ExperimentConfigurationPanel, 'visible', 'off');
set(handles.uipanel35, 'visible', 'off');
%set(handles.simPlateDone, 'visible', 'on'); % Make the done button visible so the user could finish using PlateSimulator
set(handles.figure1, 'Color', 'white'); % Change the background color
doneCallbackHandle = @simPlateDone_Callback;
doneHandler(handles.plateSimulatorInterface.PlateSimulator.done, handles, doneCallbackHandle);

% --- Executes on button press in loadConfigurationFile.
function loadConfigurationFile_Callback(hObject, eventdata, handles)
% hObject    handle to loadConfigurationFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileChooser = FileChooser();
[fullFilePath, fileName] = fileChooser.chooseConfigurationFile();
handles = changeConfiguration(fullFilePath, handles);
guidata(hObject, handles);
ApareciumCommonImporterFunctions.treatments_Table_CellEditCallback(handles.treatments_Table, eventdata, handles);
handles = guidata(hObject);
if strcmp(handles.fromTreatmentStructure, 'Yes')
    handles.midasTableController.updateTreatments(handles.treatmentStructure);
    handles.plateSimulatorInterface.addExperiment(handles.apareciumExperimentInput);
    handles.simPlateHandle = handles.plateSimulatorInterface.generatePlateSimulator(handles); %% does not show the PlateSimulator
    handles.plateSimulatorInterface.regeneratePlateSimulatorFromTreatmentStructure(handles.treatmentStructure);
    set(handles.simPlateHandle, 'visible', 'off');
    drawnow();
else

end
successBox('Configuration file successfully loaded', 'Success');
guidata(hObject, handles);

% --- Executes on button press in SaveConfigurationFile.
function SaveConfigurationFile_Callback(hObject, eventdata, handles)
% hObject    handle to SaveConfigurationFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.fileName = ''; % We do not know what the fileName is going to be so just assume an empty string to avoid errors
saveConfiguration(handles); % Let the user save a configuration file based the currently active configuration


function ChooseDimensionality_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseDimensionality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ChooseDimensionality as text
%        str2double(get(hObject,'String')) returns contents of ChooseDimensionality as a double
dimensionality = get(hObject,'String'); % Read in the new dimensionality
handles = changeDimensionality(handles, dimensionality); % Make changes in the handles object based on the new dimensionality 
guidata(hObject, handles);

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


% --- Executes on button press in useParallelComputing.
function useParallelComputing_Callback(hObject, eventdata, handles)
% hObject    handle to useParallelComputing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useParallelComputing
value = get(hObject,'Value');
switch value
    case 1
        if isequal(license('test', 'Distrib_Computing_Toolbox'), 1)           
            handles.imageProcessingParameters.setParallelComputing('on'); % use parallel computing
        else
            warndlg('Parallel Computing Toolbox not found, can´t use parallel computing option.');
            set(hObject, 'Value', 0);
            handles.imageProcessingParameters.setParallelComputing('off');
        end
    case 0
        handles.imageProcessingParameters.setParallelComputing('off'); % do not use parallel computing
end
guidata(hObject, handles);

% --- Executes on button press in autoSaveMIDAS.
function autoSaveMIDAS_Callback(hObject, eventdata, handles)
% hObject    handle to autoSaveMIDAS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoSaveMIDAS
switch get(hObject,'Value')
    case 1
        handles.imageProcessingParameters.setAutoSaveMidas('on'); % Automatically save MIDAS files after the analysis is completed
    case 0
        handles.imageProcessingParameters.setAutoSaveMidas('off'); % Do not save MIDAS files automatically
end

% --- Executes on button press in autoSaveBinaryImage.
function autoSaveBinaryImage_Callback(hObject, eventdata, handles)
% hObject    handle to autoSaveBinaryImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoSaveBinaryImage
switch get(hObject,'Value')
    case 0
        handles.imageProcessingParameters.setAutoSaveBinaryFiles('off'); % Do not automatically save binary images
    case 1
        handles.imageProcessingParameters.setAutoSaveBinaryFiles('on'); % Save binary images automatically 
end

% --------------------------------------------------------------------
function options_Callback(hObject, eventdata, handles)
% hObject    handle to options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SettingsUI(); % display settings

% --- Executes when selected object is changed in chooseImageSegmentation.
function chooseImageSegmentation_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in chooseImageSegmentation 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.NewValue 
    case handles.fullImage
        handles.imageProcessingParameters.setFullImageMode(); % Analyze the whole image
    case handles.segmentedFullImage
        handles.imageProcessingParameters.setSegmentedFullImageMode(); % Analyze the whole image but in segments
    case handles.imageCenter
        handles.imageProcessingParameters.setImageCenterMode(); % Analyze only the center of the image
end


guidata(hObject, handles);

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in chooseStartTime.
function chooseStartTime_Callback(hObject, eventdata, handles)
% hObject    handle to chooseStartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
startTime = ExperimentStartTimeChooser(handles.imageAnalyzer.getExperimentStartTime()); % Let the user choose the starting time of the experiment
handles.imageAnalyzer.setExperimentStartTime(startTime); % Let the imageAnalyzer know that which experiment start time was defined
set(handles.startTimeText, 'String', ['Start time : ', datestr(datetime(handles.imageAnalyzer.getExperimentStartTime(), 'convertfrom', 'datenum'), 'dd.mm.yyyy HH:MM:ss')]);
guidata(hObject, handles);

% --- Executes when selected object is changed in mergePanel.
function mergePanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in mergePanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.NewValue
    case handles.merge
        handles.imageProcessingParameters.setMergeMode('on'); % Choose to further process the image
    case handles.noMerge
        handles.imageProcessingParameters.setMergeMode('off'); % Choose to skip the step of splitting and merging
end
guidata(hObject, handles);


% --- Executes when entered data in editable cell(s) in treatments_Table.
function treatments_Table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to treatments_Table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
handles.treatments_TableData = get(hObject, 'data'); % get the data from the table 
data = get(hObject,'Data'); % get the data cell array of the table
if sum(strcmp(fieldnames(eventdata), 'Indices')) % needed to make it work with both object (newer matlab versions) and struct (older ones)
    if isequal(eventdata.Indices(2), 4) % if the column of the edited cell is the delete column
        if eventdata.EditData && handles.dimensionality > 1 % if the checkbox was set to true
            data{eventdata.Indices(1),eventdata.Indices(2)} = true; % set the data value to true
            data(eventdata.Indices(1), :) = []; % delete the data from the row that was deleted
            handles.dimensionality = handles.dimensionality - 1; % reduce dimensionality
            handles.midasTableController.deleteTreatmentColumnByIndex(eventdata.Indices(1)); % delete the treatment from the MIDAS controller
        else % if the checkbox was set to false
            data{eventdata.Indices(1),eventdata.Indices(2)} = false; % set the data value to false
        end
    elseif isequal(eventdata.Indices(2), 5) % if the column of the edited cell is the auto concentration column
        data{eventdata.Indices(1),eventdata.Indices(2)} = false;
        set(hObject, 'Data', data);
        guidata(hObject, handles);
        drawnow;
        concentrations = autoSequenceGenerator();
        data{eventdata.Indices(1), 2} = concentrations;      
    end
end
set(hObject,'Data',data);
handles = changeDimensionality(handles, num2str(handles.dimensionality)); % update the dimensionality
handles = updateMidasHeaders(handles); % update MIDAS headers to new situation
handles.apareciumExperimentInput.updateTreatments(handles.treatments_TableData); % update the apareciumExperimentInput to new situation
guidata(hObject, handles);


% --- Executes on button press in startAnalysis.
function startAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to startAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% TODO - there is code duplication in this function, make separate functions where possible

switch handles.analysisMode % check if the user wants to analyze a completed measurement or observe an ongoing experiment
    case 'Completed' % the case of the already completed measurement
        if strcmp(handles.imageProcessingParameters.getAutoSaveMidas(), 'on') % check is the MIDAS file must be automatically saved
            answer = inputdlg('Choose name for autosave MIDAS file'); % let the user choose the name for the MIDAS file. "MD-" prefix is not required here, it is added automatically
            handles.imageAnalyzer.setMidasFileName(answer{1}); % let the imageAnalyzer know of the new name
        end
        handles.midasTableController.deleteChannelHeader(1);
        handles.imageAnalyzer.setHandles(handles); % give handles to imageAnalyzer so it could use it
        handles.imageAnalyzer.setImageImporter(handles.imageImporter); % give the image importer to the image analyzer
        handles.imageAnalyzer.setImageProcessingParameters(handles.imageProcessingParameters); % give the image processing parameters to the image analyzer
        handles.imageAnalyzer.setAnalysisFeedbackHandle(handles.timePassed); % give the feedback handle to the image analyzer
        handles.imageAnalyzer.setCameraAndLensParameters(handles.cameraAndLensParameters); % give the camera and lens parameters to the imageAnalyzer
        handles.imageAnalyzer.startAnalysis(); % start the analysis, this will take some time
        handles.experimentDataStructure = handles.imageAnalyzer.fullDataStructure; % get the resulting data structure
        handles = generateApareciumExperimentInput(handles, handles.experimentDataStructure); % generate new aparecium experiment input based on that
        handles = changeDimensionality(handles, num2str(handles.dimensionality)); % update the dimensionality 
        handles.apareciumExperimentInput.updateTreatments(handles.treatments_TableData); % update treatments
        rawData = sendDataToMidasTable(handles.experimentDataStructure, handles.dimensionality); % Send data to the MidasTableController
        updateMidasChannels(handles); % update the channel names
        handles.midasTableController.setData(rawData); % set data to the MIDAS table
        handles = updateMidasHeaders(handles);  % Update MIDAS headers
        if handles.plateSimulatorInterface.isPlateSimulatorInitialized % check if treatments were already defined before the analysis start
            treatmentStructure = handles.plateSimulatorInterface.getTreatmentStructure(); % get the treatment structure
            handles.midasTableController.updateTreatments(treatmentStructure); % update treatment values in the MIDAS file
        end
    case 'Observe' % the case of an ongoing experiment
        switch handles.observationStarted % check if the observation has already been started
            case 0 % the case when observation has not been started yet
                if strcmp(handles.imageProcessingParameters.getAutoSaveMidas(), 'on') %&& strcmp(handles.imageAnalyzer.getMidasFileName(), ''
                    answer = inputdlg('Choose name for autosave MIDAS file'); % let the user choose the name for the MIDAS file. "MD-" prefix is not required here, it is added automatically
                    handles.imageAnalyzer.setMidasFileName(answer{1}); % let the imageAnalyzer know of the new name
                end
                handles.imageAnalyzer.setHandles(handles);  % give handles to imageAnalyzer so it could use it
                handles.imageAnalyzer.setFigureHandles([handles.leftAxes, handles.rightAxes]); % give figure handles to the imageAnalyzer
                handles.imageAnalyzer.setImageProcessingParameters(handles.imageProcessingParameters); % give the image processing parameters to the image analyzer
                handles.imageAnalyzer.setAnalysisFeedbackHandle(handles.timePassed);  % give the feedback handle to the image analyzer
                set(handles.startAnalysis, 'String', 'Stop observation'); % change the string on the button so that user cleary sees that the observation has been started
                handles.observationStarted = 1; % Save that observation has been started 
                handles.imageAnalyzer.setCameraAndLensParameters(handles.cameraAndLensParameters); % give the camera and lens parameters to the imageAnalyzer
                handles.imageAnalyzer.setImageImporter(handles.imageImporter); % give the image importer to the image analyzer
                handles.imageAnalyzer.startObservationMode(); % Set the image analyzer to the observation mode 
                guidata(hObject, handles);
                while handles.observationStarted && handles.imageAnalyzer.imagesLeftToAnalyse > 0 % if analysis should be ongoing and there are still unanalyzed images
                    try
                        handles.imageImporter.getNewObservationSet(); % find out what image file were added
                        handles.imageAnalyzer.observeNewImages(); % analyze the new images
                        pause(1); % wait a little before trying to get new images, this frequency is frequent enough, Cytation5 microscopes usually takes one image every few seconds
                    catch
                        pause(1); % something went wrong or there were no new images, wait and attempt again
                    end
                    disp('Observing');% display that the observation is ongoing so the user knows
                end
                handles.imageAnalyzer.stopObservationMode(); % stop the observation mode if all the images have been analyzed
            case 1
                handles.observationStarted = 0; % just reset to the not started state
                guidata(hObject, handles);
        end
end
guidata(hObject, handles);

% --- Executes on button press in simPlateDone.
function simPlateDone_Callback(hObject, eventdata, handles)
% hObject    handle to simPlateDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% The user has finished with the PlateSimulator, clean it up and restore
%% to the original GUI
set(handles.simPlateHandle, 'visible', 'off');
set(handles.importImages, 'visible', 'on');
set(handles.analysisOptions, 'visible', 'on');
set(handles.analysisStatusPanel, 'visible', 'on');
set(handles.ExperimentConfigurationPanel, 'visible', 'on');
set(handles.uipanel35, 'visible', 'on');
%set(handles.simPlateDone, 'visible', 'off');
set(handles.figure1, 'Color', [225/255, 226/255, 251/255]);
treatmentStructure = handles.plateSimulatorInterface.getTreatmentStructure();
handles.midasTableController.updateTreatments(treatmentStructure);
guidata(handles.figure1, handles);


% --- Executes on button press in saveMIDASfile.
function saveMIDASfile_Callback(hObject, eventdata, handles)
% hObject    handle to saveMIDASfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputStruct.data = handles.midasTableController.getMidasTable(); % get the data from the MidasTableController
inputStruct.fileName = ''; 
saveMidasFile(inputStruct); % allow the user save the MIDAS file

% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.figure1, 'visible' ,'off'); % hide this GUI
handles.midasTableController.setEventDataEqualToData(); % required step for moving data
handles.midasTableController.activeUpdate = 'on'; % prepare the MIDAS table for MIDASTools
MIDASTools(handles.midasTableController, 'fromMidasTable'); % Send the MIDAS table controller to MIDASTools



function tileDim_Callback(hObject, eventdata, handles)
% hObject    handle to tileDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tileDim as text
%        str2double(get(hObject,'String')) returns contents of tileDim as a double

handles.imageProcessingParameters.setTileDim(str2double(get(hObject,'String'))); % change the tileDim parameter
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function tileDim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tileDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lambda_Callback(hObject, eventdata, handles)
% hObject    handle to lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lambda as text
%        str2double(get(hObject,'String')) returns contents of lambda as a double
handles.imageProcessingParameters.setLambda(str2double(get(hObject,'String'))); % change the lambda parameter
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function lambda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function preDilateCutoff_Callback(hObject, eventdata, handles)
% hObject    handle to preDilateCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of preDilateCutoff as text
%        str2double(get(hObject,'String')) returns contents of preDilateCutoff as a double
handles.imageProcessingParameters.setPreDilateCutoff(str2double(get(hObject,'String'))); % change the minSizeMSER parameter
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function preDilateCutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to preDilateCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function postDilateCutoff_Callback(hObject, eventdata, handles)
% hObject    handle to postDilateCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of postDilateCutoff as text
%        str2double(get(hObject,'String')) returns contents of postDilateCutoff as a double
handles.imageProcessingParameters.setPostDilateCutoff(str2double(get(hObject,'String'))); % change the maxSizeMSER parameter
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function postDilateCutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to postDilateCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function extraEdgeThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to extraEdgeThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of extraEdgeThreshold as text
%        str2double(get(hObject,'String')) returns contents of extraEdgeThreshold as a double
handles.imageProcessingParameters.setExtraEdgeThreshold(str2double(get(hObject,'String'))); % change the maxEcc parameter 
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function extraEdgeThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to extraEdgeThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minSizeSplit_Callback(hObject, eventdata, handles)
% hObject    handle to minSizeSplit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minSizeSplit as text
%        str2double(get(hObject,'String')) returns contents of minSizeSplit as a double
handles.imageProcessingParameters.setMinSizeSplit(str2double(get(hObject,'String'))); % change the minSizeSplit parameter  
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function minSizeSplit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minSizeSplit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxSizeSplit_Callback(hObject, eventdata, handles)
% hObject    handle to maxSizeSplit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxSizeSplit as text
%        str2double(get(hObject,'String')) returns contents of maxSizeSplit as a double
handles.imageProcessingParameters.setMaxSizeSplit(str2double(get(hObject,'String'))); % change the maxSizeSplit parameter  
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function maxSizeSplit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxSizeSplit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxVariation_Callback(hObject, eventdata, handles)
% hObject    handle to maxVariation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxVariation as text
%        str2double(get(hObject,'String')) returns contents of maxVariation as a double
handles.imageProcessingParameters.setMaxVariation(str2double(get(hObject,'String'))); % change the maxVariation parameter 
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function maxVariation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxVariation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in midasGenerationOptions.
function midasGenerationOptions_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in midasGenerationOptions 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.NewValue
    case handles.separateMidasFiles
        handles.imageProcessingParameters.setMidasFileSaveFormat('separate'); % Create separate MIDAS file for each folder
    case handles.completeMidasFile
        handles.imageProcessingParameters.setMidasFileSaveFormat('complete'); % Create one complete MIDAS file for all selected folders
end



function timeShift_Callback(hObject, eventdata, handles)
% hObject    handle to timeShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeShift as text
%        str2double(get(hObject,'String')) returns contents of timeShift as a double
handles.imageAnalyzer.setTimeShift(str2double(get(hObject,'String'))); % change the timeShift
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function timeShift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in chooseReference.
function chooseReference_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in chooseReference 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.NewValue 
    case handles.chooseTime % in case the user wants to manually choose the experiment start time
        %% Enable choosing start time and disable time shift
        set(handles.chooseStartTime, 'enable', 'on');
        set(handles.timeShift, 'enable', 'off');
        handles.imageAnalyzer.setReferenceTimeMode('Choose time');
        try
            set(handles.startTimeText, 'String', ['Start time : ', datestr(datetime(handles.imageAnalyzer.getExperimentStartTime(), 'convertfrom', 'datenum'), 'dd.mm.yyyy HH:MM:ss')]);
        catch
            set(handles.startTimeText, 'String', 'Start time : Not set');
            
        end
    case handles.firstPoint % in case the user wants to automatically set the experiment start time equal to the time the first image was taken
        %% Enable time shift and disable choosing start time
        set(handles.chooseStartTime, 'enable', 'off');
        set(handles.timeShift, 'enable', 'on');
        
        set(handles.startTimeText, 'String', 'Start time : First timepoint');

        handles.imageAnalyzer.setReferenceTimeMode('First point');
end


% --- Executes when selected object is changed in timingProperties.
function timingProperties_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in timingProperties 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.NewValue
    case handles.chooseTimeManually % user chooses to add time values later manually to the MIDAS file 
        %% Disable all time choosing options
        set(handles.chooseStartTime, 'enable', 'off');
        set(handles.timeShift, 'enable', 'off');
        set(handles.chooseTime, 'enable', 'off');
        set(handles.firstPoint, 'enable', 'off');
        handles.imageAnalyzer.setMeasurementTimeMode('Manual');
    case handles.averageOfCycle % user chooses to use one time value for each measurement that was performed during the same cycle
        %% disable choosing start time and enable some other options
        set(handles.firstPoint, 'enable', 'on');
        set(handles.chooseStartTime, 'enable', 'off');
        set(handles.chooseTime, 'enable', 'on');
        set(handles.timeShift, 'enable', 'on');
        set(handles.firstPoint, 'value', 1);
        handles.imageAnalyzer.setMeasurementTimeMode('Cycle average');
        handles.imageAnalyzer.setReferenceTimeMode('First point');
    case handles.averageOfWell % user chooses to use one time value for each well
        %% disable choosing start time and enable some other options
        set(handles.firstPoint, 'enable', 'on');
        set(handles.timeShift, 'enable', 'on');
        set(handles.chooseStartTime, 'enable', 'off');
        set(handles.chooseTime, 'enable', 'on');
        set(handles.firstPoint, 'value', 1);
        handles.imageAnalyzer.setMeasurementTimeMode('Well average');
        handles.imageAnalyzer.setReferenceTimeMode('First point');
end


% --- Executes during object creation, after setting all properties.
function leftAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to leftAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
cla(hObject); % make sure that the axis is empty
guidata(hObject, handles);
% Hint: place code in OpeningFcn to populate leftAxes


% --- Executes during object creation, after setting all properties.
function rightAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rightAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
cla(hObject)  % make sure that the axis is empty
guidata(hObject, handles)
% Hint: place code in OpeningFcn to populate rightAxes


% --- Executes when selected object is changed in uipanel17.
function uipanel17_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel17 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

% change the button String based on which analysis mode is chosen
switch eventdata.NewValue 
    case handles.observe
        handles.analysisMode = 'Observe';
        set(handles.startAnalysis, 'String', 'Start observation');
    case handles.completedMeasurement
        handles.analysisMode = 'Completed';   
        set(handles.startAnalysis, 'String', 'Start analysis');
end
guidata(hObject, handles);
        


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% this function deals with importing binary images. Sti

handles.imageImporter = ImageImporter(); % Create a new ImageImporter obejct
handles.imageImporter.setDetectionChannelRegex(get(handles.detectionChannelRegex, 'String'));
handles.imageImporter.setQuantificationChannelRegex(get(handles.quantificationChannelRegex, 'String'));
handles.imageImporter.analyzeQuality = 1;
lowerStackBound = str2num(get(handles.lowerStackBound,'String'));
handles.imageImporter.setLowerBound(lowerStackBound);
higherStackBound = str2num(get(handles.higherStackBound,'String'));
handles.imageImporter.setHigherBound(higherStackBound);
fileChooser = FileChooser();
startingPath = fileChooser.chooseMembraneToolsFolder(); % get the preferred starting folder
handles.imageImporter.userChooseImageFolders(startingPath); % note that user must still choose the regular images, timing is still read from there but binary image is taken from elsewhere


handles.experimentDataStructure = handles.imageImporter.experimentDataStructure; 
handles.imageProcessingParameters.setFromBinaryMode(); % set the image analysis parameters to accordance with processing binary files
set(handles.autoSaveBinaryImage, 'value', 0); % Don´t save binary files, they must already be there



%% disable most of the panels that change parameters which change the way
%% the bright-field images are analyzer but not how the binary images are
%% analyzed
set(handles.autoSaveBinaryImage, 'Enable', 'off');
handles.imageProcessingParameters.setAutoSaveBinaryFiles('off');

%set(handles.observe, 'Enable', 'off');
%set(handles.merge, 'Enable', 'off');
%set(handles.noMerge, 'Enable', 'off');

%set(handles.tileDim, 'Enable', 'off');
%set(handles.lambda, 'Enable', 'off');
%set(handles.preDilateCutoff, 'Enable', 'off');
%set(handles.postDilateCutoff, 'Enable', 'off');
%set(handles.extraEdgeThreshold, 'Enable', 'off');
%set(handles.minSizeSplit, 'Enable', 'off');
%set(handles.maxSizeSplit, 'Enable', 'off');
%set(handles.maxVariation, 'Enable', 'off');

set(handles.completedMeasurement, 'Value', 1);

handles.analysisMode = 'Completed';   
set(handles.startAnalysis, 'String', 'Start analysis');
handles = generateApareciumExperimentInput(handles, handles.experimentDataStructure);
guidata(hObject, handles);
% --------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
openApareciumHelp(); % open the help


% --- Executes during object creation, after setting all properties.
function uipanel17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function pixelLength_Callback(hObject, eventdata, handles)
% hObject    handle to pixelLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pixelLength as text
%        str2double(get(hObject,'String')) returns contents of pixelLength as a double

handles.cameraAndLensParameters.pixelSize = str2double(get(hObject,'String')); %Change the side length of the camera pixel (um/px)
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function pixelLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixelLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function magnification_Callback(hObject, eventdata, handles)
% hObject    handle to magnification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of magnification as text
%        str2double(get(hObject,'String')) returns contents of magnification as a double
handles.cameraAndLensParameters.magnification = str2double(get(hObject,'String')); % Change the magnification of the lens that was used
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function magnification_CreateFcn(hObject, eventdata, handles)
% hObject    handle to magnification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.midasTableController.setEventDataEqualToData(); % prepare midasTableController for moving to export wizard
ExportTools(handles.midasTableController); % move the object to export wizard


% --- Executes during object creation, after setting all properties.
function useParallelComputing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to useParallelComputing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function treatments_Table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to treatments_Table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Data', {'', '', '', 'false', 'false'});
guidata(hObject, handles);


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
contents = get(hObject,'String');
thresholdFunctionName = contents{get(hObject,'Value')};
functionCallbackHandle = eval(['@',thresholdFunctionName])
handles.imageAnalyzer.thresholdFunctionHandle = functionCallbackHandle;
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
functionName = inputdlg('Enter function name');
thresholdFunctionNames = ['None', ICSEThresholdManager.addNewThreshold(functionName{1})];
set(handles.popupmenu1, 'String', thresholdFunctionNames);
guidata(hObject, handles);



function lowerThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to lowerThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lowerThreshold as text
%        str2double(get(hObject,'String')) returns contents of lowerThreshold as a double
handles.imageProcessingParameters.setLowerThreshold(str2double(get(hObject,'String'))); % change the tileDim parameter
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function lowerThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowerThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function upperThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to upperThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of upperThreshold as text
%        str2double(get(hObject,'String')) returns contents of upperThreshold as a double
handles.imageProcessingParameters.setUpperThreshold(str2double(get(hObject,'String'))); % change the tileDim parameter
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function upperThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to upperThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApareciumCommonImporterFunctions.figure1_ResizeFcn(hObject, eventdata, handles);


% --- Executes on button press in saveQualityMasks.
function saveQualityMasks_Callback(hObject, eventdata, handles)
% hObject    handle to saveQualityMasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveQualityMasks
switch get(hObject,'Value')
    case 0
        handles.imageProcessingParameters.setAutoSaveMasks('off'); % Do not automatically save binary images
    case 1
        handles.imageProcessingParameters.setAutoSaveMasks('on'); % Save binary images automatically 
end


% --- Executes on button press in fromImageTickBox.
function fromImageTickBox_Callback(hObject, eventdata, handles)
% hObject    handle to fromImageTickBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fromImageTickBox
handles.cameraAndLensParameters.fromImage = get(handles.fromImageTickBox, 'Value');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function fromImageTickBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fromImageTickBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes on selection change in detectionModel.
function detectionModel_Callback(hObject, eventdata, handles)
% hObject    handle to detectionModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns detectionModel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from detectionModel
contents = cellstr(get(hObject,'String'));
if strcmp(contents{get(hObject,'Value')}, 'Sobel')
    set(handles.ilastikParametersPanel, 'Visible', 'off')
    set(handles.analysisParameters, 'Visible', 'on')
    set(handles.kerasParametersPanel, 'Visible', 'off')
    handles.imageProcessingParameters.detectionModel = handles.imageProcessingParameters.SobelModel;
elseif strcmp(contents{get(hObject,'Value')}, 'Ilastik')
    set(handles.ilastikParametersPanel, 'Visible', 'on')
    set(handles.analysisParameters, 'Visible', 'off')
    set(handles.kerasParametersPanel, 'Visible', 'off')
    handles.imageProcessingParameters.detectionModel = handles.imageProcessingParameters.IlastikModel;
elseif strcmp(contents{get(hObject,'Value')}, 'Keras')
    set(handles.ilastikParametersPanel, 'Visible', 'off')
    set(handles.analysisParameters, 'Visible', 'off')
    set(handles.kerasParametersPanel, 'Visible', 'on')
    handles.imageProcessingParameters.detectionModel = handles.imageProcessingParameters.KerasModel;
end
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function detectionModel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to detectionModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ilastikModelPath_Callback(hObject, eventdata, handles)
% hObject    handle to ilastikModelPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ilastikModelPath as text
%        str2double(get(hObject,'String')) returns contents of ilastikModelPath as a double
handles.imageProcessingParameters.ilastikModelPath = get(hObject,'String');
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function ilastikModelPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ilastikModelPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chooseIlastikFile.
function chooseIlastikFile_Callback(hObject, eventdata, handles)
% hObject    handle to chooseIlastikFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileChooser = FileChooser();
fullPath = fileChooser.chooseIlastikModelFile();
handles.imageProcessingParameters.ilastikModelPath = fullPath;
set(handles.ilastikModelPath, 'String', fullPath);
guidata(hObject, handles)


function ilastikMembraneLabelIndex_Callback(hObject, eventdata, handles)
% hObject    handle to ilastikMembraneLabelIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ilastikMembraneLabelIndex as text
%        str2double(get(hObject,'String')) returns contents of ilastikMembraneLabelIndex as a double
handles.imageProcessingParameters.membraneLabelIndex = str2double(get(hObject,'String'));
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function ilastikMembraneLabelIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ilastikMembraneLabelIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in useMorphologicalCleaning.
function useMorphologicalCleaning_Callback(hObject, eventdata, handles)
% hObject    handle to useMorphologicalCleaning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useMorphologicalCleaning
handles.imageProcessingParameters.useMorphologicalOperations = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in ignoreMorphologicalCleaning.
function ignoreMorphologicalCleaning_Callback(hObject, eventdata, handles)
% hObject    handle to ignoreMorphologicalCleaning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ignoreMorphologicalCleaning
handles.imageProcessingParameters.useMorphologicalOperations = ~get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in maxZProjection.
function maxZProjection_Callback(hObject, eventdata, handles)
% hObject    handle to maxZProjection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of maxZProjection
handles.imageProcessingParameters.focusOrMaxProjection = 'max projection';
guidata(hObject, handles);


% --- Executes on button press in focus.
function focus_Callback(hObject, eventdata, handles)
% hObject    handle to focus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of focus
handles.imageProcessingParameters.focusOrMaxProjection = 'focus';
guidata(hObject, handles);


% --------------------------------------------------------------------
function characteristicsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to characteristicsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function characteristicDescription_Callback(hObject, eventdata, handles)
% hObject    handle to characteristicDescription (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
characteristics = get(handles.listbox2, 'String');
selectedParameter = characteristics{get(handles.listbox2, 'Value')};
switch selectedParameter
    case 'averageMembraneIntensity'
        helpdlg('The average pixel intensity of the region of interest, usually the cell membrane.', [selectedParameter, ' description']);
    case 'averageSecondaryImageIntensity'
        helpdlg('The average intensity of the secondary image which was not used for detection.', [selectedParameter, ' description']);
    case 'averageNonMembraneIntensity'
        helpdlg('The average intensity of all other pixels not in the ROI, usually corresponding to image background.', [selectedParameter, ' description']);        
    case 'firstNonMembraneQuadrileIntensity'
        helpdlg('The average intensity of the lowest quadrile of all other pixels not in the ROI, usually corresponding to image background.', [selectedParameter, ' description']);               
    case 'averageUnmaskedMembraneIntensity'
        helpdlg('The average pixel intensity of the region of interest, usually the cell membrane. This value is calculated without using the quality mask.', [selectedParameter, ' description']);        
    case 'averageUnmaskedNonMembraneIntensity'
        helpdlg('The average intensity of all other pixels not in the ROI, usually corresponding to image background. This value is calculated without using the quality mask.', [selectedParameter, ' description']);             
    case 'firstUnmaskedNonMembraneQuadrileIntensity'
        helpdlg('The average intensity of the lowest quadrile of all other pixels not in the ROI, usually corresponding to image background. This value is calculated without using the quality mask.', [selectedParameter, ' description']);                      
    case 'averageUnmaskedSecondaryImageIntensity'
        helpdlg('The average intensity of the secondary image which was not used for detection. This value is calculated without using the quality mask.', [selectedParameter, ' description']);  
    case 'pixelCount'
        helpdlg('Pixel count in the ROI, usually the membrane.', [selectedParameter, ' description']);        
    case 'intensitySTD'
        helpdlg('Standard deviation of the pixel intensities in the ROI, usually the membrane.', [selectedParameter, ' description']);
end


% --- Executes on button press in saveQualityMaskNow.
function saveQualityMaskNow_Callback(hObject, eventdata, handles)
% hObject    handle to saveQualityMaskNow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
maskdir = uigetdir([handles.imageImporter.mainDirectory, '\','Mask'], 'Select directory for saving the masks');
for folder = 1 : handles.imageImporter.getNumberOfUsedDirectories()
    mkdir([maskdir,'\' , handles.imageImporter.getUsedDirectoryWithIndex(folder), '\']);
    for well = 1 : numel(handles.imageImporter.masks{folder}) 
        for imageInWell = 1 : numel(handles.imageImporter.masks{folder}{well})
            if ~isempty(handles.imageImporter.maskNameArray{folder}{well}{imageInWell})
                imwrite(handles.imageImporter.masks{folder}{well}{imageInWell}, [maskdir, '\', handles.imageImporter.getUsedDirectoryWithIndex(folder), '\', handles.imageImporter.maskNameArray{folder}{well}{imageInWell}], 'tif')
        
            end
        end
    end
end

% --- Executes on button press in saveBrightFieldFocusNow.
function saveBrightFieldFocusNow_Callback(hObject, eventdata, handles)
% hObject    handle to saveBrightFieldFocusNow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName, filePath] = uiputfile('*.mat', 'Save .mat file with bright-field focus image names');
fileNames = handles.imageImporter.nameArray;
save([filePath, fileName], 'fileNames');



% --- Executes on button press in saveFluorescenceFocusNow.
function saveFluorescenceFocusNow_Callback(hObject, eventdata, handles)
% hObject    handle to saveFluorescenceFocusNow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName, filePath] = uiputfile('*.mat', 'Save .mat file with fluorescence focus image names');
fileNames = handles.imageImporter.secondaryNameArray;
save([filePath, fileName], 'fileNames');



function horizontalShift_Callback(hObject, eventdata, handles)
% hObject    handle to horizontalShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of horizontalShift as text
%        str2double(get(hObject,'String')) returns contents of horizontalShift as a double
handles.imageProcessingParameters.setPixelShiftHorizontal(str2double(get(hObject,'String')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function horizontalShift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to horizontalShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function verticalShift_Callback(hObject, eventdata, handles)
% hObject    handle to verticalShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of verticalShift as text
%        str2double(get(hObject,'String')) returns contents of verticalShift as a double
handles.imageProcessingParameters.setPixelShiftVertical(str2double(get(hObject,'String')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function verticalShift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to verticalShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in imageAlignment.
function imageAlignment_Callback(hObject, eventdata, handles)
% hObject    handle to imageAlignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
output = ImageAligner(handles.imageImporter);
set(handles.horizontalShift, 'String', num2str(output(1)));
set(handles.verticalShift, 'String', num2str(output(2)));
handles.imageProcessingParameters.setPixelShiftHorizontal(output(1));
handles.imageProcessingParameters.setPixelShiftHorizontal(output(2));




function detectionChannelRegex_Callback(hObject, eventdata, handles)
% hObject    handle to detectionChannelRegex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of detectionChannelRegex as text
%        str2double(get(hObject,'String')) returns contents of detectionChannelRegex as a double
regexString = get(hObject,'String');
handles.imageProcessingParameters.setDetectionChannelRegex(regexString);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function detectionChannelRegex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to detectionChannelRegex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function quantificationChannelRegex_Callback(hObject, eventdata, handles)
% hObject    handle to quantificationChannelRegex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quantificationChannelRegex as text
%        str2double(get(hObject,'String')) returns contents of quantificationChannelRegex as a double
regexString = get(hObject,'String');
handles.imageProcessingParameters.setQuantificationChannelRegex(regexString);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function quantificationChannelRegex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quantificationChannelRegex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton30.
function pushbutton30_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton31.
function pushbutton31_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton32.
function pushbutton32_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in expectZStack.
function expectZStack_Callback(hObject, eventdata, handles)
% hObject    handle to expectZStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of expectZStack
expectStack = get(hObject,'Value');
handles.imageProcessingParameters.setExpectZstack(expectStack);
guidata(hObject, handles);



function lowerStackBound_Callback(hObject, eventdata, handles)
% hObject    handle to lowerStackBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lowerStackBound as text
%        str2double(get(hObject,'String')) returns contents of lowerStackBound as a double


% --- Executes during object creation, after setting all properties.
function lowerStackBound_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowerStackBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function higherStackBound_Callback(hObject, eventdata, handles)
% hObject    handle to higherStackBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of higherStackBound as text
%        str2double(get(hObject,'String')) returns contents of higherStackBound as a double


% --- Executes during object creation, after setting all properties.
function higherStackBound_CreateFcn(hObject, eventdata, handles)
% hObject    handle to higherStackBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in useSlopes.
function useSlopes_Callback(hObject, eventdata, handles)
% hObject    handle to useSlopes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useSlopes
handles.imageProcessingParameters.setDetectionFocusOrSlopes('Slopes');
guidata(hObject, handles);


% --- Executes on button press in useFocusImage.
function useFocusImage_Callback(hObject, eventdata, handles)
% hObject    handle to useFocusImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useFocusImage
handles.imageProcessingParameters.setDetectionFocusOrSlopes('Focus');
guidata(hObject, handles);


% --- Executes on button press in pushbutton34.
function pushbutton34_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
results = handles.imageAnalyzer.results;
path = fullfile(handles.imageImporter.mainDirectory, handles.imageImporter.usedDirectories{1});
generateObjectWiseExcel(results, path);




function kerasModelPath_Callback(hObject, eventdata, handles)
% hObject    handle to kerasModelPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kerasModelPath as text
%        str2double(get(hObject,'String')) returns contents of kerasModelPath as a double
handles.imageProcessingParameters.kerasModelPath = get(hObject,'String');
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function kerasModelPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kerasModelPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton35.
function pushbutton35_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileChooser = FileChooser();
fullPath = fileChooser.chooseKerasModelFile();
handles.imageProcessingParameters.kerasModelPath = fullPath;
set(handles.kerasModelPath, 'String', fullPath);
guidata(hObject, handles)


function edit31_Callback(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit31 as text
%        str2double(get(hObject,'String')) returns contents of edit31 as a double


% --- Executes during object creation, after setting all properties.
function edit31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in detectionChannelBGOptions.
function detectionChannelBGOptions_Callback(hObject, eventdata, handles)
% hObject    handle to detectionChannelBGOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.imageProcessingParameters.membraneToolsBackgroundCorrection = DetectionChannelBackgroundOptionsGUI(handles.imageProcessingParameters.membraneToolsBackgroundCorrection);
guidata(hObject, handles);

% --- Executes on button press in quantificationChannelBGOptions.
function quantificationChannelBGOptions_Callback(hObject, eventdata, handles)
% hObject    handle to quantificationChannelBGOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.imageProcessingParameters.membraneToolsBackgroundCorrection = DetectionChannelBackgroundOptionsGUI(handles.imageProcessingParameters.membraneToolsBackgroundCorrection);
guidata(hObject, handles);


% --- Executes on button press in chooseTime.
function chooseTime_Callback(hObject, eventdata, handles)
% hObject    handle to chooseTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chooseTime


% --- Executes during object creation, after setting all properties.
function uibuttongroup3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when selected cell(s) is changed in treatments_Table.
function treatments_Table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to treatments_Table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(eventdata.Indices)
    jUIScrollPane = findjobj(hObject);
    jUITable = jUIScrollPane.getViewport.getView;
    jUITable.changeSelection(eventdata.Indices(1)-1, eventdata.Indices(2)-1, false, false);
    %jUITable.getComponent(1).setCaretPosition(1);
    guidata(hObject, handles);
    try
        jUITable = jUIScrollPane.getViewport.getView;
        jUITable.getComponent(1).setSelectionStart(0);
        jUITable.getComponent(1).setSelectionEnd(2);
        handles.TextFieldCellEditor = jUITable.getComponent(1);
    catch      
        handles.TextFieldCellEditor.setSelectionStart(0)
        handles.TextFieldCellEditor.setSelectionEnd(2)
    end
    handles.TextFieldCellEditor.setSelectionStart(0)
    handles.TextFieldCellEditor.setSelectionEnd(2)

end

eventData.twice = 1;
guidata(hObject, handles);


% --- Executes when selected object is changed in uibuttongroup5.
function uibuttongroup5_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup5 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes when selected object is changed in uibuttongroup2.
function uibuttongroup2_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup2 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SubtractQuantificationChannelBackround.
function SubtractQuantificationChannelBackround_Callback(hObject, eventdata, handles)
% hObject    handle to SubtractQuantificationChannelBackround (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SubtractQuantificationChannelBackround
switch get(hObject,'Value')
    case 1
        handles.imageProcessingParameters.setSubtractBackground(true); % Subtract quantification channel background
    case 0
        handles.imageProcessingParameters.setAutoSaveMidas(false); % Do not subtract quantification channel background
end



function inputNormalizationMax_Callback(hObject, eventdata, handles)
% hObject    handle to inputNormalizationMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputNormalizationMax as text
%        str2double(get(hObject,'String')) returns contents of inputNormalizationMax as a double
handles.imageProcessingParameters.setNormalizationMax(str2double(get(hObject,'String')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function inputNormalizationMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputNormalizationMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function inputNormalizationMin_Callback(hObject, eventdata, handles)
% hObject    handle to inputNormalizationMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputNormalizationMin as text
%        str2double(get(hObject,'String')) returns contents of inputNormalizationMin as a double
handles.imageProcessingParameters.setNormalizationMin(str2double(get(hObject,'String')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function inputNormalizationMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputNormalizationMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function binarisationThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to binarisationThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binarisationThreshold as text
%        str2double(get(hObject,'String')) returns contents of binarisationThreshold as a double
handles.imageProcessingParameters.setBinarisationThreshold(str2double(get(hObject,'String')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function binarisationThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binarisationThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tileImage.
function tileImage_Callback(hObject, eventdata, handles)
% hObject    handle to tileImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value')
    handles.imageProcessingParameters.setTileOrResizePreprocessing('Tile');
end
guidata(hObject, handles);


% --- Executes on button press in autoSaveProbabilityMap.
function autoSaveProbabilityMap_Callback(hObject, eventdata, handles)
% hObject    handle to autoSaveProbabilityMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoSaveProbabilityMap
if get(hObject,'Value')
    handles.imageProcessingParameters.setAutoSaveProbabilityMap('on');
else
    handles.imageProcessingParameters.setAutoSaveProbabilityMap('off');
end
guidata(hObject, handles);

% --- Executes on button press in resizeImage.
function resizeImage_Callback(hObject, eventdata, handles)
% hObject    handle to resizeImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of resizeImage

if get(hObject,'Value')
    handles.imageProcessingParameters.setTileOrResizePreprocessing('Resize');
end
guidata(hObject, handles);


% --- Executes on button press in firstPoint.
function firstPoint_Callback(hObject, eventdata, handles)
% hObject    handle to firstPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of firstPoint
