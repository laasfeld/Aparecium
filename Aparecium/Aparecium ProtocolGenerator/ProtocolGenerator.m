
function varargout = ProtocolGenerator(varargin)
% PROTOCOLGENERATOR M-file for ProtocolGenerator.fig
%      PROTOCOLGENERATOR, by itself, creates a new PROTOCOLGENERATOR or raises the existing
%      singleton*.
%
%      H = PROTOCOLGENERATOR returns the handle to a new PROTOCOLGENERATOR or the handle to
%      the existing singleton*.
%
%      PROTOCOLGENERATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROTOCOLGENERATOR.M with the given input arguments.
%
%      PROTOCOLGENERATOR('Property','Value',...) creates a new
%      PROTOCOLGENERATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ProtocolGenerator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are passed to ProtocolGenerator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProtocolGenerator

% Last Modified by GUIDE v2.5 30-Aug-2017 17:12:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProtocolGenerator_OpeningFcn, ...
                   'gui_OutputFcn',  @ProtocolGenerator_OutputFcn, ...
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


% --- Executes just before ProtocolGenerator is made visible.
function ProtocolGenerator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ProtocolGenerator (see VARARGIN)

% Choose default command line output for ProtocolGenerator
addApareciumToPath();
handles.output = hObject;
handles.protocol = ExperimentProtocol();
handles.ExcelProtocol = ExcelProtocol();
handles.dimensionality = 1;
handles.treatments_TableData = [];
handles.midasTableController = handles.protocol.getExampleMIDASTableController();
handles.midasTableController.addTreatmentColumn(' ', '', '');
handles.plateSimulatorInterface = PlateSimulatorInterface();
handles.pipetingSimulatorInterface = PipetingSimulatorInterface();
handles.protocol.setPipetingSimulatorInterface(handles.pipetingSimulatorInterface);
handles.imageProcessingParameters = ImageProcessingParameters();
handles.protocol.imageAnalyzer.setImageProcessingParameters(handles.imageProcessingParameters);
handles.imageProcessingParameters.automaticallySaveMidasFile = 'off';
handles = createTreatmentNameOptionsStruct(handles);
handles = createTreatmentNameWithConcAndUnitsOptionsStruct(handles);
handles = createTreatmentNameWithConcOptionsStruct(handles);
handles = createPlateLayoutWithGroupsOptionsStruct(handles);
handles = createPlateLayoutWithSubgroupsOptionsStruct(handles);
handles = createExportNamesOptionsStruct(handles);
handles = createPlateLayoutWithTreatmentsOptionsStruct(handles);
handles = createPipetingSequenceOptionsStruct(handles);
showSingleAdditionalOptionsPanel(handles, 'none');
handles.TabGroup = hideTabs(handles.figure1, handles);
handles.TabsAreShown = 0;
imageImporter = ImageImporter();
handles.imageAnalyzer = handles.protocol.imageAnalyzer;
handles.protocol.imageAnalyzer.setImageImporter(imageImporter);
handles.cameraAndLensParameters = CameraAndLensParameters();
handles.protocol.imageAnalyzer.setCameraAndLensParameters(handles.cameraAndLensParameters);
handles.protocol.apareciumExperimentInput.updateTreatments(handles.treatments_TableData);
handles.apareciumExperimentInput = handles.protocol.apareciumExperimentInput;
handles.plateSimulatorHasBeenOpenedThisSession = 1;
handles.pipetingSimulatorHasBeenOpenedThisSession = 0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ProtocolGenerator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ProtocolGenerator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function handles = createTreatmentNameOptionsStruct(handles)
handles.treatmentNamesStruct = struct();
handles.treatmentNamesStruct.transpose = 0;

function handles = createTreatmentNameWithConcAndUnitsOptionsStruct(handles)
handles.treatmentNameWithConcAndUnitsStruct = struct();
handles.treatmentNameWithConcAndUnitsStruct.transpose = 0;
handles.treatmentNameWithConcAndUnitsStruct.unitStyle = '(<unit>)';
handles.treatmentNameWithConcAndUnitsStruct.customStyle = '';

function handles = createTreatmentNameWithConcOptionsStruct(handles)
handles.treatmentNameWithConcStruct = struct();
handles.treatmentNameWithConcStruct.transpose = 0;

function handles = createPlateLayoutWithGroupsOptionsStruct(handles)
handles.plateLayoutWithGroupsStruct = struct();
handles.plateLayoutWithGroupsStruct.transpose = 0;
handles.plateLayoutWithGroupsStruct.exportIndex = 1;

function handles = createPlateLayoutWithSubgroupsOptionsStruct(handles)
handles.plateLayoutWithSubgroupsStruct = struct();
handles.plateLayoutWithSubgroupsStruct.transpose = 0;
handles.plateLayoutWithSubgroupsStruct.exportIndex = 1;

function handles = createExportNamesOptionsStruct(handles)
handles.exportNamesStruct = struct();
handles.exportNamesStruct.transpose = 0;

function handles = createPlateLayoutWithTreatmentsOptionsStruct(handles)
handles.plateLayoutWithTreatments = struct();
handles.plateLayoutWithTreatments.transpose = 0;
handles.plateLayoutWithTreatments.treatmentTag = '';
handles.plateLayoutWithTreatments.treatmentName = '';

function handles = createPipetingSequenceOptionsStruct(handles)
handles.pipetingSequenceStruct = struct();
handles.pipetingSequenceStruct.PipetingSimulator = handles.pipetingSimulatorInterface;

function previewTabGroup = createTabs(hObject, handles)

previewTabGroup = uitabgroup('v0','Parent', handles.TabsPanel);
tab1 = uitab('v0','Parent', previewTabGroup, 'Title', 'Protocol');
tab2 = uitab('v0','Parent', previewTabGroup, 'Title', 'ICSE');
set(handles.uipanel27, 'Parent', tab1);
set(handles.ICSEOptions, 'Parent', tab2);
set(handles.ICSEOptions, 'Visible', 'on');
guidata(hObject, handles);

function previewTabGroup = hideTabs(hObject, handles)

previewTabGroup = uitabgroup('Parent', handles.TabsPanel);
tab1 = uitab('Parent', previewTabGroup, 'Title', 'Protocol');
set(handles.uipanel27, 'Parent', tab1);
set(handles.ICSEOptions, 'Parent', handles.TabsPanel);
set(handles.ICSEOptions, 'Visible', 'off');

guidata(hObject, handles);

% --- Executes on selection change in toolSelection.
function toolSelection_Callback(hObject, eventdata, handles)
% hObject    handle to toolSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns toolSelection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from toolSelection
contents = get(hObject,'String');
handles.protocol.setToolOfProtocol(contents{get(hObject,'Value')});
if strcmp(contents{get(hObject,'Value')}, 'ICSETools') && isequal(handles.TabsAreShown, 0);
    createTabs(handles.figure1, handles);
    handles.TabsAreShown = 1;
    
    channelNames{1,1} = 'Cell_area_um2';
    channelNames{2,1} = 'Area_STD_um2';
    channelNames{3,1} = 'Cell_diameter_um';
    channelNames{4,1} = 'Diameter_STD_um';
    channelNames{5,1} = 'Cell_count';
    channelNames{6,1} = 'Max_cell_diameter_um';

    for index = 1 : size(channelNames, 1)
       channelNames{index, 2} = channelNames{index, 1}; 
    end
    set(handles.numberOfChannels, 'String', num2str(size(channelNames, 1)));
    numberOfChannels_Callback(handles.numberOfChannels, [], handles);
    set(handles.channels_Table, 'Data', channelNames);
    channels_Table_CellEditCallback(handles.channels_Table, [], handles);
    set(handles.loadChannelsFromExampleFile, 'Enable', 'off');
    set(handles.fastKinetics, 'Enable', 'off');
    set(handles.inputTimeUnit, 'Enable', 'off');
    
elseif isequal(handles.TabsAreShown, 1)
    hideTabs(handles.figure1, handles);
    handles.TabsAreShown = 0;
    set(handles.loadChannelsFromExampleFile, 'Enable', 'on');
    set(handles.fastKinetics, 'Enable', 'on');
    set(handles.inputTimeUnit, 'Enable', 'on');
else
   set(handles.loadChannelsFromExampleFile, 'Enable', 'on'); 
   set(handles.fastKinetics, 'Enable', 'on');
   set(handles.inputTimeUnit, 'Enable', 'on');
end


guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function toolSelection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to toolSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function experimentName_Callback(hObject, eventdata, handles)
% hObject    handle to experimentName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of experimentName as text
%        str2double(get(hObject,'String')) returns contents of experimentName as a double
handles.protocol.setExperimentName(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function experimentName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to experimentName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in createMIDASFile.
function createMIDASFile_Callback(hObject, eventdata, handles)
% hObject    handle to createMIDASFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of createMIDASFile
handles.protocol.setCreateMIDASFile(get(hObject,'Value'));
guidata(hObject, handles);

% --- Executes on selection change in exportListbox.
function exportListbox_Callback(hObject, eventdata, handles)
% hObject    handle to exportListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns exportListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from exportListbox


% --- Executes during object creation, after setting all properties.
function exportListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exportListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in createNewExports.
function createNewExports_Callback(hObject, eventdata, handles)
% hObject    handle to createNewExports (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rawData = sendDataToMidasTable(handles.protocol.exampleExperimentDataStructure, handles.dimensionality);
handles.midasTableController.setData(rawData);
handles.protocol.exampleMIDASTableController.updateTreatments(handles.protocol.treatmentStructure);
handles.midasTableController.setEventDataEqualToData();
newExports = ExportTools(handles.midasTableController, 'Protocol Generator');
handles.protocol.addNewExports(newExports);
handles = updateExportsList(handles);
guidata(hObject, handles);


function handles = updateExportsList(handles)
listOfExports = handles.protocol.getListOfExports();
exportNames = cell(1, numel(listOfExports));
for exportIndex = 1 : numel(listOfExports)
    exportNames{exportIndex} = listOfExports{exportIndex}.exportName;
end
if isempty(exportNames)
    set(handles.exportDropDown, 'Enable', 'off');
    set(handles.exportDropDown, 'String', {''});
    
    set(handles.plateLayoutWithSubgroupsExportChooser, 'Enable', 'off');
    set(handles.plateLayoutWithSubgroupsExportChooser, 'String', {''});
else
    set(handles.exportDropDown, 'Enable', 'on');
    set(handles.exportDropDown, 'String', exportNames);
    
    set(handles.plateLayoutWithSubgroupsExportChooser, 'Enable', 'on');
    set(handles.plateLayoutWithSubgroupsExportChooser, 'String', exportNames);
end
set(handles.exportListbox, 'String', exportNames);

% --- Executes on button press in deleteSelectedExports.
function deleteSelectedExports_Callback(hObject, eventdata, handles)
% hObject    handle to deleteSelectedExports (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in editSelectedExport.
function editSelectedExport_Callback(hObject, eventdata, handles)
% hObject    handle to editSelectedExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = get(handles.exportListbox,'String');
activeExportIndex = get(hObject,'Value');
listOfExports = handles.protocol.getListOfExports();
exportCell = ExportTools(handles.midasTableController, listOfExports{activeExportIndex}, 'Edit protocol');
export = exportCell{1};
handles.protocol.replaceExport(activeExportIndex, export);
handles = updateExportsList(handles);
guidata(hObject, handles);


function height_Callback(hObject, eventdata, handles)
% hObject    handle to height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of height as text
%        str2double(get(hObject,'String')) returns contents of height as a double
handles.protocol.setPlateHeight(str2double(get(hObject,'String')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function height_CreateFcn(hObject, eventdata, handles)
% hObject    handle to height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function width_Callback(hObject, eventdata, handles)
% hObject    handle to width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of width as text
%        str2double(get(hObject,'String')) returns contents of width as a double
handles.protocol.setPlateWidth(str2double(get(hObject,'String')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function plateName_Callback(hObject, eventdata, handles)
% hObject    handle to plateName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plateName as text
%        str2double(get(hObject,'String')) returns contents of plateName as a double
plateName = get(hObject, 'String');
handles.protocol.getExampleMIDASTable.changePlateName(plateName);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function plateName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plateName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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
contents = get(hObject,'String');
handles.protocol.setInputTimeUnit(contents{get(hObject,'Value')});
guidata(hObject, handles);

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

% Hint: get(hObject,'Value') returns toggle state of fastKinetics
handles.protocol.setFastKinetics(get(hObject,'Value'));
guidata(hObject, handles);

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in OpenPlateSimulator.
function OpenPlateSimulator_Callback(hObject, eventdata, handles)
% hObject    handle to OpenPlateSimulator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.plateSimulatorInterface.addExperiment(handles.protocol.apareciumExperimentInput);
handles.simPlateHandle = handles.plateSimulatorInterface.generatePlateSimulator(handles);
if ~handles.plateSimulatorHasBeenOpenedThisSession
    handles.plateSimulatorInterface.regeneratePlateSimulatorFromTreatmentStructure(handles.protocol.treatmentStructure);
    handles.plateSimulatorHasBeenOpenedThisSession = 1;
end
handles = setUIModeToPlateSim(handles);
guidata(hObject, handles);

function handles = setUIModeToPlateSim(handles)
set(handles.generalOptions, 'visible', 'off');
set(handles.ExperimentConfigurationPanel, 'visible', 'off');
set(handles.figure1, 'Color', 'white');
doneCallbackHandle = @simPlateDone_Callback;
doneHandler(handles.plateSimulatorInterface.PlateSimulator.done, handles, doneCallbackHandle);

function handles = setUIModeToPipetingSim(handles)
%set(handles.generalOptions, 'visible', 'off');
%set(handles.ExperimentConfigurationPanel, 'visible', 'off');
set(handles.figure1, 'Color', 'white');
doneCallbackHandle = @simPipetingDone_Callback;
doneHandler(handles.pipetingSimulatorInterface.PipetingSimulator.done, handles, doneCallbackHandle);

function simPlateDone_Callback(hObject, eventdata, handles)
set(handles.simPlateHandle, 'visible', 'off');
set(handles.experimentNameText, 'visible', 'on');
set(handles.experimentName, 'visible', 'on');
set(handles.generalOptions, 'visible', 'on');
set(handles.exportsPanel, 'visible', 'on');
set(handles.protocolExportPanel, 'visible', 'on');
set(handles.ExperimentConfigurationPanel, 'visible', 'on');
set(handles.figure1, 'Color', [225/255, 226/255, 251/255]);
treatmentStructure = handles.plateSimulatorInterface.getTreatmentStructure();
handles.protocol.exampleMIDASTableController.updateTreatments(treatmentStructure);
handles.protocol.treatmentStructure = treatmentStructure;
guidata(handles.figure1, handles);

function simPipetingDone_Callback(hObject, eventdata, handles)
set(handles.simPipetingHandle, 'visible', 'off');
set(handles.experimentNameText, 'visible', 'on');
set(handles.experimentName, 'visible', 'on');
set(handles.generalOptions, 'visible', 'on');
set(handles.exportsPanel, 'visible', 'on');
set(handles.protocolExportPanel, 'visible', 'on');
set(handles.ExperimentConfigurationPanel, 'visible', 'on');
set(handles.figure1, 'Color', [225/255, 226/255, 251/255]);

guidata(handles.figure1, handles);

% --- Executes on button press in LoadConfigurationFile.
function LoadConfigurationFile_Callback(hObject, eventdata, handles)
% hObject    handle to LoadConfigurationFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApareciumCommonImporterFunctions.LoadConfigurationFile_Callback(hObject, eventdata, handles);

% --- Executes on button press in SaveConfigurationFile.
function SaveConfigurationFile_Callback(hObject, eventdata, handles)
% hObject    handle to SaveConfigurationFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.fileName = '';
saveConfiguration(handles);
successBox('Configuration file successfully saved', 'Success');

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function ChooseDimensionality_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseDimensionality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ChooseDimensionality as text
%        str2double(get(hObject,'String')) returns contents of ChooseDimensionality as a double
dimensionality = get(hObject,'String');
handles = changeDimensionality(handles, dimensionality);
handles.protocol.setDimensionality(handles.dimensionality);
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


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.excel = ExcelProtocolInterface();
handles.ExcelProtocol.templateTableIndex
if handles.ExcelProtocol.templateTableIndex > 0
    cell.column = 1;
    cell.row = 1;
   handles.excel.sendTableToPredefinedCell(handles.ExcelProtocol.getTemplateTable().getTable(), cell); 
end
guidata(hObject, handles);

% --- Executes on selection change in exportTableParameter.
function exportTableParameter_Callback(hObject, eventdata, handles)
% hObject    handle to exportTableParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns exportTableParameter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from exportTableParameter
contents = get(handles.exportTableParameter,'String');
handles.visualProtocolParameterName = contents{get(handles.exportTableParameter,'Value')};
switch contents{get(handles.exportTableParameter,'Value')};
    case 'Experiment name'
        showExperimentName(handles);
    case 'Height'
        showHeight(handles);
    case 'Width'
        showWidth(handles);
    case 'Treatment names'
        showTreatmentNames(handles);
    case 'Treatment names with concentrations'
        showTreatmentNamesWithConcentrations(handles);
    case 'Treatment names with concentrations and units'
        showTreatmentNamesWithConcentrationsAndUnits(handles);
    case 'Plate layout with treatments'
        showPlateLayoutWithTreatments(handles);
    case 'Plate layout with groups'
        showPlateLayoutWithGroups(handles);
    case 'Plate layout with subgroups'
        showPlateLayoutWithSubgroups(handles);
    case 'List of exports'
        showListOfExports(handles);
    case 'Pipeting sequence'
        showPipetingSequence(handles);
end
guidata(hObject, handles);

function handles = showExperimentName(handles)
    showSingleAdditionalOptionsPanel(handles, 'none');
    set(handles.exportParameterPreviewTable, 'Data', {handles.protocol.experimentName});
    
function handles = showHeight(handles)
    showSingleAdditionalOptionsPanel(handles, 'none');
    set(handles.exportParameterPreviewTable, 'Data', handles.protocol.plateHeight);
    
function handles = showWidth(handles)
    showSingleAdditionalOptionsPanel(handles, 'none');
    set(handles.exportParameterPreviewTable, 'Data', handles.protocol.plateWidth);
    
function handles = showTreatmentNames(handles)
    showSingleAdditionalOptionsPanel(handles, handles.TreatmentNames);
    treatmentNames = handles.protocol.getTreatmentNames();
    if handles.treatmentNamesStruct.transpose
       treatmentNames = treatmentNames'; 
    end
    set(handles.exportParameterPreviewTable, 'Data', treatmentNames);
    
function handles = showTreatmentNamesWithConcentrations(handles)
    showSingleAdditionalOptionsPanel(handles, handles.TreatmentNamesWithConc);
    treatmentNames = handles.protocol.getTreatmentNames();
    concentrations = handles.protocol.getTreatmentConcentrations();
    table(1, :) = treatmentNames;
    for treatment = 1 : numel(treatmentNames)
       table(2:numel(concentrations{treatment})+1, treatment) = num2cell(concentrations{treatment}); 
    end
    
    if handles.treatmentNameWithConcStruct.transpose
        table = table';
    end
    set(handles.exportParameterPreviewTable, 'Data', table);
    

function handles = showTreatmentNamesWithConcentrationsAndUnits(handles)
    showSingleAdditionalOptionsPanel(handles, handles.TreatmentNamesWithConcAndUnits);
    treatmentNames = handles.protocol.getTreatmentNames();
    concentrations = handles.protocol.getTreatmentConcentrations();
    units = handles.protocol.getTreatmentUnits();
    table(1, :) = treatmentNames;
    for treatment = 1 : numel(treatmentNames)
       table{1, treatment} = [table{1, treatment}, '(', units{treatment},')'];
       table(2:numel(concentrations{treatment})+1, treatment) = num2cell(concentrations{treatment}); 
    end
    if handles.treatmentNameWithConcAndUnitsStruct.transpose
       table = table'; 
    end
    set(handles.exportParameterPreviewTable, 'Data', table);

function handles = showPlateLayoutWithTreatments(handles)
    set(handles.chooseTreatment, 'Enable', 'on');
    showSingleAdditionalOptionsPanel(handles, handles.PlateLayoutWithTreatments);
    treatmentNames = handles.protocol.getTreatmentNames();
    concentrations = handles.protocol.getTreatmentConcentrations();
    units = handles.protocol.getTreatmentUnits();
    plateTable = generatePlateTable(handles.protocol.plateHeight, handles.protocol.plateWidth);
    activeTreatmentName = handles.plateLayoutWithTreatments.treatmentName;
    for treatmentIndex = 1 : numel(treatmentNames)
        if strcmp(activeTreatmentName, treatmentNames{treatmentIndex})
           activeTreatmentIndex = treatmentIndex;
           break;
        end
    end
    plateTable{1, 1} = [treatmentNames{activeTreatmentIndex}, '(', units{activeTreatmentIndex}, ')'];
    treatmentStructure = handles.protocol.treatmentStructure;
    for wellIndex = 1 : numel(treatmentStructure.resultWells)
        [row, column] = handles.protocol.apareciumExperimentInput.getRowAndColumnIndecesOfWell(treatmentStructure.resultWells{wellIndex});
        plateTable{column + 1, row + 1} = treatmentStructure.results{wellIndex}(activeTreatmentIndex);
    end
    
    if handles.plateLayoutWithTreatments.transpose
       plateTable = plateTable'; 
    end
    set(handles.exportParameterPreviewTable, 'Data', plateTable);
        

function handles = showPlateLayoutWithGroups(handles)
    showSingleAdditionalOptionsPanel(handles, handles.PlateLayoutWithGroups);
    listOfExports = handles.protocol.getListOfExports();
    exportNames = handles.protocol.getExportNames();
    indexOfActiveExport = handles.plateLayoutWithGroupsStruct.exportIndex;
    
    groupNames = listOfExports{indexOfActiveExport}.getGroupNames();
    groupStructure = listOfExports{indexOfActiveExport}.getGroupStructure();
    plateTable = generatePlateTable(handles.protocol.plateHeight, handles.protocol.plateWidth);
    plateTable{1, 1} = ['Group stucture of ', exportNames{indexOfActiveExport}];
    treatmentStructure = handles.protocol.treatmentStructure;
    for wellIndex = 1 : numel(treatmentStructure.resultWells)
        [row, column] = handles.protocol.apareciumExperimentInput.getRowAndColumnIndecesOfWell(treatmentStructure.resultWells{wellIndex});
        plateTable{column + 1, row + 1} = groupNames{groupStructure(row, column, 1)};
    end
    if handles.plateLayoutWithGroupsStruct.transpose
        plateTable = plateTable';
    end
    set(handles.exportParameterPreviewTable, 'Data', plateTable);


function handles = showPlateLayoutWithSubgroups(handles)
    showSingleAdditionalOptionsPanel(handles, handles.PlateLayoutWithSubgroups); 
    listOfExports = handles.protocol.getListOfExports();
    exportNames = handles.protocol.getExportNames();
    indexOfActiveExport = get(handles.plateLayoutWithSubgroupsExportChooser, 'Value');
    subgroupNames = listOfExports{indexOfActiveExport}.getSubgroupNames();
    groupStructure = listOfExports{indexOfActiveExport}.getGroupStructure();
    plateTable = generatePlateTable(handles.protocol.plateHeight, handles.protocol.plateWidth);
    plateTable{1, 1} = ['Subgroup stucture of ', exportNames{indexOfActiveExport}];
    treatmentStructure = handles.protocol.treatmentStructure;
    for wellIndex = 1 : numel(treatmentStructure.resultWells)
        [row, column] = handles.protocol.apareciumExperimentInput.getRowAndColumnIndecesOfWell(treatmentStructure.resultWells{wellIndex});
        plateTable{column + 1, row + 1} = subgroupNames{groupStructure(row, column, 1)}{groupStructure(row, column, 2)+1};
    end
    if handles.plateLayoutWithSubgroupsStruct.transpose
        plateTable = plateTable';
    end
    set(handles.exportParameterPreviewTable, 'Data', plateTable);
    
function handles = showListOfExports(handles)
    showSingleAdditionalOptionsPanel(handles, handles.ExportNames);
    exportNames = handles.protocol.getExportNames();
    if handles.exportNamesStruct.transpose
        exportNames = exportNames';
    end
    set(handles.exportParameterPreviewTable, 'Data', exportNames);
    
function handles = showPipetingSequence(handles)
    table = handles.pipetingSimulatorInterface.createPipetingTable();   
    set(handles.exportParameterPreviewTable, 'Data', table);


% --- Executes during object creation, after setting all properties.
function exportTableParameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exportTableParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7


% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8


% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu9.
function popupmenu9_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu9


% --- Executes during object creation, after setting all properties.
function popupmenu9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu11.
function popupmenu11_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu11 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu11


% --- Executes during object creation, after setting all properties.
function popupmenu11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu10.
function popupmenu10_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu10


% --- Executes during object creation, after setting all properties.
function popupmenu10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu12.
function popupmenu12_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu12 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu12


% --- Executes during object creation, after setting all properties.
function popupmenu12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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
handles.treatments_TableData = get(hObject, 'data');
data = get(hObject,'Data'); % get the data cell array of the table

if ~isempty(eventdata) && sum(strcmp(fieldnames(eventdata), 'Indices')) % needed to make it work with both object (newer matlab versions) and struct (older ones)
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
        concentrations = autoSequenceGenerator();
        data{eventdata.Indices(1), 2} = concentrations;
    end
end
set(hObject, 'Data', data);
handles = changeDimensionality(handles, num2str(handles.dimensionality));
handles = updateMidasHeaders(handles);
handles.protocol.apareciumExperimentInput.updateTreatments(handles.treatments_TableData);
treatmentNames = data(:, 1);
set(handles.chooseTreatment, 'String', treatmentNames);
handles.plateLayoutWithTreatments.treatmentName = data{1, 1};
guidata(hObject, handles);


function numberOfChannels_Callback(hObject, eventdata, handles)
% hObject    handle to numberOfChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numberOfChannels as text
%        str2double(get(hObject,'String')) returns contents of numberOfChannels as a double
handles.protocol.setNumberOfChannels(str2double(get(hObject,'String')));
handles.protocol.generateEmptyExperiment();
channelNames = handles.protocol.getChannelNames();
previousData = get(handles.channels_Table, 'Data');
userDefinedChannels = channelNames;
if(size(previousData, 1) < numel(channelNames))
   userDefinedChannels(1 : size(previousData, 1)) = previousData(:, 2); 
else
   userDefinedChannels = previousData(1 : numel(channelNames), 2);
end

set(handles.channels_Table, 'Data', [channelNames, userDefinedChannels]);
channels_Table_CellEditCallback(handles.channels_Table, [], handles);
if handles.protocol.getNumberOfChannels() > 4
    set(handles.channels_Table, 'Position', [0.01278, 0.048026, 0.98, 0.65789]);
else
    set(handles.channels_Table, 'Position', [0.01278, 0.048026, 0.93, 0.65789]);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function numberOfChannels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numberOfChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
data = get(hObject, 'Data');
userDefinedChannelNames = data(:, 2);
handles.protocol.setChannelNames(userDefinedChannelNames);
handles.protocol.updateExampleExperimentDataStructureChannelNames();
handles.apareciumExperimentInput = handles.protocol.apareciumExperimentInput;
updateMidasChannels(handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function channels_Table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channels_Table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
cellContents = {'Channel 1'};
set(hObject, 'data', [cellContents, cellContents]);


% --- Executes on button press in loadChannelsFromExampleFile.
function loadChannelsFromExampleFile_Callback(hObject, eventdata, handles)
% hObject    handle to loadChannelsFromExampleFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = get(handles.toolSelection, 'String');
fileChooser = FileChooser();
switch contents{get(handles.toolSelection, 'Value')}
    case 'Gen5Tools'
        [fullFilePath, fileName] = fileChooser.userChooseNeoASCIIFile();         
        neoAsciiReader = NeoASCIIReader();
        neoAsciiReader.readFile(fullFilePath);
        experimentDataStructure = neoAsciiReader.experimentDataStructure;
        originalChannelNames = experimentDataStructure.channelNames';
        channelNames = ChannelManager.getMIDASChannelNames(experimentDataStructure.channelNames');
        
    case 'PerkinElmerTools'
        
    case 'PHERAStarTools'
        this.midasTableController = MIDASTableController('empty');
        fileChooser = FileChooser();
        switch questdlg('Load from ASCII or xBase database?', 'Question', 'xBase', 'ASCII', 'ASCII')
            case 'ASCII'
                [fullFilePath, fileName] = fileChooser.userChoosePheraStarASCIIFile();
                pheraStarAsciiReader = PheraSTARASCIIReader();
                pheraStarAsciiReader.readFile(fullFilePath);
                experimentDataStructure = pheraStarAsciiReader.experimentDataStructure;
            case 'xBase'
                [fullFilePath, fileName, parameterStructure] = userChoosePheraStarDatabase();
                pheraStarDatabaseReader = PheraStarDatabaseReader();
                pheraStarDatabaseReader.readFile(fullFilePath, parameterStructure);
                experimentDataStructure = pheraStarDatabaseReader.experimentDataStructure;

        end
        originalChannelNames = experimentDataStructure.channelNames';
        channelNames = ChannelManager.getMIDASChannelNames(experimentDataStructure.channelNames');
    case 'ICSETools'

    case 'MIDASTools'
end

data = cell(numel(channelNames), 2);
for index = 1 : numel(channelNames)
   data{index, 1} = originalChannelNames{index};
   data{index, 2} = channelNames{index};
end
set(handles.numberOfChannels, 'String', num2str(numel(channelNames)));
numberOfChannels_Callback(handles.numberOfChannels, [], handles);
set(handles.channels_Table, 'Data', data);
channels_Table_CellEditCallback(handles.channels_Table, [], handles);
guidata(hObject, handles);


% --- Executes on button press in saveProtocol.
function saveProtocol_Callback(hObject, eventdata, handles)
% hObject    handle to saveProtocol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.protocol.setExcelProtocol(handles.ExcelProtocol);
userSaveProtocolFile(handles.protocol);

% --- Executes on button press in loadProtocol.
function loadProtocol_Callback(hObject, eventdata, handles)
% hObject    handle to loadProtocol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileChooser = FileChooser();
[fullFilePath, fileName] = fileChooser.chooseProtocolFile();
load(fullFilePath);
handles.protocol = experimentProtocolObject;
handles.plateSimulatorHasBeenOpenedThisSession = 0;
handles.pipetingSimulatorHasBeenOpenedThisSession = 1;
handles.protocol.apareciumExperimentInput.setHasChanged(1);
handles = updateGUIToProtocol(handles);
guidata(hObject, handles);

function handles = updateGUIToProtocol(handles)
set(handles.height, 'String', num2str(handles.protocol.plateHeight));
set(handles.width, 'String', num2str(handles.protocol.plateWidth));
switch handles.protocol.toolOfProtocol
    case 'Gen5Tools'
        value = 1;
    case 'PerkinElmerTools'
        value = 2;
    case 'PHERAStarTools'
        value = 3;
    case 'ICSETools'
        value = 4;
        createTabs(handles.figure1, handles);
        handles.TabsAreShown = 1;
    case 'MIDASTools'
        value = 5;
end
set(handles.toolSelection, 'Value', value);
set(handles.experimentName, 'String', handles.protocol.experimentName);
set(handles.ChooseDimensionality, 'String', num2str(handles.protocol.dimensionality));
set(handles.numberOfChannels, 'String', num2str(handles.protocol.numberOfChannels));

treatmentNames = handles.protocol.getTreatmentNames();
treatmentConcentratons = handles.protocol.getTreatmentConcentrations();
treatmentUnits = handles.protocol.getTreatmentUnits();
numberOfTreatments = handles.protocol.getNumberOfTreatments();
for treatment = 1 : numberOfTreatments
   concentrations{treatment, 1} = regexprep(num2str(treatmentConcentratons{treatment}),'       ',' '); 
   falseValues{treatment} = false;
end
table = [treatmentNames', concentrations, treatmentUnits', falseValues', falseValues'];
set(handles.treatments_Table, 'Data', table);

channelNames = handles.protocol.getChannelNames();
numberOfChannels = numel(channelNames);
channelsTable = cell(numberOfChannels, 2);
for channelIndex = 1 : numberOfChannels
    channelsTable{channelIndex, 1} = ['Channel', num2str(channelIndex)];
    channelsTable{channelIndex, 2} = channelNames{channelIndex};
end

set(handles.channels_Table, 'Data', channelsTable);

updateExportsList(handles);
handles.midasTableController = handles.protocol.getExampleMIDASTableController();
handles.ExcelProtocol = handles.protocol.getExcelProtocol();
handles.dimensionality = handles.protocol.getDimensionality();
set(handles.ChooseDimensionality, 'String', num2str(handles.protocol.getDimensionality()));
guidata(handles.figure1, handles);



% --- Executes on button press in launch.
function launch_Callback(hObject, eventdata, handles)
% hObject    handle to launch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.protocol.launch();
guidata(hObject, handles);


% --- Executes on button press in createExcelTable.
function createExcelTable_Callback(hObject, eventdata, handles)
% hObject    handle to createExcelTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.protocol.setExcelProtocol(handles.ExcelProtocol);
handles.protocol.launchExcelProtocol();
guidata(hObject, handles);

% --- Executes on button press in sendToExcel.
function sendToExcel_Callback(hObject, eventdata, handles)
% hObject    handle to sendToExcel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
table = get(handles.exportParameterPreviewTable, 'Data');
cell = struct();
[cell.row, cell.column] = handles.excel.sendTableToActiveCell(table);
singleExcelTable = SingleExcelTable();
singleExcelTable.setPreferredCell(cell);
tableParameters = [];
contents = get(handles.exportTableParameter,'String');
switch contents{get(handles.exportTableParameter,'Value')};
    case 'Experiment name'
        singleExcelTable.setType('Experiment name');
    case 'Height'
        singleExcelTable.setType('Height');
    case 'Width'
        singleExcelTable.setType('Width');
    case 'Treatment names'
        singleExcelTable.setType('Treatment names');
        tableParameters = handles.treatmentNamesStruct;
    case 'Treatment names with concentrations'
        singleExcelTable.setType('Treatment names with concentrations');
        tableParameters = handles.treatmentNameWithConcStruct;
    case 'Treatment names with concentrations and units'
        singleExcelTable.setType('Treatment names with concentrations and units');
        tableParameters = handles.treatmentNameWithConcAndUnitsStruct;
    case 'Plate layout with treatments'
        singleExcelTable.setType('Plate layout with treatments');
        tableParameters = handles.plateLayoutWithTreatments;
    case 'Plate layout with groups'
        singleExcelTable.setType('Plate layout with groups');
        tableParameters = handles.plateLayoutWithGroupsStruct;
    case 'Plate layout with subgroups'
        singleExcelTable.setType('Plate layout with subgroups');
        tableParameters = handles.plateLayoutWithSubgroupsStruct;
    case 'List of exports'
        singleExcelTable.setType('List of exports');
        tableParameters = handles.exportNamesStruct;
    case 'Pipeting sequence'
        singleExcelTable.setType('Pipeting sequence');
        tableParameters = handles.pipetingSequenceStruct;
end
singleExcelTable.setTableParameters(tableParameters);
handles.ExcelProtocol.addNewTable(singleExcelTable);
guidata(hObject, handles);


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.treatmentNamesStruct.transpose = ~handles.treatmentNamesStruct.transpose;
exportTableParameter_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.treatmentNameWithConcStruct.transpose = ~handles.treatmentNameWithConcStruct.transpose;
exportTableParameter_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.treatmentNameWithConcAndUnitsStruct.transpose = ~handles.treatmentNameWithConcAndUnitsStruct.transpose;
exportTableParameter_Callback(hObject, eventdata, handles);
guidata(hObject, handles);


function popupmenu13_Callback(hObject, eventdata, handles)
% --- Executes on selection change in popupmenu13.
% hObject    handle to popupmenu13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu13 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu13
contents = get(hObject,'String');
handles.treatmentNameWithConcAndUnitsStruct.unitStyle = contents{get(hObject,'Value')};
exportTableParameter_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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


% --- Executes on button press in treatmentWithConcsAndUnits_treatmentName.
function treatmentWithConcsAndUnits_treatmentName_Callback(hObject, eventdata, handles)
% hObject    handle to treatmentWithConcsAndUnits_treatmentName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in treatmentWithConcsAndUnits_Unit.
function treatmentWithConcsAndUnits_Unit_Callback(hObject, eventdata, handles)
% hObject    handle to treatmentWithConcsAndUnits_Unit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function showSingleAdditionalOptionsPanel(handles, panel)
set(handles.TreatmentNamesWithConcAndUnits ,'visible', 'off');
set(handles.TreatmentNames ,'visible', 'off');
set(handles.TreatmentNamesWithConc ,'visible', 'off');
set(handles.PlateLayoutWithGroups ,'visible', 'off');
set(handles.uipanel18 ,'visible', 'off');
set(handles.PlateLayoutWithTreatments ,'visible', 'off');
set(handles.ExportNames ,'visible', 'off');
set(handles.PlateLayoutWithSubgroups ,'visible', 'off');
if ~strcmp(panel, 'none')
    set(panel, 'visible', 'on');
end


% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.plateLayoutWithSubgroupsStruct.transpose = ~handles.plateLayoutWithSubgroupsStruct.transpose;
exportTableParameter_Callback(handles.exportTableParameter, eventdata, handles)
guidata(hObject, handles);

% --- Executes on selection change in plateLayoutWithSubgroupsExportChooser.
function plateLayoutWithSubgroupsExportChooser_Callback(hObject, eventdata, handles)
% hObject    handle to plateLayoutWithSubgroupsExportChooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns plateLayoutWithSubgroupsExportChooser contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        plateLayoutWithSubgroupsExportChooser
handles.plateLayoutWithSubgroupsStruct.exportIndex = get(hObject,'Value');
exportTableParameter_Callback(handles.exportTableParameter, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function plateLayoutWithSubgroupsExportChooser_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plateLayoutWithSubgroupsExportChooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in transpose_export_names.
function transpose_export_names_Callback(hObject, eventdata, handles)
% hObject    handle to transpose_export_names (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.exportNamesStruct.transpose = ~handles.exportNamesStruct.transpose;
exportTableParameter_Callback(handles.exportTableParameter, eventdata, handles);
guidata(hObject, handles);

% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.plateLayoutWithTreatments.transpose = ~handles.plateLayoutWithTreatments.transpose;
exportTableParameter_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.plateLayoutWithGroupsStruct.transpose = ~handles.plateLayoutWithGroupsStruct.transpose;
exportTableParameter_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in uipanel26.
function uipanel26_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel26 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
if ~isequal(eventdata.NewValue, eventdata.OldValue)
    if isequal(eventdata.NewValue, handles.useTreatments)
        set(handles.chooseTreatment, 'Enable', 'on');
        set(handles.chooseTag, 'Enable', 'off');
    elseif isequal(eventdata.NewValue, handles.useTags)
        set(handles.chooseTreatment, 'Enable', 'off');
        set(handles.chooseTag, 'Enable', 'on');    
    end
end

% --- Executes on selection change in chooseTreatment.
function chooseTreatment_Callback(hObject, eventdata, handles)
% hObject    handle to chooseTreatment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns chooseTreatment contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chooseTreatment
contents = get(hObject,'String');
activeTreatmentName = contents{get(hObject,'Value')};
handles.plateLayoutWithTreatments.treatmentName = activeTreatmentName;
exportTableParameter_Callback(handles.exportTableParameter, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function chooseTreatment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseTreatment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in chooseTag.
function chooseTag_Callback(hObject, eventdata, handles)
% hObject    handle to chooseTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns chooseTag contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chooseTag


% --- Executes during object creation, after setting all properties.
function chooseTag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in exportDropDown.
function exportDropDown_Callback(hObject, eventdata, handles)
% hObject    handle to exportDropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns exportDropDown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from exportDropDown
handles.plateLayoutWithGroupsStruct.exportIndex = get(handles.exportDropDown, 'Value');
exportTableParameter_Callback(handles.exportTableParameter, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function exportDropDown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exportDropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function connectionToTemplate_Callback(hObject, eventdata, handles)
% hObject    handle to connectionToTemplate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function treatments_Table_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to treatments_Table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes when selected cell(s) is changed in treatments_Table.
function treatments_Table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to treatments_Table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)




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



function maxEcc_Callback(hObject, eventdata, handles)
% hObject    handle to maxEcc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxEcc as text
%        str2double(get(hObject,'String')) returns contents of maxEcc as a double
handles.imageProcessingParameters.setMaxEcc(str2double(get(hObject,'String'))); % change the maxEcc parameter 
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function maxEcc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxEcc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxSizeMSER_Callback(hObject, eventdata, handles)
% hObject    handle to maxSizeMSER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxSizeMSER as text
%        str2double(get(hObject,'String')) returns contents of maxSizeMSER as a double
handles.imageProcessingParameters.setMaxSizeMSER(str2double(get(hObject,'String'))); % change the maxSizeMSER parameter
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function maxSizeMSER_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxSizeMSER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minSizeMSER_Callback(hObject, eventdata, handles)
% hObject    handle to minSizeMSER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minSizeMSER as text
%        str2double(get(hObject,'String')) returns contents of minSizeMSER as a double
handles.imageProcessingParameters.setMinSizeMSER(str2double(get(hObject,'String'))); % change the minSizeMSER parameter
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function minSizeMSER_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minSizeMSER (see GCBO)
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


function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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

% --- Executes when selected object is changed in uipanel31.
function uipanel31_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel31 
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
        handles.imageAnalyzer.setReferenceTimeMode('Choose time');
    case handles.firstPoint % in case the user wants to automatically set the experiment start time equal to the time the first image was taken
        %% Enable time shift and disable choosing start time
        handles.imageAnalyzer.setReferenceTimeMode('First point');
end


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


% --- Executes when selected object is changed in uipanel43.
function uipanel43_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel43 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.NewValue 
    case handles.observe
        handles.protocol.analysisMode = 'Observe';
    case handles.completedMeasurement
        handles.protocol.analysisMode = 'Completed';
end
guidata(hObject, handles);


% --- Executes when selected object is changed in uipanel45.
function uipanel45_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel45 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.NewValue
    case handles.brightField
        switch get(handles.uipanel31, 'SelectedObject') 
            case handles.fullImage
                handles.imageProcessingParameters.setFullImageMode(); % Analyze the whole image
            case handles.segmentedFullImage
                handles.imageProcessingParameters.setSegmentedFullImageMode(); % Analyze the whole image but in segments
            case handles.imageCenter
                handles.imageProcessingParameters.setImageCenterMode(); % Analyze only the center of the image
        end
    case handles.binary
        handles.imageProcessingParameters.setFromBinaryMode();
        set(handles.autoSaveBinaryImage, 'value', 0); % Don´t save binary files, they must already be there

        %% disable most of the panels that change parameters which change the way
        %% the bright-field images are analyzer but not how the binary images are
        %% analyzed
        set(handles.autoSaveBinaryImage, 'Enable', 'off');
        handles.imageProcessingParameters.setAutoSaveBinaryFiles('off');

        set(handles.observe, 'Enable', 'off');
        set(handles.merge, 'Enable', 'off');
        set(handles.noMerge, 'Enable', 'off');

        set(handles.tileDim, 'Enable', 'off');
        set(handles.lambda, 'Enable', 'off');
        set(handles.minSizeMSER, 'Enable', 'off');
        set(handles.maxSizeMSER, 'Enable', 'off');
        set(handles.maxEcc, 'Enable', 'off');
        set(handles.minSizeSplit, 'Enable', 'off');
        set(handles.maxSizeSplit, 'Enable', 'off');
        set(handles.maxVariation, 'Enable', 'off');

        set(handles.completedMeasurement, 'Value', 1);

        handles.analysisMode = 'Completed';   
        guidata(hObject, handles);
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
        set(handles.chooseTime, 'enable', 'off');
        set(handles.firstPoint, 'enable', 'off');
        handles.imageAnalyzer.setMeasurementTimeMode('Manual');
    case handles.averageOfCycle % user chooses to use one time value for each measurement that was performed during the same cycle
        %% disable choosing start time and enable some other options
        set(handles.firstPoint, 'enable', 'on');
        set(handles.chooseTime, 'enable', 'on');
        set(handles.firstPoint, 'value', 1);
        handles.imageAnalyzer.setMeasurementTimeMode('Cycle average');
        handles.imageAnalyzer.setReferenceTimeMode('First point');
    case handles.averageOfWell % user chooses to use one time value for each well
        %% disable choosing start time and enable some other options
        set(handles.firstPoint, 'enable', 'on');
        set(handles.chooseTime, 'enable', 'on');
        set(handles.firstPoint, 'value', 1);
        handles.imageAnalyzer.setMeasurementTimeMode('Well average');
        handles.imageAnalyzer.setReferenceTimeMode('First point');
end


% --- Executes during object creation, after setting all properties.
function timingProperties_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timingProperties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton34.
function pushbutton34_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newChannels = ChoosePredefinedChannels(handles.protocol.getNumberOfChannels());
set(handles.channels_Table, 'Data', newChannels);
guidata(hObject, handles);


% --- Executes on button press in pushbutton35.
function pushbutton35_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileChooser = FileChooser();
[fullFilePath, fileName] = fileChooser.chooseTemplateExcel();
formulaTable = ExcelProtocolInterface.xlsReadFormulae(fullFilePath);
handles.protocol.setTemplateTable(formulaTable);
singleExcelTable = SingleExcelTable();
singleExcelTable.setType('Template protocol');
singleExcelTable.createTableFromExperiment(handles.protocol);
cell = struct();
cell.row = 1;
cell.column = 1;
singleExcelTable.setPreferredCell(cell);
tableParameters = struct();
singleExcelTable.setTableParameters(tableParameters);
handles.ExcelProtocol.setTemplateTable(singleExcelTable);
handles.protocol.setExcelProtocol(handles.ExcelProtocol)
guidata(hObject, handles);
% --- Executes on button press in pushbutton36.
function pushbutton36_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton37.
function pushbutton37_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.protocol.apareciumExperimentInput.setHasChanged(1);


if ~handles.pipetingSimulatorHasBeenOpenedThisSession || handles.protocol.apareciumExperimentInput.hasChanged()
    handles.protocol.pipetingSimulatorInterface.addExperiment(handles.protocol.apareciumExperimentInput);
    handles.simPipetingHandle = handles.protocol.pipetingSimulatorInterface.generatePipetingSimulator(handles);
    handles.protocol.pipetingSimulatorInterface.regeneratePlateSimulatorFromTreatmentStructure(handles.protocol.treatmentStructure);
    handles.pipetingSimulatorHasBeenOpenedThisSession = 1;
else
    handles.simPipetingHandle = handles.protocol.pipetingSimulatorInterface.generatePipetingSimulator(handles);
    handles.protocol.pipetingSimulatorInterface.regeneratePlateSimulatorFromTreatmentStructure(handles.protocol.treatmentStructure);
end
    
handles = setUIModeToPipetingSim(handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton38.
function pushbutton38_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sequence = handles.protocol.pipetingSimulatorInterface.getPipetingSequence();
[name, path] = uiputfile({'.e1'}, 'Choose file location');
pipetingSequenceToE1(sequence, [path, name]);


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApareciumCommonImporterFunctions.figure1_ResizeFcn(hObject, eventdata, handles);
pos = get(hObject, 'Position');
try
    set(handles.simPipetingHandle, 'Position',[0,0, pos(3), pos(4)]);
    drawnow;
catch
     % plate simulator handle does not exist, no need for special resize 
end
guidata(hObject, handles)
