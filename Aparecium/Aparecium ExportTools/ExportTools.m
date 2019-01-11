function varargout = ExportTools(varargin)
% EXPORTTOOLS M-file for ExportTools.fig
%      EXPORTTOOLS, by itself, creates a new EXPORTTOOLS or raises the existing
%      singleton*.
%
%      H = EXPORTTOOLS returns the handle to a new EXPORTTOOLS or the handle to
%      the existing singleton*.
% 
%      EXPORTTOOLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPORTTOOLS.M with the given input
%      arguments.
%
%      EXPORTTOOLS('Property','Value',...) creates a new EXPORTTOOLS or
%      raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExportTools_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are passed to ExportTools_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExportTools

% Last Modified by GUIDE v2.5 14-Dec-2018 16:07:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExportTools_OpeningFcn, ...
                   'gui_OutputFcn',  @ExportTools_OutputFcn, ...
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


% --- Executes just before ExportTools is made visible.
function ExportTools_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ExportTools (see VARARGIN)

% Choose default command line output for ExportTools
handles.output = hObject;
handles.apareciumExperimentInput = ApareciumExperimentInput();
handles.plateSimulatorInterface = PlateSimulatorInterface();

handles.activeFormula = [];
handles.excelTableConfiguration = 1;
handles.originalChannels = [];
handles.loadingBar = loadingBar();
%try
    handles.midasTableController = varargin{1};
    handles = MidasToApareciumExperimentInput(handles.midasTableController, handles);
    handles.exportTimeMomentController = ExportTimeMomentController(handles.apareciumExperimentInput);
    handles.exportTimeMomentController.setCycleListHandle(handles.timeRemoval);
    handles.exportTimeMomentController.setOutputTimeUnitDrowdownHandle(handles.outputTimeUnitDropdown);
%catch
    %warndlg('Error loading MIDAS file to export tools. Check if the file is in correct format or consult with Aparecium developers.');
%end

handles.numberOfGroups = 1;
groupNameTable_CellEditCallback(hObject, eventdata, handles);
handles.previewTabGroup = [];
handles.previewTabGroup = createTabs(hObject, handles);
handles.excelTable = createTable(handles.ExcelTablePanel, {}, zeros(0,0), 'Buttons', 'off', 'Visible', 'on');
setAutoResizeOff(handles.excelTable);
handles.excelTableController = ExcelTableController();
handles.excelTableController.setTableHandle(handles.excelTable);

handles.SBExporter = SBToolboxExporter();
handles.SBExporter.addLoadingBar(handles.loadingBar);
handles.SBExporter.setExperimentParamNameTable(handles.parameterNameTable);
handles.SBTable = createTable(handles.SBTablePanel, {}, zeros(0,0), 'Buttons', 'off', 'Visible', 'off');
handles.SBExporter.setTableHandle(handles.SBTable);
handles.SBCalcMode = 'Average';

handles.graphicalPreviewController.setXAxisChoosingDropdownHandle(handles.graphXAxisChooser);
handles.graphicalPreviewController.setGraphFormatDropdownHandle(handles.graphFormatChooser);
handles.graphicalPreviewController.setGroupDropdownHandle(handles.chooseGraphGroup);
handles.graphicalPreviewController.setTrisurfCheckbox(handles.trisurfCheckbox);
handles.graphicalPreviewController.setPointsSurfaceCheckbox(handles.pointsSurfaceCheckbox);
handles.graphicalPreviewController.setAxisMinMaxBoxes(handles.XAxisUpperBound, handles.XAxisLowerBound, handles.YAxisUpperBound, handles.YAxisLowerBound, handles.ZAxisUpperBound, handles.ZAxisLowerBound);

handles.copasiPreviewController = CopasiPanelController();
handles.copasiPreviewController.setExperimentParamNameTable(handles.copasiParameterNameTable);
handles.CopasiTable = createTable(handles.CopasiTablePanel, {}, zeros(0,0), 'Buttons', 'off', 'Visible', 'off');
handles.copasiPreviewController.setTableHandle(handles.CopasiTable);
handles.copasiCalcMode = 'Average';

handles.prismPanelController = PrismPanelController();
handles.prismPanelController.setXAxisChoosingDropdownHandle(handles.PrismXAxisTreatmentSelection);
handles.prismPanelController.setTableOrganizationHandle(handles.PrismOrganizationStyle);
handles.PrismTable = createTable(handles.PrismTablePanel, {}, zeros(0,0), 'Buttons', 'off', 'Visible', 'off');
handles.PrismHeaderTable = createTable(handles.PrismHeaderTablePanel, {}, zeros(0,0), 'Buttons', 'off', 'Visible', 'off');
setAutoResizeOff(handles.PrismTable);
setAutoResizeOff(handles.PrismHeaderTable);
handles.prismPanelController.setTableHandle(handles.PrismTable);
handles.prismPanelController.setHeaderTableHandle(handles.PrismHeaderTable);

try
    handles.SBExporter.addTimeController(handles.exportTimeMomentController);
catch
    disp('Error')
end

handles.excelTableController.setXAxisChoosingDropdownHandle(handles.xAxisTreatmentSelection);
handles.excelTableController.setTableOrganizationHandle(handles.organizationStyle);
try
    handles.excelTableController.addTimeController(handles.exportTimeMomentController);
    handles.SBExporter.addTimeController(handles.exportTimeMomentController);
    handles.graphicalPreviewController.addTimeController(handles.exportTimeMomentController);
    handles.copasiPreviewController.addTimeController(handles.exportTimeMomentController);
    handles.prismPanelController.addTimeController(handles.exportTimeMomentController);
catch
    disp('Error');
end
handles.loadingBar.devizualize();
set(handles.removeEmptyRows, 'Value', handles.excelTableController.removeEmptyRows);
if isequal(numel(varargin), 2)
    if strcmp(varargin{2}, 'Protocol Generator')
       handles.mode = 'Protocol Generator'; 
    else
       handles.mode = 'MIDAS export';
    end
    
elseif isequal(numel(varargin), 3)
    if strcmp(varargin{3}, 'Edit protocol')
       handles.mode = 'Edit protocol';
    end
else
    handles.mode = 'MIDAS export';
end

switch handles.mode
    case 'Protocol Generator'
        set(handles.exportNameText, 'visible', 'on');
        set(handles.exportName, 'visible', 'on');
        set(handles.saveThisExport, 'visible', 'on');
        set(handles.exportName, 'String', 'Export1');
        set(handles.excelOrPrism, 'Visible', 'on');
        handles.output = [];
        guidata(hObject, handles);
        uiwait(handles.figure1);
    case 'Edit protocol'
        set(handles.exportNameText, 'visible', 'on');
        set(handles.exportName, 'visible', 'on');
        set(handles.saveThisExport, 'visible', 'on');
        set(handles.exportName, 'String', 'Export1');
        set(handles.excelOrPrism, 'Visible', 'on');
        handles.output = [];
        handles.exportToEdit = varargin{2};
        handles = updateGUIToPreviousExport(handles, handles.figure1);
        guidata(hObject, handles);
        uiwait(handles.figure1);
    case 'MIDAS export'
      guidata(hObject, handles);
      set(handles.excelOrPrism, 'Visible', 'off');   
end

handles = initializeShowBlank(handles);
handles.calculationMethod = CalculationMethod();

guidata(hObject, handles);

% UIWAIT makes ExportTools wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ExportTools_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
switch handles.mode
    case 'Protocol Generator'
        delete(handles.figure1);
    case 'Edit protocol'
        delete(handles.figure1);
    case 'MIDAS export'
end

function handles = initializeShowBlank(handles)
if isdeployed
    load([pwd, '\', 'settings.mat']);
else
    load settings
end
set(handles.showBlank, 'Value', settings.showBlank);
if settings.showBlank
   subgroupStartValue = 1; 
else
   subgroupStartValue = 2;
end
handles.excelTableController.setSubgroupStartValue(subgroupStartValue);
handles.SBExporter.setSubgroupStartValue(subgroupStartValue);
handles.graphicalPreviewController.setSubgroupStartValue(subgroupStartValue);
handles.copasiPreviewController.setSubgroupStartValue(subgroupStartValue);
handles.prismPanelController.setSubgroupStartValue(subgroupStartValue);

function setAutoResizeOff(table)
jtable = table.getTable;
jtable.setAutoResizeMode(jtable.AUTO_RESIZE_OFF)

function handles = updateGUIToPreviousExport(handles, figure)
set(handles.exportName, 'String', handles.exportToEdit.exportName);
set(handles.groupNameTable, 'Data', handles.exportToEdit.getGroupNames());
groupNameTable_CellEditCallback(handles.figure1, [], handles);
handles.plateSimulatorInterface.addExperiment(handles.apareciumExperimentInput);
handles.simPlateHandle = handles.plateSimulatorInterface.generatePlateSimulator(handles);

groupStructure = handles.exportToEdit.getGroupStructure();
sharedBlankStructure = handles.exportToEdit.getSharedBlankStructure();
subgroupNames = handles.exportToEdit.getSubgroupNames();
timewiseBlankStructure = handles.exportToEdit.getSubgroupNames();
alignment = handles.exportToEdit.getTimwiseBlankAlignment();
handles.plateSimulatorInterface.regeneratePlateSimulatorFromGroupStructure(groupStructure, subgroupNames, sharedBlankStructure, timewiseBlankStructure, alignment);
calculationMethod = handles.exportToEdit.getCalculationMethod();
handles.activeFormula = calculationMethod.getFormulae();
updateFormulaList(handles);

handles.excelTableController.addExperiment(handles.apareciumExperimentInput);
handles.excelTableController.addSharedBlankStructure(sharedBlankStructure);
handles.excelTableController.addSubgroupNames(subgroupNames);
handles.excelTableController.addGroupStructure(groupStructure);

handles.SBExporter.addExperiment(handles.apareciumExperimentInput);
handles.SBExporter.addSharedBlankStructure(sharedBlankStructure);
handles.SBExporter.addSubgroupNames(subgroupNames);
handles.SBExporter.addGroupStructure(groupStructure);

handles.graphicalPreviewController.addExperiment(handles.apareciumExperimentInput);
handles.graphicalPreviewController.addSharedBlankStructure(sharedBlankStructure);
handles.graphicalPreviewController.addSubgroupNames(subgroupNames);
handles.graphicalPreviewController.addGroupStructure(groupStructure);

set(handles.chooseGraphGroup, 'String', handles.apareciumExperimentInput.getGroups());

switch handles.exportToEdit.exportType
    case handles.exportToEdit.excel
        set(handles.previewTabGroup, 'SelectedIndex', 1);
        
        contents = get(handles.tableConfigurationChooser, 'String');
        tableType = handles.exportToEdit.tableType;
        set(handles.tableConfigurationChooser, 'Value', findStringFromCellArray(contents, tableType)); 
        switch findStringFromCellArray(contents, tableType)
            case 1
                handles.excelTableConfiguration = 1;
                set(handles.xAxisTreatmentSelection, 'enable', 'off');
                set(handles.removeEmptyRows, 'enable', 'on'); 
            case 2
                handles.excelTableConfiguration = 2;
                set(handles.xAxisTreatmentSelection, 'enable', 'on');
                set(handles.removeEmptyRows, 'enable', 'off'); 
        end
        contents = get(handles.xAxisTreatmentSelection, 'String');
        xAxisTypeTable = handles.exportToEdit.xAxisTypeTable;
        set(handles.xAxisTreatmentSelection, 'Value', findStringFromCellArray(contents, xAxisTypeTable)); 

        switch handles.exportToEdit.tableOrganizationStyle
            case handles.exportToEdit.organizationStyleGroups
                set(handles.organizationStyle,'Value', 1);
            case handles.exportToEdit.organizationStyleSubgroups
                set(handles.organizationStyle,'Value', 2);
        end
        
        switch handles.exportToEdit.excelOrPrism
            case handles.exportToEdit.excel
                set(handles.excelOrPrism, 'SelectedObject', handles.autoExportToExcel);
            case handles.exportToEdit.prism
                set(handles.excelOrPrism, 'SelectedObject', handles.autoExportToPrism);
        end
        
    case handles.exportToEdit.SB
        set(handles.previewTabGroup, 'SelectedIndex', 2);
        set(handles.parameterNameTable, 'Data', handles.exportToEdit.variableNames);
        parameterNameTable_CellEditCallback(handles.parameterNameTable, [], handles);
        switch handles.exportToEdit.fastKineticsExportMethod
            case handles.exportToEdit.merge
               set(handles.mergeSB, 'Value', 1); 
            case handles.exportToEdit.average
               set(handles.mergeSB, 'Value', 0);
        end
        
    case handles.exportToEdit.figure
        set(handles.previewTabGroup, 'SelectedIndex', 3);
        switch handles.exportToEdit.graphFormat
            case handles.exportToEdit.timeDependant
                set(handles.graphFormatChooser, 'Value', 1);
            case handles.exportToEdit.concentrationDependant
                set(handles.graphFormatChooser, 'Value', 2);
            case handles.exportToEdit.threeD
                set(handles.graphFormatChooser, 'Value', 3);
        end
        contents = get(handles.graphXAxisChooser, 'String');
        xAxisTypeFigure = handles.exportToEdit.xAxisTypeFigure;
        set(handles.graphXAxisChooser, 'Value', findStringFromCellArray(contents, xAxisTypeFigure));
        contents = get(handles.chooseGraphGroup, 'String');
        activeGroup = handles.exportToEdit.activeGroup;
        set(handles.chooseGraphGroup, 'Value', findStringFromCellArray(contents, activeGroup));
        set(handles.pointsSurfaceCheckbox, 'Value', handles.exportToEdit.points);
        set(handles.trisurfCheckBox, 'Value', handles.exportToEdit.surface);
end
simPlateDone_Callback(handles.figure1, [], handles);

set(handles.saveThisExport, 'String', 'Save changes and close');
contents = get(handles.outputTimeUnitDropdown, 'String');
set(handles.outputTimeUnitDropdown, 'Value', findStringFromCellArray(contents, handles.exportToEdit.getTimeUnit()));
applyFormula_Callback(handles.figure1, [], handles);
guidata(handles.figure1, handles);



function previewTabGroup = createTabs(hObject, handles)
try
    previewTabGroup = uitabgroup('v0','Parent', handles.exportPreviewPanel);
    tab1 = uitab('v0','Parent', previewTabGroup, 'Title', 'Excel preview', 'Tag', 'ExcelPreview');
    tab2 = uitab('v0','Parent', previewTabGroup, 'Title', 'SBtoolbox preview', 'Tag', 'SBPreview');
    tab3 = uitab('v0','Parent', previewTabGroup, 'Title', 'Graphical preview', 'Tag', 'GraphicalPreview');
    tab4 = uitab('v0','Parent', previewTabGroup, 'Title', 'COPASI Preview', 'Tag', 'CopasiPreview');
    tab5 = uitab('v0','Parent', previewTabGroup, 'Title', 'Prism Preview', 'Tag', 'PrismPreview');
catch
    previewTabGroup = uitabgroup('Parent', handles.exportPreviewPanel);
    tab1 = uitab('Parent', previewTabGroup, 'Title', 'Excel preview', 'Tag', 'ExcelPreview');
    tab2 = uitab('Parent', previewTabGroup, 'Title', 'SBtoolbox preview', 'Tag', 'SBPreview');
    tab3 = uitab('Parent', previewTabGroup, 'Title', 'Graphical preview', 'Tag', 'GraphicalPreview');
    tab4 = uitab('Parent', previewTabGroup, 'Title', 'COPASI Preview', 'Tag', 'CopasiPreview');
    tab5 = uitab('Parent', previewTabGroup, 'Title', 'Prism Preview', 'Tag', 'PrismPreview');
end
previewTabGroup.SelectionChangedFcn = @tabChangeListener;
try
    set(previewTabGroup, 'BackgroundColor', [225/255 226/255 251/255]);
catch MException
    if strcmp(MException.message, 'There is no BackgroundColor property on the TabGroup class.')
        tabs = {tab1, tab2, tab3, tab4, tab5};
        for i = 1 : numel(tabs)
            tabs{i}.BackgroundColor = [225/255 226/255 251/255];
        end
    else
        error(MException.message);
    end    
end
set(handles.excelPreviewPanel, 'Parent', tab1);
set(handles.SBtoolboxPreviewPanel, 'Parent', tab2);
set(handles.graphicalPreview, 'Parent', tab3);
set(handles.COPASIPreviewPanel, 'Parent', tab4);
set(handles.PrismPreviewPanel, 'Parent', tab5);
guidata(hObject, handles);



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.plateSimulatorInterface.addExperiment(handles.apareciumExperimentInput);
handles.simPlateHandle = handles.plateSimulatorInterface.generatePlateSimulator(handles);
plate = handles.plateSimulatorInterface.PlateSimulator.getMicroPlate();
concentrations = handles.apareciumExperimentInput.getConcentrationsAtEvents();
%concentrations = reshape(concentrations, size(concentrations, 1), size(concentrations, 2) , size(concentrations, 4));
concentrations = permute(concentrations, [3 2 1 4]); %time, columns, rows, treatment
plate.treatWellsWithPredefinedTreatments(concentrations);
setUIModeToPlateSim(hObject, handles);
figure1_ResizeFcn(handles.figure1, [], handles);
guidata(hObject, handles);

function handles = setUIModeToPlateSim(hObject, handles)

set(handles.groupWellsPanel, 'visible', 'off');
set(handles.generalSettingsPanel, 'visible', 'off');
set(handles.excelPreviewPanel, 'visible', 'off');
set(handles.SBtoolboxPreviewPanel, 'visible', 'off');
set(handles.exportPreviewPanel, 'visible', 'off');
set(handles.previewTabGroup, 'visible', 'off');
set(handles.figure1, 'Color', 'white');
doneCallbackHandle = @simPlateDone_Callback;
doneHandler(handles.plateSimulatorInterface.getPlateSimulator().getDoneButton(), handles, doneCallbackHandle);
guidata(hObject, handles);
% --- Executes on selection change in formulaListBox.
function formulaListBox_Callback(hObject, eventdata, handles)
% hObject    handle to formulaListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns formulaListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from formulaListBox
updateFormulaList(handles);
% --- Executes during object creation, after setting all properties.
function formulaListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to formulaListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'max',2);% this option allows selection of multiple formulas
guidata(hObject, handles);


% --- Executes on button press in TFI.
function TFI_Callback(hObject, eventdata, handles)
% hObject    handle to TFI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.activeFormula{end+1}.acronyme = 'TFI';
updateFormulaList(handles);
guidata(hObject, handles);

function handles = updateFormulaList( handles)

channelNames = handles.apareciumExperimentInput.getChannelNames();
for formulaIndex = 1 : numel(handles.activeFormula)
    channelNames = [GetFunctionOutputArguments(channelNames, handles.activeFormula{formulaIndex}.acronyme), channelNames];  
end
set(handles.SBIncludedMeasurements, 'String', channelNames);

activeFormulaAcronymes{1} = '';%in case there are no formulae
for formulaIndex = 1 : numel(handles.activeFormula)
   activeFormulaAcronymes{formulaIndex} = handles.activeFormula{formulaIndex}.acronyme;
end

set(handles.formulaListBox, 'String', activeFormulaAcronymes);
[warnMsg, warnId] = lastwarn;
if strcmp(warnId, 'MATLAB:hg:uicontrol:ValueMustBeWithinStringRange')
    set(handles.SBIncludedMeasurements, 'Value', 1);
end


selectedLines = get(handles.formulaListBox, 'Value');
contents = get(handles.formulaListBox, 'String');
if isequal(numel(selectedLines), 1) 
    if ~isempty(contents{selectedLines(1)})
        if isfield(handles.activeFormula{selectedLines}, 'formula')
            set(handles.editFormula, 'Enable', 'on');
        else
            set(handles.editFormula, 'Enable', 'off');
        end
        set(handles.deleteSelectedLines, 'Enable', 'on');
    else
        set(handles.deleteSelectedLines, 'Enable', 'off');
        set(handles.editFormula, 'Enable', 'off');
    end
else
    set(handles.editFormula, 'Enable', 'off')
end
if ~isequal(handles.activeFormula, [])
    set(handles.applyFormula, 'Enable', 'on');
else
    set(handles.applyFormula, 'Enable', 'off');
end
guidata(handles.formulaListBox, handles);
% --- Executes on button press in FA.
function FA_Callback(hObject, eventdata, handles)
% hObject    handle to FA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.activeFormula{end+1}.acronyme = 'FA';
updateFormulaList(handles);
guidata(hObject, handles);


% --- Executes on button press in blankCorrection.
function blankCorrection_Callback(hObject, eventdata, handles)
% hObject    handle to blankCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.activeFormula{end+1}.acronyme = 'Blank correct';
updateFormulaList(handles);
guidata(hObject, handles);

% --- Executes on button press in timewiseBlankCorrection.
function timewiseBlankCorrection_Callback(hObject, eventdata, handles)
% hObject    handle to timewiseBlankCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.activeFormula{end+1}.acronyme = 'Timewise blank correction';
updateFormulaList(handles);
guidata(hObject, handles);

% --- Executes on button press in customFormula.
function customFormula_Callback(hObject, eventdata, handles)
% hObject    handle to customFormula (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
channelNames = handles.apareciumExperimentInput.getChannelNames();
acronyme = '';
for formulaIndex = 1 : numel(handles.activeFormula)
    channelNames = [GetFunctionOutputArguments(channelNames, handles.activeFormula{formulaIndex}.acronyme), channelNames];  
end
[formula, acronyme] = calc(channelNames);
if isequal(strcmp(formula, ''), 0) && isequal(strcmp(acronyme, ''), 0) 
    handles.activeFormula{end + 1}.acronyme = acronyme{1};
    handles.activeFormula{end}.formula = formula;
    updateFormulaList(handles);
end
guidata(hObject, handles);

% --- Executes on button press in loadFormulaFile.
function loadFormulaFile_Callback(hObject, eventdata, handles)
% hObject    handle to loadFormulaFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileChooser = FileChooser;
[fileName, filePath] = fileChooser.chooseFCFFile();
load([filePath, fileName], 'activeFormula', 'channelNames');
if exist('activeFormula', 'var') && exist('channelNames', 'var')
    try
        channelNames = removeRedundantChannels(channelNames, activeFormula{1}.formula);
    catch MException
        if strcmp(MException.message,'Reference to non-existent field ''formula''.')
            % its ok, first formula is blank 
        else
           % add throw error code here 
        end
        
    end
    if isequal(channelNames, handles.apareciumExperimentInput.getChannelNames());
        handles.activeFormula = activeFormula;
        updateFormulaList(handles);
    else
        if(numel(channelNames) > numel(handles.apareciumExperimentInput.getChannelNames()))
            errordlg('This formula is not suitable for the data. More variables are present in formula than in the data. Formula not loaded.','Unsuitable formula');
        else
            newFormulaChannels = ChooseChannelConsistency(handles.apareciumExperimentInput.getChannelNames(), channelNames);
        end
        if isequal(newFormulaChannels, '')
            
        else
            if isequal(handles.originalChannels, []); 
                handles.originalChannels = handles.apareciumExperimentInput.getChannelNames();
                set(handles.toOriginalChannels, 'Enable', 'on');                
            end
            handles.apareciumExperimentInput.setChannelNames(newFormulaChannels);
            handles.activeFormula = activeFormula;
            updateFormulaList(handles);
        end
    end
else
   warndlg('It seems that this .mat file is not in the correct format. Formula not loaded.') 
end

guidata(hObject, handles);


% --- Executes on button press in choosePrefabFormula.
function choosePrefabFormula_Callback(hObject, eventdata, handles)
% hObject    handle to choosePrefabFormula (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
acronyme = listOfFormulae.chooseBuiltInFormula();
handles.activeFormula{end + 1}.acronyme = acronyme;
updateFormulaList(handles);
guidata(hObject, handles);
% --- Executes on button press in exportToExcel.
function exportToExcel_Callback(hObject, eventdata, handles)
% hObject    handle to exportToExcel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.excelTableController.exportWithDialogue();

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.excelTableController.exportToPZFX();


function numberOfGroupsField_Callback(hObject, eventdata, handles)
% hObject    handle to numberOfGroupsField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numberOfGroupsField as text
%        str2double(get(hObject,'String')) returns contents of numberOfGroupsField as a double
numberOfGroups = get(hObject,'String');
handles = changeNumberOfGroups(handles, numberOfGroups);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function numberOfGroupsField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numberOfGroupsField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function groupWellsPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to groupWellsPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function groupNameTable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to groupNameTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Data', {'A'});
guidata(hObject, handles);


% --- Executes on button press in simPlateDone.
function simPlateDone_Callback(hObject, eventdata, handles)
% hObject    handle to simPlateDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.groupWellsPanel, 'visible', 'on');
set(handles.generalSettingsPanel, 'visible', 'on');
set(handles.excelPreviewPanel, 'visible', 'on');
set(handles.SBtoolboxPreviewPanel, 'visible', 'on');
set(handles.exportPreviewPanel, 'visible', 'on');
set(handles.previewTabGroup, 'visible', 'on');
set(handles.simPlateHandle, 'visible', 'off');
set(handles.figure1, 'Color', [225/255, 226/255, 251/255]);
groupStructure = handles.plateSimulatorInterface.getGroupStructure();
sharedBlankStructure = handles.plateSimulatorInterface.getSharedBlankStructure();
subgroupNames = handles.plateSimulatorInterface.getSubgroupNames();
subgroupNames = reshapeSubgroupNames(groupStructure, subgroupNames, sharedBlankStructure);
timewiseBlankStructure = handles.plateSimulatorInterface.getTimewiseBlankStructure();
[blanksArePresent, timewiseBlanksArePresent] = checkIfBlanksArePresent(groupStructure, sharedBlankStructure, timewiseBlankStructure);
if blanksArePresent
    set(handles.showBlank, 'Enable', 'on');
elseif ~blanksArePresent
    set(handles.showBlank, 'Value', 0);
    set(handles.showBlank, 'Enable', 'off');
end
showBlank_Callback(handles.showBlank, [], handles);

controllers{1} = handles.excelTableController;
controllers{2} = handles.SBExporter;
controllers{3} = handles.graphicalPreviewController;
controllers{4} = handles.copasiPreviewController;
controllers{5} = handles.prismPanelController;

addParametersToControllers(controllers, handles.apareciumExperimentInput, groupStructure, subgroupNames, sharedBlankStructure, timewiseBlankStructure, handles.excelTableConfiguration)

set(handles.groupsOKIndicator, 'String', 'OK', 'BackgroundColor', [0 1 0]);
set(handles.savePlateKonfig, 'Enable', 'on');
handles.activeFormula
if ~isequal(handles.activeFormula, [])
    set(handles.applyFormula, 'Enable', 'on');
else
    set(handles.applyFormula, 'Enable', 'off');
end
set(handles.chooseGraphGroup, 'String', handles.apareciumExperimentInput.getGroups());
guidata(handles.figure1, handles);

function [blanksArePresent, timewiseBlanksArePresent] = checkIfBlanksArePresent(groupStructure, sharedBlankStructure, timewiseBlankStructure)
blanksArePresent = 0;
timewiseBlanksArePresent = 0;

if sum(sum(sum(sharedBlankStructure))) > 0 || sum(sum(groupStructure(:,:,2) == 0)) > 0
    blanksArePresent = 1;
end

if sum(sum(sum(timewiseBlankStructure))) > 0
    timewiseBlanksArePresent = 1;
end




function addParametersToControllers(controllers, experiment, groupStructure, subgroupNames, sharedBlankStructure, timewiseBlankStructure, excelTableConfiguration)
if isequal(excelTableConfiguration, 1)
    mode = 'kinetics';
else
    mode = 'concentrations';
end


for index = 1 : numel(controllers)
   controllers{index}.addExperiment(experiment, mode);
   controllers{index}.addGroupStructure(groupStructure);
   controllers{index}.addSubgroupNames(subgroupNames);
   controllers{index}.addSharedBlankStructure(sharedBlankStructure);
   controllers{index}.addTimewiseBlankStructure(timewiseBlankStructure);
end

% --- Executes when entered data in editable cell(s) in groupNameTable.
function groupNameTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to groupNameTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.groupNameTable, 'data');
handles.apareciumExperimentInput.setGroups(data);
guidata(hObject, handles);


% --- Executes on button press in applyFormula.
function applyFormula_Callback(hObject, eventdata, handles)
% hObject    handle to applyFormula (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%handles.calculationMethod = CalculationMethod();
if get(handles.showBlank, 'Value')
    subgroupStartValue = 1;
else
    subgroupStartValue = 2;
end

handles.calculationMethod.setSubgroupStartValue(subgroupStartValue);
handles.calculationMethod.addFormulae(handles.activeFormula);
handles.excelTableController.setCalculationMethod(handles.calculationMethod);
handles.excelTableController.calculateNewTable(handles.excelTableConfiguration);

set(handles.tableConfigurationChooser, 'enable', 'on');

%calculationMethod.addFormulae(handles.activeFormula);
handles.SBExporter.setCalculationMethod(handles.calculationMethod);

possibleVariables = get(handles.SBIncludedMeasurements, 'String');
chosenVariables = get(handles.SBIncludedMeasurements, 'Value');
outputVariables = possibleVariables(chosenVariables);

handles.SBExporter.calculateNewTable(handles.SBCalcMode, outputVariables);
set(handles.chooseSBGroup, 'String', handles.apareciumExperimentInput.getGroups());
handles.SBExporter.showTableData(1, 2);
subgroupNames = handles.SBExporter.getSubgroupNamesOfGroup(1);
set(handles.chooseSBSubgroup, 'String', subgroupNames);
set(handles.chooseSBSubgroup, 'Value', 1);

set(handles.graphFormatChooser, 'enable', 'on');
set(handles.chooseGraphGroup, 'enable', 'on');

handles.graphicalPreviewController.setCalculationMethod(handles.calculationMethod);
handles.graphicalPreviewController.calculateNewGraph();

% apply formula to copasiPanelController
handles.copasiPreviewController.setCalculationMethod(handles.calculationMethod);
handles.copasiPreviewController.calculateNewTable(handles.SBCalcMode, handles.activeFormula{end}.acronyme); %% TODO - change to handles.CopasiCalcMode

handles.prismPanelController.setCalculationMethod(handles.calculationMethod);
handles.prismPanelController.calculateNewTable(handles.excelTableConfiguration);

guidata(hObject, handles);

function applyFormulaToExcelPreview(hObject, eventdata, handles)


%calculationMethod = CalculationMethod();
if get(handles.showBlank, 'Value')
    subgroupStartValue = 1;
else
    subgroupStartValue = 2;
end
handles.calculationMethod.setSubgroupStartValue(subgroupStartValue);
handles.calculationMethod.addFormulae(handles.activeFormula);
handles.excelTableController.setCalculationMethod(handles.calculationMethod);
handles.excelTableController.calculateNewTable(handles.excelTableConfiguration);
set(handles.tableConfigurationChooser, 'enable', 'on');
set(handles.chooseSBGroup, 'String', handles.apareciumExperimentInput.getGroups());
guidata(hObject, handles);

function applyFormulaToGraph(hObject, eventdata, handles)
set(handles.graphFormatChooser, 'enable', 'on');
set(handles.chooseGraphGroup, 'enable', 'on');
%calculationMethod = CalculationMethod();
if get(handles.showBlank, 'Value')
    subgroupStartValue = 1;
else
    subgroupStartValue = 2;
end

handles.calculationMethod.setSubgroupStartValue(subgroupStartValue);
handles.calculationMethod.addFormulae(handles.activeFormula);
handles.graphicalPreviewController.setCalculationMethod(handles.calculationMethod);
handles.graphicalPreviewController.calculateNewGraph();
guidata(hObject, handles);

function applyFormulaToSBToolboxPreview(hObject, eventdata, handles)
%calculationMethod = CalculationMethod();
if get(handles.showBlank, 'Value')
    subgroupStartValue = 1;
else
    subgroupStartValue = 2;
end

handles.calculationMethod.setSubgroupStartValue(subgroupStartValue);
handles.calculationMethod.addFormulae(handles.activeFormula);

handles.SBExporter.setCalculationMethod(handles.calculationMethod);

possibleVariables = get(handles.SBIncludedMeasurements, 'String');
chosenVariables = get(handles.SBIncludedMeasurements, 'Value');
outputVariables = possibleVariables(chosenVariables);

handles.SBExporter.calculateNewTable(handles.SBCalcMode, outputVariables);
set(handles.chooseSBGroup, 'String', handles.apareciumExperimentInput.getGroups());
handles.SBExporter.showTableData(1, 2);
subgroupNames = handles.SBExporter.getSubgroupNamesOfGroup(1);
set(handles.chooseSBSubgroup, 'String', subgroupNames);
set(handles.chooseSBSubgroup, 'Value', 1);
guidata(hObject, handles)

% --- Executes on button press in deleteSelectedLines.
function deleteSelectedLines_Callback(hObject, eventdata, handles)
% hObject    handle to deleteSelectedLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectedLines = get(handles.formulaListBox, 'Value');
% handles.activeFormula(min(selectedLines) : end) = []; % Delete all lines after first selected line, since later functions might lose their arguments that way.
% this option should be considered, when it can´t be guaranteed that number of function inputs and outputs fit together  
handles.activeFormula(selectedLines) = [];
if(isempty(handles.activeFormula))
    handles.activeFormula = [];
end
set(handles.formulaListBox, 'Value', 1);
updateFormulaList(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function excelTable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to excelTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

guidata(hObject, handles);


% --- Executes on selection change in tableConfigurationChooser.
function tableConfigurationChooser_Callback(hObject, eventdata, handles)
% hObject    handle to tableConfigurationChooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns tableConfigurationChooser contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tableConfigurationChooser
handles.excelTableConfiguration = get(hObject,'Value');
if isequal(handles.excelTableConfiguration, 1)
    set(handles.xAxisTreatmentSelection, 'enable', 'on');
    set(handles.removeEmptyRows, 'enable', 'on');
    handles.excelTableController.setXAxisChoosingDropdownMode('kinetics');
    set(handles.xAxisTreatmentSelection, 'Value', 2);
elseif isequal(handles.excelTableConfiguration, 2)
    set(handles.xAxisTreatmentSelection, 'enable', 'on');
    set(handles.removeEmptyRows, 'enable', 'off');
    set(handles.text16, 'String', 'Choose treatment');
    handles.excelTableController.setXAxisChoosingDropdownMode('concentrations');
    set(handles.xAxisTreatmentSelection, 'Value', 3);
end
applyFormulaToExcelPreview(hObject, eventdata, handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function tableConfigurationChooser_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tableConfigurationChooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function exportPreviewPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exportPreviewPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in timeRemoval.
function timeRemoval_Callback(hObject, eventdata, handles)
% hObject    handle to timeRemoval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns timeRemoval contents as cell array
%        contents{get(hObject,'Value')} returns selected item from timeRemoval


% --- Executes during object creation, after setting all properties.
function timeRemoval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeRemoval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'max', 2)% this allows selection of multiple lines
guidata(hObject, handles);


% --- Executes on button press in removeTimepoints.
function removeTimepoints_Callback(hObject, eventdata, handles)
% hObject    handle to removeTimepoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.exportTimeMomentController.removeSelectedCycles();
applyFormula_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes on selection change in chooseSBGroup.
function chooseSBGroup_Callback(hObject, eventdata, handles)
% hObject    handle to chooseSBGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns chooseSBGroup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chooseSBGroup
group = get(hObject,'Value');
subgroupNames = handles.SBExporter.getSubgroupNamesOfGroup(group);
subgroups = handles.SBExporter.getSubgroupsOfGroup(group);
set(handles.chooseSBSubgroup, 'String', subgroupNames);
set(handles.chooseSBSubgroup, 'Value', 1);
handles.SBExporter.showTableData(group, subgroups{1});
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function chooseSBGroup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseSBGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when entered data in editable cell(s) in parameterNameTable.
function parameterNameTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to parameterNameTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
handles.SBExporter.getNewExperimentParamsNames();
handles.SBExporter.getNewExperimentStateOrParam();
handles.SBExporter.getNewExperimentIncludes();
guidata(hObject, handles);


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

% --- Executes on selection change in xAxisTreatmentSelection.
function xAxisTreatmentSelection_Callback(hObject, eventdata, handles)
% hObject    handle to xAxisTreatmentSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns xAxisTreatmentSelection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from xAxisTreatmentSelection
applyFormulaToExcelPreview(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function xAxisTreatmentSelection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xAxisTreatmentSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject, 'enable', 'on');
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);


% --- Executes on selection change in chooseSBSubgroup.
function chooseSBSubgroup_Callback(hObject, eventdata, handles)
% hObject    handle to chooseSBSubgroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns chooseSBSubgroup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chooseSBSubgroup
group = get(handles.chooseSBGroup, 'Value');
subgroups = handles.SBExporter.getSubgroupsOfGroup(group);
subgroup = subgroups{get(hObject,'Value')}; 
handles.SBExporter.showTableData(group, subgroup);

% --- Executes during object creation, after setting all properties.
function chooseSBSubgroup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseSBSubgroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in resetTimeMoments.
function resetTimeMoments_Callback(hObject, eventdata, handles)
% hObject    handle to resetTimeMoments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.exportTimeMomentController.resetToExperiment();
set(handles.outputTimeUnitDropdown, 'Value', 2); 
applyFormula_Callback(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes on button press in exportSBTable.
function exportSBTable_Callback(hObject, eventdata, handles)
% hObject    handle to exportSBTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
applyFormulaToSBToolboxPreview(hObject, eventdata, handles);
handles.SBExporter.exportWithDialogue();

% --- Executes on button press in exportAsSBProject.
function exportAsSBProject_Callback(hObject, eventdata, handles)
% hObject    handle to exportAsSBProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------


% --------------------------------------------------------------------
function activex1_Click(hObject, eventdata, handles)
% hObject    handle to activex1 (see GCBO)
% eventdata  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in outputTimeUnitDropdown.
function outputTimeUnitDropdown_Callback(hObject, eventdata, handles)
% hObject    handle to outputTimeUnitDropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns outputTimeUnitDropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from outputTimeUnitDropdown
contents = get(hObject,'String');
unit = contents{get(hObject,'Value')};
handles.exportTimeMomentController.setTimeUnit(unit);
applyFormula_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function outputTimeUnitDropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputTimeUnitDropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'Value', 2);
guidata(hObject, handles);


% --- Executes on button press in mergeSB.
function mergeSB_Callback(hObject, eventdata, handles)
% hObject    handle to mergeSB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mergeSB
handles.SBCalcMode = 'Merge';
guidata(hObject, handles);
applyFormula_Callback(hObject, eventdata, handles)

% --- Executes on button press in average.
function average_Callback(hObject, eventdata, handles)
% hObject    handle to average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of average
handles.SBCalcMode = 'Average';
guidata(hObject, handles);
applyFormula_Callback(hObject, eventdata, handles)


% --- Executes when entered data in editable cell(s) in SBTable.
function SBTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to SBTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

group = get(handles.chooseSBGroup, 'Value');
subgroups = handles.SBExporter.getSubgroupsOfGroup(group);
subgroup = get(handles.chooseSBSubgroup, 'Value');
handles = handles.SBExporter.cellEditCallbackFunction(hObject, eventdata, handles, group, subgroups{subgroup})
guidata(hObject, handles)


% --- Executes on button press in savePlateKonfig.
function savePlateKonfig_Callback(hObject, eventdata, handles)
% hObject    handle to savePlateKonfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
groupStructure = handles.plateSimulatorInterface.getGroupStructure();
groupNames = get(handles.groupNameTable, 'data');
sharedBlankStructure = handles.plateSimulatorInterface.getSharedBlankStructure();
timewiseBlankStructure = handles.plateSimulatorInterface.getTimewiseBlankStructure();
timewiseBlankAlignment = handles.plateSimulatorInterface.getTimewiseBlankAlignment();
subgroupNames = handles.plateSimulatorInterface.getSubgroupNames();
subgroupNames = reshapeSubgroupNames(groupStructure, subgroupNames, sharedBlankStructure);
if isdeployed
    load([pwd, '\', 'settings.mat']);
else
    load settings
end
try
    [fileName, filePath] = uiputfile('*.mat', 'Save group config file, prefix GCF- is recommended', settings.GCFPath);
catch
    [fileName, filePath] = uiputfile('*.mat', 'Save group config file, prefix GCF- is recommended');
end
fullPath = [filePath, fileName];
save(fullPath, 'groupStructure', 'groupNames', 'sharedBlankStructure', 'timewiseBlankStructure', 'timewiseBlankAlignment', 'subgroupNames');

% --- Executes on button press in loadGroups.
function loadGroups_Callback(hObject, eventdata, handles)
% hObject    handle to loadGroups (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%[fileName, filePath] = uigetfile('*.mat', 'Choose group configuration file');
fileChooser = FileChooser;
[fileName, filePath] = fileChooser.chooseGCFFile();
load([filePath, fileName], 'groupStructure', 'groupNames', 'sharedBlankStructure', 'timewiseBlankStructure', 'timewiseBlankAlignment', 'subgroupNames');
if exist('groupStructure', 'var') && exist('groupNames', 'var');
    plateSizeFromFile = size(groupStructure);
    plateSizeFromExperiment = size(handles.apareciumExperimentInput.getWells());
    if isequal(plateSizeFromFile(1:2), plateSizeFromExperiment)    
        if ~exist('sharedBlankStructure', 'var')
            sharedBlankStructure = zeros(size(groupStructure, 1), size(groupStructure, 2), numel(groupNames));
        else
            numberOfCycles = handles.apareciumExperimentInput.getNumberOfCycles();
            if isequal(numberOfCycles, size(timewiseBlankStructure, 3)) % no need to change anything, everything matches up
                
            elseif numberOfCycles > size(timewiseBlankStructure, 3) % need to add some values to the end
                if strcmp(timewiseBlankAlignment, 'first')
                    sizeOfMatrix = size(timewiseBlankStructure);
                    timewiseBlankStructure = cat(3, timewiseBlankStructure, zeros([sizeOfMatrix(1 : 2), numberOfCycles - sizeOfMatrix(3)]));% need to add some values to the beginning
                elseif strcmp(timewiseBlankAlignment, 'last')
                    sizeOfMatrix = size(timewiseBlankStructure);
                    timewiseBlankStructure = cat(3, zeros([sizeOfMatrix(1 : 2), numberOfCycles - sizeOfMatrix(3)]), timewiseBlankStructure);
                end
            elseif numberOfCycles < size(timewiseBlankStructure, 3)
                if strcmp(timewiseBlankAlignment, 'first') % need to delete some values from the end
                    timewiseBlankStructure(:,:, numberOfCycles + 1 : end) = [];
                elseif strcmp(timewiseBlankAlignment, 'last') % need to delete some valued from the beginning
                    timewiseBlankStructure(:,:,1:end - numberOfCycles) = [];
                end
            end
        end
        if ~exist('timewiseBlankAlignment', 'var')
            timewiseBlankAlignment = 'first';
        end
        if ~exist('timewiseBlankStructure', 'var')
            
        end
        
        handles.apareciumExperimentInput.setGroups(groupNames);
        
        controllers{1} = handles.excelTableController;
        controllers{2} = handles.SBExporter;
        controllers{3} = handles.graphicalPreviewController;
        controllers{4} = handles.copasiPreviewController;
        controllers{5} = handles.prismPanelController;
        addParametersToControllers(controllers, handles.apareciumExperimentInput, groupStructure, subgroupNames, sharedBlankStructure, timewiseBlankStructure, handles.excelTableConfiguration);            
        
        handles.plateSimulatorInterface.addExperiment(handles.apareciumExperimentInput);
        handles.simPlateHandle = handles.plateSimulatorInterface.generatePlateSimulator(handles);
        handles.plateSimulatorInterface.regeneratePlateSimulatorFromGroupStructure(groupStructure, subgroupNames, sharedBlankStructure, timewiseBlankStructure, timewiseBlankAlignment);
        
        simPlateDone_Callback(handles.figure1, [], handles);
        
        set(handles.groupNameTable, 'data', groupNames);
        set(handles.groupsOKIndicator, 'String', 'OK', 'BackgroundColor', [0 1 0]);
        set(handles.chooseGraphGroup, 'String', handles.apareciumExperimentInput.getGroups());
        set(handles.savePlateKonfig, 'Enable', 'on');
        set(handles.numberOfGroupsField, 'String', num2str(numel(groupNames)));
       
    else
        warndlg('It seems that this .mat file defines grouping configuration for a plate of a different size. Groups not loaded.') 
    end
else
   warndlg('It seems that this .mat file is not in the correct format. Groups not loaded.') 
end


% --- Executes on button press in saveFormula.
function saveFormula_Callback(hObject, eventdata, handles)
% hObject    handle to saveFormula (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
activeFormula = handles.activeFormula;
channelNames = handles.apareciumExperimentInput.getChannelNames();
if isdeployed
    load([pwd, '\', 'settings.mat']);
else
    load settings
end 
try
    [fileName, filePath] = uiputfile('*.mat', 'Save group config file, prefix FCF- is recommended', settings.FCFPath);
catch
    [fileName, filePath] = uiputfile('*.mat', 'Save group config file, prefix FCF- is recommended');
end
fullPath = [filePath, fileName];
save(fullPath, 'activeFormula', 'channelNames');


% --- Executes on button press in toOriginalChannels.
function toOriginalChannels_Callback(hObject, eventdata, handles)
% hObject    handle to toOriginalChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = questdlg('This will clear the current formula, are you sure you want to continue?' ,'Question', 'Yes', 'No', 'No');
switch answer
    case 'Yes'
        handles.apareciumExperimentInput.setChannelNames(handles.originalChannels);
        set(handles.toOriginalChannels, 'Enable', 'off');
        handles.activeFormula = [];
        set(handles.formulaListBox, 'Value', 1);
        handles.originalChannels = [];
    case 'No'
        
end
handles = updateFormulaList(handles);
guidata(hObject, handles);


% --- Executes on selection change in graphFormatChooser.
function graphFormatChooser_Callback(hObject, eventdata, handles)
% hObject    handle to graphFormatChooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns graphFormatChooser contents as cell array
%        contents{get(hObject,'Value')} returns selected item from graphFormatChooser
if isequal(get(hObject,'Value'), 1)
    set(handles.graphXAxisChooser, 'Enable', 'off');
    set(handles.ZAxisUpperBound, 'Enable', 'off');
    set(handles.ZAxisLowerBound, 'Enable', 'off');
    set(handles.trisurfCheckbox, 'Enable', 'off');
    set(handles.pointsSurfaceCheckbox, 'Enable', 'off');
elseif isequal(get(hObject,'Value'), 2)
    set(handles.graphXAxisChooser, 'Enable', 'on');
    set(handles.ZAxisUpperBound, 'Enable', 'off');
    set(handles.ZAxisLowerBound, 'Enable', 'off');
    set(handles.trisurfCheckbox, 'Enable', 'off');
    set(handles.pointsSurfaceCheckbox, 'Enable', 'off');
elseif isequal(get(hObject,'Value'), 3)
    set(handles.graphXAxisChooser, 'Enable', 'on');
    set(handles.ZAxisUpperBound, 'Enable', 'on');
    set(handles.ZAxisLowerBound, 'Enable', 'on');
    set(handles.trisurfCheckbox, 'Enable', 'on');
    set(handles.pointsSurfaceCheckbox, 'Enable', 'on');
end
applyFormulaToGraph(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function graphFormatChooser_CreateFcn(hObject, eventdata, handles)
% hObject    handle to graphFormatChooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in graphXAxisChooser.
function graphXAxisChooser_Callback(hObject, eventdata, handles)
% hObject    handle to graphXAxisChooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns graphXAxisChooser contents as cell array
%        contents{get(hObject,'Value')} returns selected item from graphXAxisChooser
applyFormulaToGraph(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function graphXAxisChooser_CreateFcn(hObject, eventdata, handles)
% hObject    handle to graphXAxisChooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YAxisUpperBound_Callback(hObject, eventdata, handles)
% hObject    handle to YAxisUpperBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YAxisUpperBound as text
%        str2double(get(hObject,'String')) returns contents of YAxisUpperBound as a double
handles.graphicalPreviewController.updateGraphic();

% --- Executes during object creation, after setting all properties.
function YAxisUpperBound_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YAxisUpperBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YAxisLowerBound_Callback(hObject, eventdata, handles)
% hObject    handle to YAxisLowerBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YAxisLowerBound as text
%        str2double(get(hObject,'String')) returns contents of YAxisLowerBound as a double
handles.graphicalPreviewController.updateGraphic();

% --- Executes during object creation, after setting all properties.
function YAxisLowerBound_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YAxisLowerBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XAxisLowerBound_Callback(hObject, eventdata, handles)
% hObject    handle to XAxisLowerBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XAxisLowerBound as text
%        str2double(get(hObject,'String')) returns contents of XAxisLowerBound as a double
handles.graphicalPreviewController.updateGraphic();

% --- Executes during object creation, after setting all properties.
function XAxisLowerBound_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XAxisLowerBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XAxisUpperBound_Callback(hObject, eventdata, handles)
% hObject    handle to XAxisUpperBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XAxisUpperBound as text
%        str2double(get(hObject,'String')) returns contents of XAxisUpperBound as a double
handles.graphicalPreviewController.updateGraphic();

% --- Executes during object creation, after setting all properties.
function XAxisUpperBound_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XAxisUpperBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.graphicalPreviewController.plotToExternalFigure('on');
handles.graphicalPreviewController.copyAxesToNewFigure();
handles.graphicalPreviewController.plotToExternalFigure('off');

function ZAxisUpperBound_Callback(hObject, eventdata, handles)
% hObject    handle to ZAxisUpperBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ZAxisUpperBound as text
%        str2double(get(hObject,'String')) returns contents of ZAxisUpperBound as a double
handles.graphicalPreviewController.updateGraphic();

% --- Executes during object creation, after setting all properties.
function ZAxisUpperBound_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ZAxisUpperBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ZAxisLowerBound_Callback(hObject, eventdata, handles)
% hObject    handle to ZAxisLowerBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ZAxisLowerBound as text
%        str2double(get(hObject,'String')) returns contents of ZAxisLowerBound as a double
handles.graphicalPreviewController.updateGraphic();

% --- Executes during object creation, after setting all properties.
function ZAxisLowerBound_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ZAxisLowerBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function uitoggletool7_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in chooseGraphGroup.
function chooseGraphGroup_Callback(hObject, eventdata, handles)
% hObject    handle to chooseGraphGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns chooseGraphGroup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chooseGraphGroup
applyFormulaToGraph(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function chooseGraphGroup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseGraphGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.graphicalPreviewController = GraphicalPreviewController(hObject);
guidata(hObject, handles);
% Hint: place code in OpeningFcn to populate axes


% --- Executes on button press in trisurfCheckbox.
function trisurfCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to trisurfCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trisurfCheckbox
applyFormulaToGraph(hObject, eventdata, handles);

% --- Executes on button press in pointsSurfaceCheckbox.
function pointsSurfaceCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to pointsSurfaceCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pointsSurfaceCheckbox
applyFormulaToGraph(hObject, eventdata, handles);


% --------------------------------------------------------------------
function uitoggletool4_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function autoExport(hObject, eventdata, handles)

    % load in the correct plate config
    filePath = 'C:\Users\dell\Desktop\Bakalaureuse töö bioorgaanikas\Aparecium project\Aparecium refactored version\';
    fileName = 'GCF-VirusTitrationGroups.mat';
load([filePath, fileName], 'groupStructure', 'groupNames');
if exist('groupStructure', 'var') && exist('groupNames', 'var');
    handles.excelTableController.addExperiment(handles.apareciumExperimentInput);
    handles.excelTableController.addGroupStructure(groupStructure);
    handles.SBExporter.addExperiment(handles.apareciumExperimentInput);
    handles.SBExporter.addGroupStructure(groupStructure);
    handles.apareciumExperimentInput.setGroups(groupNames);
    handles.graphicalPreviewController.addExperiment(handles.apareciumExperimentInput);
    handles.graphicalPreviewController.addGroupStructure(groupStructure);   
    set(handles.groupNameTable, 'data', groupNames);
    set(handles.groupsOKIndicator, 'String', 'OK', 'BackgroundColor', [0 1 0]);
    set(handles.chooseGraphGroup, 'String', handles.apareciumExperimentInput.getGroups());
    set(handles.savePlateKonfig, 'Enable', 'on');
    set(handles.applyFormula, 'Enable', 'on');
else
   warndlg('It seems that this .mat file is not in the correct format. Groups not loaded.') 
end
formulaNames = {'FCF-CellDiameter.mat','FCF-CellDiameterSTD.mat','FCF-CellArea.mat','FCF-CellAreaSTD.mat','FCF-CellCount.mat','FCF-MaxCellDiameter.mat'};

for formulaIndex = 1:6
    % load in the correct formula
    fileName = formulaNames{formulaIndex};
    load([filePath, fileName], 'activeFormula', 'channelNames');
    if exist('activeFormula', 'var') && exist('channelNames', 'var') 
        if isequal(channelNames, handles.apareciumExperimentInput.getChannelNames());
            handles.activeFormula = activeFormula;
            updateFormulaList(handles);
        else
            newFormulaChannels = ChooseChannelConsistency(handles.apareciumExperimentInput.getChannelNames(), channelNames);
            if isequal(newFormulaChannels, '')

            else
                if isequal(handles.originalChannels, []); 
                    handles.originalChannels = handles.apareciumExperimentInput.getChannelNames();
                    set(handles.toOriginalChannels, 'Enable', 'on');
                end
                handles.apareciumExperimentInput.setChannelNames(newFormulaChannels);
                handles.activeFormula = activeFormula;
                updateFormulaList(handles);
            end
        end
    else
       warndlg('It seems that this .mat file is not in the correct format. Formula not loaded.') 
    end
    
    
    % change time unit
    set(handles.outputTimeUnitDropdown,'Value', 4);
    outputTimeUnitDropdown_Callback(handles.outputTimeUnitDropdown, eventdata, handles)
    
    %apply formula
    set(handles.tableConfigurationChooser,'Value',1);
    tableConfigurationChooser_Callback(handles.tableConfigurationChooser, eventdata, handles);
    handles.excelTableConfiguration = 1;
    applyFormula_Callback(hObject, eventdata, handles);
    
    %export excel as kinetic 
    
    outputFilename = [handles.midasTableController.fullFilePath, fileName,'_kinetic_', '.xls'];
    handles.excelTableController.exportToExcelWithName(outputFilename);
    
    %export as concentration dependance
    set(handles.tableConfigurationChooser,'Value',2);
    tableConfigurationChooser_Callback(handles.tableConfigurationChooser, eventdata, handles);
    guidata(hObject, handles)
    handles.excelTableConfiguration = 2;
    set(handles.xAxisTreatmentSelection, 'Value', 3);
    xAxisTreatmentSelection_Callback(handles.xAxisTreatmentSelection, eventdata, handles);
    
    outputFilename = [handles.midasTableController.fullFilePath, fileName,'_dilution_Dependant_', '.xls'];
    handles.excelTableController.exportToExcelWithName(outputFilename);
    
    %export as SB
    data = get(handles.parameterNameTable,'data');
    data{1,2} = 'LogDilution';
    data{2,2} = 'HealthyCells';
    set(handles.parameterNameTable,'data');
    parameterNameTable_CellEditCallback(hObject, eventdata, handles);
    [path, useless, useless2,useless3] = fileparts(handles.midasTableController.fullFilePath);
    mkdir([path,'\','Experiments']);
    
    handles.SBExporter.exportWithName([path,'\','Experiments']);
    
end
msgbox('quickexport finished')

% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
autoExport(hObject, eventdata, handles)


% --- Executes on button press in removeEmptyRows.
function removeEmptyRows_Callback(hObject, eventdata, handles)
% hObject    handle to removeEmptyRows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of removeEmptyRows
handles.excelTableController.removeEmptyRows = get(handles.removeEmptyRows, 'Value');


% --- Executes on selection change in organizationStyle.
function organizationStyle_Callback(hObject, eventdata, handles)
% hObject    handle to organizationStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns organizationStyle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from organizationStyle
applyFormulaToExcelPreview(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function organizationStyle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to organizationStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in excelTable.
function excelTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to excelTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
handles.excelTableController.updateSelectedIndices(eventdata.Indices);
guidata(hObject, handles);


% --- Executes on key press with focus on excelTable and none of its controls.
function excelTable_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to excelTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
% disp([eventdata.Modifier, '', eventdata.Key])
% if strcmp(eventdata.Key, 'c') && strcmp(eventdata.Modifier, 'control')
%     handles.excelTableController.customCopy();
% end



% --- Executes on button press in sendExcelToWorkspace.
function sendExcelToWorkspace_Callback(hObject, eventdata, handles)
% hObject    handle to sendExcelToWorkspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.excelTableController.sendToWorkspace();

% --- Executes on button press in sendSBTableToWorkspace.
function sendSBTableToWorkspace_Callback(hObject, eventdata, handles)
% hObject    handle to sendSBTableToWorkspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
group = get(handles.chooseSBGroup, 'Value');
subgroup = get(handles.chooseSBSubgroup, 'Value'); 
subgroups = handles.SBExporter.getSubgroupsOfGroup(group);
handles.SBExporter.sendTableToWorkspace(group, subgroups{subgroup});


% --- Executes on button press in editFormula.
function editFormula_Callback(hObject, eventdata, handles)
% hObject    handle to editFormula (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
formulaIndexToEdit = get(handles.formulaListBox, 'Value');
channelNames = handles.apareciumExperimentInput.getChannelNames();
acronyme = '';
for formulaIndex = 1 : formulaIndexToEdit - 1
    [channelNames] = GetFunctionOutputArguments( channelNames, handles.activeFormula{formulaIndex}.acronyme);  
end
previousAcronyme = handles.activeFormula{formulaIndexToEdit}.acronyme;
[formula, acronyme] = calc(channelNames, 'edit', handles.activeFormula{formulaIndexToEdit}.formula, handles.activeFormula{formulaIndexToEdit}.acronyme);
if isequal(strcmp(formula, ''), 0) && isequal(strcmp(acronyme, ''), 0) 
    handles.activeFormula{formulaIndexToEdit}.acronyme = acronyme{1};
    handles.activeFormula{formulaIndexToEdit}.formula = formula;
    updateFormulaList(handles);
end
previousChannelNames = GetFunctionOutputArguments( channelNames, previousAcronyme);
newChannelNames = GetFunctionOutputArguments( channelNames, handles.activeFormula{formulaIndexToEdit}.acronyme);
for formulaIndex = formulaIndexToEdit : numel(handles.activeFormula)
    if isequal(formulaIndex, formulaIndexToEdit) 
        previousChannelNames = GetFunctionOutputArguments( previousChannelNames, previousAcronyme);
    else
        previousChannelNames = GetFunctionOutputArguments( previousChannelNames, handles.activeFormula{formulaIndex}.acronyme);
    end
    newChannelNames = GetFunctionOutputArguments( newChannelNames, handles.activeFormula{formulaIndex}.acronyme);
    if formulaIndex < numel(handles.activeFormula)
        if isfield(handles.activeFormula{formulaIndex+1}, 'formula') % if there is no formula field then it must be a built-in function 
            for channelIndex = 1 : numel(previousChannelNames)
                handles.activeFormula{formulaIndex+1}.formula = regexprep(handles.activeFormula{formulaIndex+1}.formula, previousChannelNames(channelIndex), newChannelNames(channelIndex));
            end
        end
    end
end
guidata(hObject, handles)


% --- Executes on button press in saveThisExport.
function saveThisExport_Callback(hObject, eventdata, handles)
% hObject    handle to saveThisExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
export = MIDASExport();
export.exportName = get(handles.exportName, 'String');
export.setGroupNames(get(handles.groupNameTable, 'Data'));
export.setGroupStructure(handles.plateSimulatorInterface.getGroupStructure());
subgroupNames = handles.plateSimulatorInterface.getSubgroupNames();
groupStructure = handles.plateSimulatorInterface.getGroupStructure();
subgroupNames = reshapeSubgroupNames(groupStructure, subgroupNames);
export.subgroupNames = subgroupNames;
calculationMethod = CalculationMethod();
if get(handles.showBlank, 'Value')
    subgroupStartValue = 1;
else
    subgroupStartValue = 2;
end
calculationMethod.setSubgroupStartValue(subgroupStartValue);
calculationMethod.addFormulae(handles.activeFormula);
export.setCalculationMethod(calculationMethod);
export.setSharedBlankStructure(handles.plateSimulatorInterface.getSharedBlankStructure());
export.setTimwiseBlankStructure(handles.plateSimulatorInterface.getTimewiseBlankStructure());
export.setTimewiseBlankAlignment(handles.plateSimulatorInterface.getTimewiseBlankAlignment());
selectedExportIndex = get(handles.previewTabGroup, 'SelectedIndex');
children = get(handles.previewTabGroup, 'Children');
activeTab = children(selectedExportIndex);
contents = get(handles.outputTimeUnitDropdown, 'String');
export.setTimeUnit(contents{get(handles.outputTimeUnitDropdown, 'Value')});
switch get(activeTab, 'Title')
    case 'Excel preview'
        export.setExportType(export.excel);
        contents = get(handles.tableConfigurationChooser, 'String');
        export.setTableType(contents{get(handles.tableConfigurationChooser,'Value')});
        contents = get(handles.xAxisTreatmentSelection, 'String');
        export.xAxisTypeTable = contents{get(handles.xAxisTreatmentSelection,'Value')};
        contents = get(handles.organizationStyle, 'String');
        switch contents{get(handles.organizationStyle,'Value')} 
            case 'Groups'  
                export.tableOrganizationStyle = export.organizationStyleGroups;
            case 'Subgroups (beta)'
                export.tableOrganizationStyle = export.organizationStyleSubgroups;
        end
        
        switch get(handles.excelOrPrism, 'SelectedObject')
            case handles.autoExportToPrism
                export.excelOrPrism = export.prism;
            case handles.autoExportToExcel
                export.excelOrPrism = export.excel;
        end
            
    case 'SBtoolbox preview'
        export.setExportType(export.SB);
        export.variableNames = get(handles.parameterNameTable, 'Data');
        switch get(handles.mergeSB, 'Value')
            case 1
                export.fastKineticsExportMethod = export.merge;
            case 0
                export.fastKineticsExportMethod = export.average;
        end
    case 'Graphical preview'
        export.setExportType(export.figure);
        contents = get(handles.graphFormatChooser, 'String');
        switch contents{get(handles.graphFormatChooser, 'Value')}
            case 'Value vs time (2D)'
                export.graphFormat = export.timeDependant;
            case 'Value vs concentration (2D)'
                export.graphFormat = export.concentrationDependant;
            case 'Value vs concentration and time (3D)'
                export.graphFormat = export.threeD;
        end
        contents = get(handles.graphXAxisChooser, 'String');
        export.xAxisTypeFigure = contents{get(handles.graphXAxisChooser,'Value')};
        contents = get(handles.chooseGraphGroup, 'String');
        export.activeGroup = contents{get(handles.chooseGraphGroup, 'Value')};
        export.points = get(handles.pointsSurfaceCheckbox, 'Value');
        export.surface = get(handles.trisurfCheckbox, 'Value');
end

handles.output{end+1} = export;
guidata(hObject, handles);
if strcmp(handles.mode, 'Edit protocol')
    figure1_CloseRequestFcn(handles.figure1, [], handles);
end

function exportName_Callback(hObject, eventdata, handles)
% hObject    handle to exportName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exportName as text
%        str2double(get(hObject,'String')) returns contents of exportName as a double


% --- Executes during object creation, after setting all properties.
function exportName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exportName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch handles.mode
    case 'Protocol Generator' 
        if isequal(get(hObject, 'waitstatus'),'waiting')
            guidata(hObject, handles);
            uiresume(hObject);
        else
            delete(hObject);
        end
    case 'Edit protocol'
        if isequal(get(hObject, 'waitstatus'),'waiting')
            guidata(hObject, handles);
            uiresume(hObject);
        else
            delete(hObject);
        end
    case 'MIDAS export'
        delete(hObject);
end
% Hint: delete(hObject) closes the figure


% --- Executes when selected object is changed in uipanel9.
function uipanel9_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel9 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton37.
function pushbutton37_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

AdvancedTimeChooser(handles.exportTimeMomentController);
handles.exportTimeMomentController.changeCycleListHandle(handles.timeRemoval);
handles.exportTimeMomentController.changeOutputTimeUnitDropdownHandle(handles.outputTimeUnitDropdown);
guidata(hObject, handles);

% --- Executes on selection change in popupmenu10.
function popupmenu10_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu10
switch get(hObject,'Value')
    case 1
        set(handles.chooseGraphGroup, 'String', handles.apareciumExperimentInput.getGroups());
        handles.graphicalPreviewController.organizationStyle = 'Group';
        set(handles.chooseGraphGroup, 'Value', 1);
        
    case 2        
        names = cell(handles.plateSimulatorInterface.getSubgroupNames());
        if get(handles.showBlank, 'Value')
           subgroupStartValue = 1; 
        else
           subgroupStartValue = 2;
        end
        set(handles.chooseGraphGroup, 'String', names(1, subgroupStartValue:end));
        handles.graphicalPreviewController.organizationStyle = 'Subgroup';
        set(handles.chooseGraphGroup, 'Value', 1);
end
guidata(hObject, handles)

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


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
handles.graphicalPreviewController.holdOn = get(hObject,'Value');
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function generalSettingsPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to generalSettingsPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in exportToCopasi.
function exportToCopasi_Callback(hObject, eventdata, handles)
% hObject    handle to exportToCopasi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.copasiPreviewController.exportWithDialogue();

% --- Executes on button press in pushbutton39.
function pushbutton39_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton40.
function pushbutton40_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton41.
function pushbutton41_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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


% --- Executes when entered data in editable cell(s) in copasiParameterNameTable.
function copasiParameterNameTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to copasiParameterNameTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
handles.copasiPreviewController.getNewExperimentParamsNames();
applyFormula_Callback(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pos = get(hObject, 'Position');
try
    set(handles.simPlateHandle, 'Position',[0,0, pos(3), pos(4)]);
    drawnow;
catch
    
end
guidata(hObject, handles)


% --- Executes on button press in showBlank.
function showBlank_Callback(hObject, eventdata, handles)
% hObject    handle to showBlank (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showBlank
if get(handles.showBlank, 'Value')
   subgroupStartValue = 1; 
else
   subgroupStartValue = 2;
end
handles.excelTableController.setSubgroupStartValue(subgroupStartValue);
handles.SBExporter.setSubgroupStartValue(subgroupStartValue);
handles.graphicalPreviewController.setSubgroupStartValue(subgroupStartValue);
handles.copasiPreviewController.setSubgroupStartValue(subgroupStartValue);
guidata(hObject, handles)


% --- Executes on button press in pushbutton42.
function pushbutton42_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton43.
function pushbutton43_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton44.
function pushbutton44_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes on button press in pushbutton45.
function pushbutton45_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in PrismOrganizationStyle.
function PrismOrganizationStyle_Callback(hObject, eventdata, handles)
% hObject    handle to PrismOrganizationStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PrismOrganizationStyle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PrismOrganizationStyle


% --- Executes during object creation, after setting all properties.
function PrismOrganizationStyle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PrismOrganizationStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PrismXAxisTreatmentSelection.
function PrismXAxisTreatmentSelection_Callback(hObject, eventdata, handles)
% hObject    handle to PrismXAxisTreatmentSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PrismXAxisTreatmentSelection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PrismXAxisTreatmentSelection


% --- Executes during object creation, after setting all properties.
function PrismXAxisTreatmentSelection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PrismXAxisTreatmentSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PrismTableConfigurationChooser.
function PrismTableConfigurationChooser_Callback(hObject, eventdata, handles)
% hObject    handle to PrismTableConfigurationChooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PrismTableConfigurationChooser contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PrismTableConfigurationChooser


% --- Executes during object creation, after setting all properties.
function PrismTableConfigurationChooser_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PrismTableConfigurationChooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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


% --- Executes on selection change in listbox4.
function listbox4_Callback(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox4


% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function commonNamePrefix_Callback(hObject, eventdata, handles)
% hObject    handle to commonNamePrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of commonNamePrefix as text
%        str2double(get(hObject,'String')) returns contents of commonNamePrefix as a double
handles.SBExporter.setPrefix(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function commonNamePrefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to commonNamePrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function commonNameSuffix_Callback(hObject, eventdata, handles)
% hObject    handle to commonNameSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of commonNameSuffix as text
%        str2double(get(hObject,'String')) returns contents of commonNameSuffix as a double
handles.SBExporter.setSuffix(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function commonNameSuffix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to commonNameSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SBIncludedMeasurements.
function SBIncludedMeasurements_Callback(hObject, eventdata, handles)
% hObject    handle to SBIncludedMeasurements (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SBIncludedMeasurements contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SBIncludedMeasurements
applyFormula_Callback(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function SBIncludedMeasurements_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SBIncludedMeasurements (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'max', 2);% this allows selection of multiple lines
guidata(hObject, handles);


% --- Executes on button press in saveNameMapping.
function saveNameMapping_Callback(hObject, eventdata, handles)
% hObject    handle to saveNameMapping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameterNameData = get(handles.parameterNameTable, 'data');
SBParamNames = parameterNameData(:, 2);
originalParamNames = parameterNameData(:, 1);
stateOrParam = parameterNameData(:, 3); %indicates state
defaultInclude = parameterNameData(:, 5);

for param = 1 : numel(SBParamNames)
   if stateOrParam{param}
        stateOrParamString = 'state';
   else
        stateOrParamString = 'param';
   end
   MIDAS2SBNameManager.addNewChannel(originalParamNames{param}, SBParamNames{param}, stateOrParamString, defaultInclude{param}); 
end


% --- Executes on button press in fastKineticsModel.
function fastKineticsModel_Callback(hObject, eventdata, handles)
% hObject    handle to fastKineticsModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.SBExporter.setUltracorrect(get(hObject, 'Value'));
% Hint: get(hObject,'Value') returns toggle state of fastKineticsModel
guidata(hObject, handles);
