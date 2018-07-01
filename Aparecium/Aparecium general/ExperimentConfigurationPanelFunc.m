function handles = ExperimentConfigurationPanelFunc(handles, varargin)
%   Create an Experiment configuration panel for Aparecium
%   Programmatically creates all the subcomponents and adds component
%   handles to handles structure. The handles must contain a field named
%   figure1 which will be set as the parent component of the panel

% Define the configuration panel
noMeasurements = 0;
if(numel(varargin) > 0)
    if strcmp(varargin{1}, 'noMeasurements')
        noMeasurements = 1;
    end
end

mainPanel = uipanel('Parent', handles.figure1); % don´t forget to set parent here later
if ~noMeasurements
    height = 0.8816;
else
    height = 0.6426282051282051;
end
set(mainPanel, 'BackgroundColor', [225/255 226/255 251/255]);
set(mainPanel, 'Position', [0.690272373540856, 0.009600000000000001, 0.3042801556420234, height])
set(mainPanel, 'Title', 'Experiment configuration')

handles = setTag(mainPanel, handles, 'ExperimentConfigurationPanel');


% Define the children of main panel

% Define the ConfigurationFilesPanel subpanel

ConfigurationFilesPanel = uipanel('Parent', mainPanel);
set(ConfigurationFilesPanel, 'BackgroundColor', [225/255 226/255 251/255]);
set(ConfigurationFilesPanel, 'Position', [0.00516795865633075 0.8560747663551411 0.9586563307493542 0.11775700934579443]);
set(ConfigurationFilesPanel, 'Title', 'Experiment configuration')
handles = setTag(ConfigurationFilesPanel, handles, 'ConfigurationFilesPanel');


% Define the children of load and save panel

% Define the load button
loadButton = uicontrol('Parent', ConfigurationFilesPanel, 'Style', 'pushbutton');
set(loadButton, 'Units', 'normalized')
set(loadButton,...
    'TooltipString', 'Load a predefined configuration file',...
    'Position', [0.027247956403269748 0.23404255319148887 0.27520435967302453 0.6595744680851064],...
    'BackgroundColor', [156/255 175/255 212/255],...
    'String', 'Load') 
handles = setTag(loadButton, handles, 'LoadConfigurationFile');

set(loadButton, 'Callback', createCallback('LoadConfigurationFile_Callback'));


% Define the save button


saveButton = uicontrol('Parent', ConfigurationFilesPanel, 'Style', 'pushbutton');
set(saveButton, 'Units', 'normalized');
set(saveButton,...
    'String', 'Save',...
    'TooltipString', 'Save the active configuration as a configuration file',...
    'BackgroundColor', [156/255 175/255 212/255],...
    'Position', [0.33787465940054495 0.23404255319148942 0.2970027247956403 0.6808510638297873])
handles = setTag(saveButton, handles, 'SaveConfigurationFile');

set(saveButton, 'Callback', createCallback('SaveConfigurationFile_Callback'));

% end of ConfigurationFilesPanel 

% Define the DimenstionalityPanel

DimensionalityPanel = uipanel('Parent', mainPanel);

set(DimensionalityPanel, 'BackgroundColor', [225/255 226/255 251/255]);
set(DimensionalityPanel, 'Title', 'Dimensionality');
set(DimensionalityPanel, 'Position', [0.00516795865633075 0.7514018691588785 0.9741602067183462 0.09906542056074773]);
handles = setTag(DimensionalityPanel, handles, 'DimensionalityPanel');

% Define the childern of DimensionalityPanel

% Define the ChooseDimenstionalityText 
ChooseDimensionalityText = uicontrol('Parent', DimensionalityPanel, 'Style', 'text');
set(ChooseDimensionalityText, 'Units', 'normalized');
set(ChooseDimensionalityText, 'String', 'Choose the dimensionality of the experiment :',...
    'Position', [0.03485254691689008 0.4054054054054036 0.6005361930294907 0.43243243243243246],...
    'Background', [225/255 226/255 251/255],...
    'TooltipString', 'Enter the number of different parameters that were or can be changed');
handles = setTag(ChooseDimensionalityText, handles, 'ChooseDimensionalityText');

% Define the ChooseDimensionality editable field

ChooseDimensionality = uicontrol('Parent', DimensionalityPanel, 'Style', 'edit');
set(ChooseDimensionality, 'Units', 'normalized');
set(ChooseDimensionality, 'String', '1',...
    'Position', [0.6675603217158178 0.3513513513513491 0.13672922252010725 0.5135135135135136],...
    'BackgroundColor', [1 1 1])
handles = setTag(ChooseDimensionality, handles, 'ChooseDimensionality');

set(ChooseDimensionality, 'Callback', createCallback('ChooseDimensionality_Callback'));

% end of DimensionalityPanel

% Define the TreatmentPanel

TreatmentPanel = uipanel('Parent', mainPanel);
set(TreatmentPanel, 'Title', 'Treatments',...
    'Position', [0.00516795865633075 0.3383177570093458 0.9922480620155041 0.40560747663551433],...
    'BackgroundColor', [225/255 226/255 251/255]);
handles = setTag(TreatmentPanel, handles, 'TreatmentPanel');

% Define children of TreatmentPanel

% Define treatments_Table
treatments_Table = uitable('Parent', TreatmentPanel, 'CreateFcn', createCallback('treatments_Table_CreateFcn'),...
    'Units', 'normalized',...
    'Position', [0.021052631578947368 0.09452736318407959 0.968421052631579 0.900497512437811],...
    'ColumnEditable', logical([1 1 1 1 1]), 'ColumnFormat', {[] [] [], 'logical', 'logical'},...
    'ColumnWidth', {88 89 50 50 59}, 'ColumnName', {'Treatment';'Concentrations'; 'Units'; 'Delete'; 'Conc seq'});
setTableBackground(treatments_Table, [186/255 205/255 242/255]);
handles = setTag(treatments_Table, handles, 'treatments_Table');

set(treatments_Table, 'CellEditCallback', createCallback('treatments_Table_CellEditCallback'));
set(treatments_Table, 'CreateFcn', createCallback('treatments_Table_CreateFcn'));

% end of TreatmentPanel

% Define MeasurementsPanel

Measurements = uipanel('Parent', mainPanel);
set(Measurements, 'Position', [0.00516795865633075 0.009345794392523369 0.9870801033591732 0.27102803738317777],...
    'Title', 'Channels',...
    'BackgroundColor', [225/255 226/255 251/255]);
handles = setTag(Measurements, handles, 'Measurements');

% Define childern of measurementsPanel

% Define measurements (channels) table

channels_Table = uitable('Parent', Measurements);
set(channels_Table, 'Units', 'normalized');
set(channels_Table, 'Position', [0.013227513227513225 0.21255813953488355 0.9576719576719577 0.7674418604651163],...
    'ColumnEditable', logical([0 1]), 'ColumnFormat', {[] 'char'}, 'ColumnWidth', {160 170},...
    'ColumnName', {'Channel name from input';'Channel name used in MIDAS'});
setTableBackground(channels_Table, [186/255 205/255 242/255]);
handles = setTag(channels_Table, handles, 'channels_Table');

set(channels_Table, 'CellEditCallback', createCallback('channels_Table_CellEditCallback'));

% Define saveMIDASChannelNames button

saveMIDASChannelNames = uicontrol('Parent', Measurements, 'Style', 'pushbutton');
set(saveMIDASChannelNames, 'Units', 'normalized');
set(saveMIDASChannelNames, 'Position', [0.5291005291005291 0.01542635658914729 0.3968253968253968 0.17829457364341084],...
    'BackgroundColor', [156/255 175/255 212/255],...
    'String', 'Save MIDAS channel names');
handles = setTag(saveMIDASChannelNames, handles, 'saveMIDASChannelNames');

set(saveMIDASChannelNames, 'Callback', createCallback('saveMIDASChannelNames_Callback'));

% end of children of MeasurementsPanel

% Define OpenPlateSimulator button

OpenPlateSimulator = uicontrol('Parent', mainPanel, 'Style', 'pushbutton');
set(OpenPlateSimulator, 'Units', 'normalized');
set(OpenPlateSimulator, 'Position', [0.028423772609819122 0.28785046728972 0.2842377260981912 0.04672897196261683],...
    'BackgroundColor', [156/255 175/255 212/255],...
    'String', 'Open PlateSimulator');
handles = setTag(OpenPlateSimulator, handles, 'OpenPlateSimulator');

set(OpenPlateSimulator, 'Callback', createCallback('OpenPlateSimulator_Callback'));

guidata(handles.figure1, handles);



end

function setTableBackground(table, color)
try
    object = findjobj(table);
    viewport = get(object, 'Viewport');
    set(viewport, 'Background', color)
    comp = get(viewport, 'Components');
    header = get(comp(1), 'TableHeader');
    set(header, 'Background',color);
    rowHeader = get(object, 'RowHeader');
    set(rowHeader, 'Background', color);
catch MException
    if strcmp(MException.identifier, 'MATLAB:class:IncompatibleJavaClass')
        % We are dealing with newer version of Java, try to set color as an
        % object 
        object = findjobj(table);
        viewport = get(object, 'Viewport');
        set(viewport, 'Background', java.awt.Color(color(1), color(2), color(3)))
        comp = get(viewport, 'Components');
        header = get(comp(1), 'TableHeader');
        set(header, 'Background', java.awt.Color(color(1), color(2), color(3)));
        rowHeader = get(object, 'RowHeader');
        set(rowHeader, 'Background', java.awt.Color(color(1), color(2), color(3)));
    end
end
end

