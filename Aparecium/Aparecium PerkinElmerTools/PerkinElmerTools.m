function varargout = PerkinElmerTools(varargin)
% PERKINELMERTOOLS M-file for PerkinElmerTools.fig
%      PERKINELMERTOOLS, by itself, creates a new PERKINELMERTOOLS or raises the existing
%      singleton*.
%
%      H = PERKINELMERTOOLS returns the handle to a new PERKINELMERTOOLS or the handle to
%      the existing singleton*.
%
%      PERKINELMERTOOLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PERKINELMERTOOLS.M with the given input arguments.
%
%      PERKINELMERTOOLS('Property','Value',...) creates a new PERKINELMERTOOLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PerkinElmerTools_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PerkinElmerTools_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PerkinElmerTools

% Last Modified by GUIDE v2.5 10-Aug-2017 17:19:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PerkinElmerTools_OpeningFcn, ...
                   'gui_OutputFcn',  @PerkinElmerTools_OutputFcn, ...
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


% --- Executes just before PerkinElmerTools is made visible.
function PerkinElmerTools_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PerkinElmerTools (see VARARGIN)

% Choose default command line output for PerkinElmerTools
addApareciumToPath();
handles.output = hObject;
handles.perkinElmerReader = PerkinElmerReader();
handles.experimentDataStructure = [];
handles.dimensionality = 1;
handles.fastKinetics = [];
handles.outputChannelNames = [];
handles.treatments_TableData = {'', '', ''}; 
handles.MIDAS_tableData = [];
handles.MIDAS_tableData = {};
handles.midasTableController;
handles.apareciumExperimentInput = ApareciumExperimentInput();
handles.plateSimulatorInterface = PlateSimulatorInterface();
handles.simPlateHandle = [];
handles.fileName = [];
handles = ExperimentConfigurationPanelFunc(handles);
handles = MIDASOptionsPanelFunc(handles);
guidata(hObject, handles)
initializeChannelsTable(handles);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PerkinElmerTools wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PerkinElmerTools_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
openApareciumHelp();

% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_ASCII_Callback(hObject, eventdata, handles)
% hObject    handle to menu_ASCII (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileChooser = FileChooser();
[fullFilePath, fileName] = fileChooser.userChoosePerkinElmerExcel();
handles.perkinElmerReader.readFile(fullFilePath);
handles.fileName = regexprep(fileName, '.txt', '');
set(handles.MIDAS_table,'visible', 'on');
set(handles.MIDASInformationText,'String', ['PerkinElmer file ', fileName, ' loaded']);
handles.experimentDataStructure = handles.perkinElmerReader.experimentDataStructure;
rawData = sendDataToMidasTable(handles.perkinElmerReader.experimentDataStructure, handles.dimensionality);
handles = generateApareciumExperimentInput(handles, handles.perkinElmerReader.experimentDataStructure);
setChannels(handles);
handles.midasTableController.setData(rawData);
successBox('PerkinElmer .xls file successfully loaded', 'Success');
guidata(hObject, handles);
% --------------------------------------------------------------------

function ChooseDimensionality_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseDimensionality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ChooseDimensionality as text
%        str2double(get(hObject,'String')) returns contents of ChooseDimensionality as a double
dimensionality = get(hObject,'String');
handles = changeDimensionality(handles, dimensionality);
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
guidata(hObject, handles);


% --- Executes on button press in OpenPlateSimulator.
function OpenPlateSimulator_Callback(hObject, eventdata, handles)
% hObject    handle to OpenPlateSimulator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.plateSimulatorInterface.addExperiment(handles.apareciumExperimentInput);
handles.simPlateHandle = handles.plateSimulatorInterface.generatePlateSimulator(handles);
handles = setUIModeToPlateSim(handles);
guidata(hObject, handles);

function handles = setUIModeToPlateSim(handles)

set(handles.loadFilePanel, 'visible', 'off');
set(handles.MIDASPreviewPanel, 'visible', 'off');
set(handles.ExperimentConfigurationPanel, 'visible', 'off');
%set(handles.simPlateDone, 'visible', 'on');
set(handles.figure1, 'Color', 'white');
doneCallbackHandle = @simPlateDone_Callback;
doneHandler(handles.plateSimulatorInterface.PlateSimulator.done, handles, doneCallbackHandle);


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function TreatmentPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TreatmentPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called       
    

% --- Executes on button press in LoadConfigurationFile.
function LoadConfigurationFile_Callback(hObject, eventdata, handles)
% hObject    handle to LoadConfigurationFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileChooser = FileChooser();
[fullFilePath, fileName] = fileChooser.chooseConfigurationFile();
handles = changeConfiguration(fullFilePath, handles);
guidata(hObject, handles);
treatments_Table_CellEditCallback(handles.treatments_Table, eventdata, handles);
successBox('Configuration file successfully loaded', 'Success');
guidata(hObject, handles);

% --- Executes on button press in SaveConfigurationFile.
function SaveConfigurationFile_Callback(hObject, eventdata, handles)
% hObject    handle to SaveConfigurationFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveConfiguration(handles);
successBox('Configuration file saved', 'Success');

% --- Executes on button press in SaveMIDASFile.
function SaveMIDASFile_Callback(hObject, eventdata, handles)
% hObject    handle to SaveMIDASFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SaveMIDASFile
if(handles.midasTableController.channelNamesAreValid())
    set(hObject, 'enable', 'off');
    set(hObject, 'String', 'Please wait');
    drawnow;
    pause(0.05);
    inputStruct.data = handles.midasTableController.getMidasTable();
    inputStruct.fileName = handles.fileName;
    result = saveMidasFile(inputStruct);
    if(result)
        successBox('MIDAS file saved', 'Success');
    end
    set(hObject, 'enable', 'on');
    set(hObject, 'String', 'Save MIDAS file');
else
    h = warndlg('The channel names are not valid. The channel name can not start with a number or contain the following characters:"+ - * / ^ [ ] ( ) { }" or any other matlab functions', 'Warning');
end
% --- Executes on button press in includeEventToMIDAS.
function includeEventToMIDAS_Callback(hObject, eventdata, handles)
% hObject    handle to includeEventToMIDAS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of includeEventToMIDAS
if get(hObject,'Value')
    success = handles.midasTableController.useEvents();
    if isequal(success, 0)
        set(hObject, 'Value', 0);
    end
else
    handles.midasTableController.doNotUseEvents();
end


% --- Executes on selection change in outputTimeUnit.
function outputTimeUnit_Callback(hObject, eventdata, handles)
% hObject    handle to outputTimeUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns outputTimeUnit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from outputTimeUnit
midasUnits = get(hObject, 'String');
midasUnitIndex = get(hObject, 'Value');
midasUnit = midasUnits{midasUnitIndex};

inputUnits = get(handles.inputTimeUnit, 'String');
inputUnitIndex = get(handles.inputTimeUnit, 'Value');
inputUnit = inputUnits{inputUnitIndex};

handles.midasTableController.recalculateTimeUnits(inputUnit, midasUnit);
handles.midasTableController.setTimeUnit(midasUnit);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function outputTimeUnit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputTimeUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in inputTimeUnit.
function inputTimeUnit_Callback(hObject, eventdata, handles)
% hObject    handle to inputTimeUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns inputTimeUnit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from inputTimeUnit
midasUnits = get(handles.outputTimeUnit, 'String');
midasUnitIndex = get(handles.outputTimeUnit, 'Value');
midasUnit = midasUnits{midasUnitIndex};

inputUnits = get(handles.inputTimeUnit, 'String');
inputUnitIndex = get(handles.inputTimeUnit, 'Value');
inputUnit = inputUnits{inputUnitIndex};

handles.midasTableController.recalculateTimeUnits(inputUnit, midasUnit);
handles.midasTableController.setTimeUnit(midasUnit);

% --- Executes during object creation, after setting all properties.
function inputTimeUnit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputTimeUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fastKinetics.
function fastKinetics_Callback(hObject, eventdata, handles)
% hObject    handle to fastKinetics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fastKinetics = get(hObject, 'Value');
timeColumn = generateTimeColumn(handles.experimentDataStructure, fastKinetics);
handles.midasTableController.setNewTimeData(timeColumn);

guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of fastKinetics



function timeShift_Callback(hObject, eventdata, handles)
% hObject    handle to timeShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeShift as text
%        str2double(get(hObject,'String')) returns contents of timeShift as a double
timeShift = str2double(get(hObject,'String'));
handles.midasTableController.recalculateTimeShift(timeShift);
guidata(hObject, handles)

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


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menu_ASCII_Callback(hObject, eventdata, handles)

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function treatments_Table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to treatments_Table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Data', {'', '', '', 'false', 'false'});
guidata(hObject, handles);


% --- Executes when entered data in editable cell(s) in treatments_Table.
function treatments_Table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to treatments_Table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate
%	value for Data
% handles    structure with handles and user data (see GUIDATA)
handles.treatments_TableData = get(hObject, 'data');
data = get(hObject,'Data'); % get the data cell array of the table
if sum(strcmp(fieldnames(eventdata), 'Indices')) % needed to make it work with both object (newer matlab versions) and struct (older ones)
    if isequal(eventdata.Indices(2), 4) % if the column of the edited cell is the delete column
        if eventdata.EditData && handles.dimensionality > 1 % if the checkbox was set to true
            data{eventdata.Indices(1),eventdata.Indices(2)} = true; % set the data value to true
            data(eventdata.Indices(1), :) = [];
            handles.dimensionality = handles.dimensionality - 1;
            handles.midasTableController.deleteTreatmentColumnByIndex(eventdata.Indices(1));
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
set(hObject, 'Data', data);
handles = changeDimensionality(handles, num2str(handles.dimensionality));
handles = updateMidasHeaders(handles);
handles.apareciumExperimentInput.updateTreatments(handles.treatments_TableData);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function MIDAS_table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MIDAS_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% set(hObject, 'Data', {}, 'visible', 'off');
handles.midasTableController = MidasTableController(hObject);
handles.midasTableController.startWithOneMeasurementColumn();
handles.midasTableController.addTreatmentColumn(' ', '', '');
guidata(hObject, handles);



function plateName_Callback(hObject, eventdata, handles)
% hObject    handle to plateName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plateName as text
%        str2double(get(hObject,'String')) returns contents of plateName as a double
plateName = get(hObject, 'String');
handles.midasTableController.changePlateName(plateName);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function plateName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plateName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.e
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in simPlateDone.
function simPlateDone_Callback(hObject, eventdata, handles)
% hObject    handle to simPlateDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.simPlateHandle, 'visible', 'off');
set(handles.loadFilePanel, 'visible', 'on');
set(handles.MIDASPreviewPanel, 'visible', 'on');
set(handles.ExperimentConfigurationPanel, 'visible', 'on');
%set(handles.simPlateDone, 'visible', 'off');
set(handles.figure1, 'Color', [225/255, 226/255, 251/255]);
treatmentStructure = handles.plateSimulatorInterface.getTreatmentStructure();
handles.midasTableController.updateTreatments(treatmentStructure);



% --- Executes on button press in moveToMidasTools.
function moveToMidasTools_Callback(hObject, eventdata, handles)
% hObject    handle to moveToMidasTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of moveToMidasTools
if(handles.midasTableController.channelNamesAreValid())
    set(handles.figure1, 'visible' ,'off');
    pause(0.05);
    handles.midasTableController.setEventDataEqualToData();
    MIDASTools(handles.midasTableController, 'fromMidasTable');
else
    h = warndlg(['The channel names are not valid. The channel name can not start with a number or contain the following characters:"+ - * / ^ [ ] ( ) { }" or any other matlab functions'], 'Warning');
end
% --- Executes when entered data in editable cell(s) in channels_Table.
function channels_Table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to channels_Table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
channelData = get(hObject, 'data');
channelNames = channelData(:,2);
handles.apareciumExperimentInput.setChannelNames(channelNames);
updateMidasChannels(handles);
guidata(hObject, handles);

function initializeChannelsTable(handles)
set(handles.channels_Table,'Data',[]);
guidata(handles.channels_Table, handles);

function setChannels(handles)
channelNames = handles.apareciumExperimentInput.getChannelNames();
noOfChannels = handles.apareciumExperimentInput.numberOfChannels();
userDefNames = cell(1,2);
%[userDefNames{:}] = deal('');
userDefNames = handles.apareciumExperimentInput.getChannelNames();
data =[channelNames', userDefNames'];
set(handles.channels_Table,'Data',data);
handles.apareciumExperimentInput.setChannelNames(userDefNames);
updateMidasChannels(handles);
guidata(handles.channels_Table, handles);


% --------------------------------------------------------------------
function delete_Callback(hObject, eventdata, handles)
% hObject    handle to delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function deleteRow_Callback(hObject, eventdata, handles)
% hObject    handle to deleteRow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function treatments_Table_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to treatments_Table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
'test';


% --- Executes when selected cell(s) is changed in treatments_Table.
function treatments_Table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to treatments_Table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
data=get(hObject,'Data'); % get the data cell array of the table

set(hObject,'Data',data); % now set the table's data to the updated data cell array
guidata(hObject, handles);


% --------------------------------------------------------------------
function options_Callback(hObject, eventdata, handles)
% hObject    handle to options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SettingsUI();


% --- Executes on button press in moveToExportWizard.
function moveToExportWizard_Callback(hObject, eventdata, handles)
% hObject    handle to moveToExportWizard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.midasTableController.channelNamesAreValid())
    handles.midasTableController.setEventDataEqualToData();
    ExportTools(handles.midasTableController);
else
     h = warndlg(['The channel names are not valid. The channel name can not start with a number or contain the following characters:"+ - * / ^ [ ] ( ) { }" or any other matlab functions'], 'Warning');
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApareciumCommonImporterFunctions.figure1_ResizeFcn(hObject, eventdata, handles);