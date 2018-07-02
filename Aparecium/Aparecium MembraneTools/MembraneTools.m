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

% Last Modified by GUIDE v2.5 01-Jan-2010 11:16:07

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
handles.imageImporter = ImageImporter(); % Create a new object that can import the images correctly
handles.imageProcessingParameters = ImageProcessingParameters(); % Create a new object that holds parameters of image analysis
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
handles.simPlateHandle = []; % a handle to the PlateSimulator
handles.analysisMode = 'Completed'; % A standard parameter
handles.observationStarted = 0; % No observation is started when the program is launched

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
handles.imageImporter = ImageImporter(); % Create a new object that can import the images correctly
handles.imageImporter.analyzeQuality = 1;
handles.imageImporter.userChooseImageFolders(); % Ask the user to choose the folder where the folders are that contain images
handles.experimentDataStructure = handles.imageImporter.experimentDataStructure; % Get information about which wells were used
handles = generateApareciumExperimentInput(handles, handles.experimentDataStructure); % Generate the ApareciumExperimentInput object based the information from images 
handles.imageProcessingParameters.setFullImageMode();
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
%set(handles.simPlateDone, 'visible', 'on'); % Make the done button visible so the user could finish using PlateSimulator
set(handles.figure1, 'Color', 'white'); % Change the background color
doneCallbackHandle = @simPlateDone_Callback;
doneHandler(handles.plateSimulatorInterface.PlateSimulator.done, handles, doneCallbackHandle);

% --- Executes on button press in loadConfigurationFile.
function loadConfigurationFile_Callback(hObject, eventdata, handles)
% hObject    handle to loadConfigurationFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileChooser = FileChooser(); % Create a new fileChooser object
[fullFilePath, fileName] = fileChooser.chooseConfigurationFile(); % Let the user choose a configuration file
handles = changeConfiguration(fullFilePath, handles);% Change the configuration to the one defined in the file
guidata(hObject, handles);
treatments_Table_CellEditCallback(handles.treatments_Table, eventdata, handles);% Call the cellEditCallback to make the changes visible
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
startTime = ExperimentStartTimeChooser(); % Let the user choose the starting time of the experiment
handles.imageAnalyzer.setExperimentStartTime(startTime); % Let the imageAnalyzer know that which experiment start time was defined
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
        handles.imageAnalyzer.setFigureHandles([handles.leftAxes, handles.rightAxes]); % give figure handles to the imageAnalyzer
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
switch eventdata.NewValue; 
    case handles.chooseTime % in case the user wants to manually choose the experiment start time
        %% Enable choosing start time and disable time shift
        set(handles.chooseStartTime, 'enable', 'on');
        set(handles.timeShift, 'enable', 'off');
        handles.imageAnalyzer.setReferenceTimeMode('Choose time');
    case handles.firstPoint % in case the user wants to automatically set the experiment start time equal to the time the first image was taken
        %% Enable time shift and disable choosing start time
        set(handles.chooseStartTime, 'enable', 'off');
        set(handles.timeShift, 'enable', 'on');
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
handles.imageImporter.analyzeQuality = 1;
handles.imageImporter.userChooseImageFolders(); % note that user must still choose the regular images, timing is still read from there but binary image is taken from elsewhere
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
