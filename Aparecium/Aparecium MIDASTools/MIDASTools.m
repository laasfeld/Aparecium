function varargout = MIDASTools(varargin)
% MIDASTOOLS M-file for MIDASTools.fig
%      MIDASTOOLS, by itself, creates a new MIDASTOOLS or raises the existing
%      singleton*.
%
%      H = MIDASTOOLS returns the handle to a new MIDASTOOLS or the handle to
%      the existing singleton*.
%
%      MIDASTOOLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MIDASTOOLS.M with the given input arguments.
%
%      MIDASTOOLS('Property','Value',...) creates a new MIDASTOOLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MIDASTools_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MIDASTools_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MIDASTools

% Last Modified by GUIDE v2.5 05-Nov-2018 15:46:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MIDASTools_OpeningFcn, ...
                   'gui_OutputFcn',  @MIDASTools_OutputFcn, ...
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


% --- Executes just before MIDASTools is made visible.
function MIDASTools_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MIDASTools (see VARARGIN)

% Choose default command line output for MIDASTools
addApareciumToPath();
set(0,'defaultuicontrolfontname','MS Sans Serif', 'defaultuicontrolfontsize', 8);
handles.output = hObject;
handles.fileChooser = FileChooser();
handles.midasControllerArray = cell(0,0);
handles.mainMIDASTable = createMIDAS_table(handles.MIDASTablePanel);
try
    handles.midasTableController = varargin{1};    
    handles.midasTableController.setMidasTableHandle(handles.mainMIDASTable);
    handles.midasTableController.showTable();
    handles.mainMIDASTable.setVisible('on');
    set(handles.MIDASInformationText, 'String', ['MIDAS file ', handles.midasTableController.fileName, ' loaded']);
    handles.fileName = handles.midasTableController.fileName;
catch
    try
        if isequal(numel(varargin), 2) && strcmp(varargin{2}, 'fromMidasTable')
            warndlg('Error loading midasTableController');
        else            
            handles.midasTableController = MidasTableController(handles.mainMIDASTable);
        end
    catch
        
    end
end
handles.dimensionality = [];
handles.apareciumExperimentInput = ApareciumExperimentInput();
handles.plateSimulatorInterface = PlateSimulatorInterface();
handles.plateSimulatorInterface.attemptMidasInitialize = 1;
handles = ExperimentConfigurationPanelFunc(handles);
set(handles.ExperimentConfigurationPanel, 'Position', [0.37	0.1056 0.244	0.8816]);
%LetItSnow(); %just a holyday easteregg
% Update handles structure
set(handles.stackTable,'Data',[]);
guidata(hObject, handles);

% UIWAIT makes MIDASTools wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MIDASTools_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)
% hObject    handle to file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function loadPrimaryMIDASFile_Callback(hObject, eventdata, handles)
% hObject    handle to loadPrimaryMIDASFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fullFilePath, fileName] = handles.fileChooser.chooseMIDASFile();
handles.midasTableController.readMidasFile(fullFilePath);


% --------------------------------------------------------------------
function loadSecondaryMIDASFile_Callback(hObject, eventdata, handles)
% hObject    handle to loadSecondaryMIDASFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in importMidasToStacker.
function importMidasToStacker_Callback(hObject, eventdata, handles)
% hObject    handle to importMidasToStacker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fullFilePath, fileName] = handles.fileChooser.chooseMIDASFile();
midasTableController = MidasTableController('empty');
midasTableController.readMidasFile(fullFilePath);
handles.midasControllerArray{end + 1} = midasTableController;
handles.stackTableController.setMidasControllerArray(handles.midasControllerArray);
handles.stackTableController.update();
set(handles.setAsPrimaryMidas, 'Enable', 'on');
successBox('MIDAS file successfully loaded', 'Success');
guidata(hObject, handles);

% --- Executes on button press in importMultipleMidasFiles.
function importMultipleMidasFiles_Callback(hObject, eventdata, handles)
% hObject    handle to importMultipleMidasFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fullFilePathArray, fileNameArray] = handles.fileChooser.chooseMultipleMIDASFiles();
for MIDASIndex = 1 : numel(fullFilePathArray)
    midasTableController = MidasTableController('empty');
    midasTableController.readMidasFile(fullFilePathArray{MIDASIndex});
    handles.midasControllerArray{end + 1} = midasTableController;
    handles.stackTableController.setMidasControllerArray(handles.midasControllerArray);
    handles.stackTableController.update();
end
set(handles.setAsPrimaryMidas, 'Enable', 'on');
successBox('MIDAS files successfully loaded', 'Success');
guidata(hObject, handles);

% --- Executes on button press in exportWizard.
function exportWizard_Callback(hObject, eventdata, handles)
% hObject    handle to exportWizard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ExportTools(handles.midasTableController);

% --- Executes on button press in resolveHeaderConflicts.
function resolveHeaderConflicts_Callback(hObject, eventdata, handles)
% hObject    handle to resolveHeaderConflicts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function mainMIDASTable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mainMIDASTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.midasTableController = MidasTableController(hObject);
guidata(hObject, handles);


% --- Executes on button press in setAsPrimaryMidas.
function setAsPrimaryMidas_Callback(hObject, eventdata, handles)
% hObject    handle to setAsPrimaryMidas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.midasTableController = mergeMIDASFiles(handles.stackTableController, handles.midasTableController);
handles.midasTableController.setMidasTableHandle(handles.mainMIDASTable);
handles.midasTableController.showTable();
handles.midasTableController.setEventDataEqualToData();
handles.mainMIDASTable.setVisible('on');
set(handles.MIDASInformationText, 'String', ['MIDAS file ', handles.midasTableController.fileName, ' loaded']);
handles.fileName = handles.midasTableController.fileName;
initializeExperimentConfigurationPanel(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stackTable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stackTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.stackTableController = stackTableController(hObject);
guidata(hObject, handles);


% --- Executes on button press in LoadPrimaryMIDAS.
function LoadPrimaryMIDAS_Callback(hObject, eventdata, handles)
% hObject    handle to LoadPrimaryMIDAS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadPrimaryMIDASFile_Callback(hObject, eventdata, handles);
successBox('MIDAS file successfully loaded', 'Success');
handles.mainMIDASTable.setVisible('on');
set(handles.MIDASInformationText, 'String', ['MIDAS file ', handles.midasTableController.fileName, ' loaded']);
handles.fileName = handles.midasTableController.fileName;
initializeExperimentConfigurationPanel(handles);

function initializeExperimentConfigurationPanel(handles)
handles =  MidasToApareciumExperimentInput(handles.midasTableController, handles);
handles.apareciumExperimentInput.setMode('addTreatments');
handles.midasTableController.setDataEqualToEventData(); % MIDAS is loaded with all data as events data but some operations are carried out on table data.
set(handles.ChooseDimensionality, 'Value', handles.apareciumExperimentInput.getNumberOfTreatments());
handles = changeDimensionality(handles, handles.apareciumExperimentInput.getNumberOfTreatments());
treatmentsTableData = handles.apareciumExperimentInput.getTreatmentsTableData();
set(handles.treatments_Table, 'Data', treatmentsTableData);
channels = handles.apareciumExperimentInput.getChannelNames();
channelsTableData = [channels', channels'];
set(handles.channels_Table, 'Data', channelsTableData);
drawnow();
pause(0.05);
guidata(handles.figure1, handles);


% --- Executes on button press in SaveMIDASFile.
function SaveMIDASFile_Callback(hObject, eventdata, handles)
% hObject    handle to SaveMIDASFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputStruct.data = handles.midasTableController.getMidasTable();
inputStruct.fileName = '';
result = saveMidasFile(inputStruct);
if isequal(result, 1)
    successBox('MIDAS file successfully saved', 'Success');
end

% --------------------------------------------------------------------
function options_Callback(hObject, eventdata, handles)
% hObject    handle to options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SettingsUI();

% --------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
openApareciumHelp();

% --- Executes on button press in loadToDataRail.
function loadToDataRail_Callback(hObject, eventdata, handles)
% hObject    handle to loadToDataRail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputStruct.data = handles.midasTableController.getMidasTable();
inputStruct.fileName = 'tempCSVForDataRail.csv';
load javaPath
inputStruct.filePath = Path;
inputStruct.automatically = 1;
saveMidasFile(inputStruct);
newFileName = ConvertDAALLtoMIDAS([inputStruct.filePath, inputStruct.fileName]);

h = startDataRail(); %start without gui
set(0,'defaultuicontrolfontname','Sans Serif', 'defaultuicontrolfontsize', 11);
hyperCube = GuiMidasImporter(newFileName, 'Aparecium');

GuiMain(hyperCube);
delete([inputStruct.filePath, inputStruct.fileName]);
set(handles.figure1,'Visible', 'off');

function removeEvents_Callback(hObject,eventdata,handles)
    handles.midasTableController.removeDuplicates()
''


% --- Executes when entered data in editable cell(s) in stackTable.
function stackTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to stackTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
handles.stackTableController.updateTimeshifts(eventdata);
handles = handles.stackTableController.removeFilesFromTable(eventdata, handles);
if isequal(numel(handles.midasControllerArray), 0)
   set(handles.setAsPrimaryMidas, 'Enable', 'off');
end

guidata(hObject, handles);


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.midasTableController.convertToSlowKinetics();
handles.midasTableController.showTable();


% --- Executes on button press in convertToSeparateTimepoints.
function convertToSeparateTimepoints_Callback(hObject, eventdata, handles)
% hObject    handle to convertToSeparateTimepoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.midasTableController.convertToStandardMIDASTable();


% --- Executes on button press in convert.
function convert_Callback(hObject, eventdata, handles)
% hObject    handle to convert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
results = TreatmentAndMeasurementConverter(get(handles.treatments_Table, 'data'));
handles.midasTableController.replaceTreatmentValuesFromTreatmentAndMeasurementConverter(results);
handles = MidasToApareciumExperimentInput(handles.midasTableController, handles);
handles.apareciumExperimentInput.setMode('addTreatments');
treatmentsTableData = handles.apareciumExperimentInput.getTreatmentsTableData();
set(handles.treatments_Table, 'data', treatmentsTableData);
drawnow();
pause(0.05);
guidata(hObject, handles);

