function handles = MIDASOptionsPanelFunc(handles, varargin)
%   Create an MIDASOptions panel for Aparecium
%   Programmatically creates all the subcomponents and adds component
%   handles to handles structure. The handles must contain a field named
%   figure1 which will be set as the parent component of the panel

% Define the MIDASOptionsPanel

mainPanel = uipanel('Parent', handles.MIDASPreviewPanel);

set(mainPanel, 'BackgroundColor', [225/255 226/255 251/255]);
set(mainPanel, 'Position', [0.8292964244521339, 0.01353637901861252, 0.1626297577854672, 0.9170896785109984]);
set(mainPanel, 'Title', 'MIDAS options');

handles = setTag(mainPanel, handles, 'uipanel7');


% Define children of the main panel

% Define the time options panel

timeOptionsPanel = uipanel('Parent', mainPanel);
set(timeOptionsPanel, 'BackgroundColor', [225/255 226/255 251/255],...
    'Position', [0.0364963503649635 0.44106463878326996 0.8321167883211679 0.5437262357414449],...
    'Title', 'Time options');
handles = setTag(timeOptionsPanel, handles, 'uipanel8');

% Define children of timeOptionsPanel

% Define include events checkbox

includeEventsCheckBox = uicontrol('Parent', timeOptionsPanel, 'Style', 'checkbox');
set(includeEventsCheckBox, 'Units', 'normalized');
set(includeEventsCheckBox, 'TooltipString', 'Check to include events to the MIDAS file, useful for later SBtoolbox analysis',...
    'Position', [0.03636363636363637 0.9 0.8818181818181821 0.0851851851851852],...
    'String', 'Include events',...
    'BackgroundColor', [225/255 226/255 251/255]);
setTag(includeEventsCheckBox, handles, 'includeEventToMIDAS');

set(includeEventsCheckBox, 'Callback', createCallback('includeEventToMIDAS_Callback'));

% Define fast kinetics checkbox

fastKineticsCheckBox = uicontrol('Parent', timeOptionsPanel, 'Style', 'checkbox');
set(fastKineticsCheckBox, 'Units', 'normalized');
set(fastKineticsCheckBox, 'TooltipString', 'Check to computationally enhance time of measurement precision',...
    'Position', [0.03636363636363637 0.7851851851851854 0.790909090909091 0.0851851851851852],...
    'String', 'Fast kinetics',...
    'BackgroundColor', [225/255 226/255 251/255]);
setTag(fastKineticsCheckBox, handles, 'fastKinetics');

set(fastKineticsCheckBox, 'Callback', createCallback('fastKinetics_Callback'));

% Define input time unit text

inputTimeUnitText = uicontrol('Parent', timeOptionsPanel, 'Style', 'text');
set(inputTimeUnitText, 'Units', 'normalized');
set(inputTimeUnitText, 'String', 'Input time unit', 'Position',...
    [0.08181818181818182 0.6925925925925931 0.6545454545454545 0.05555555555555559],...
    'Background', [225/255 226/255 251/255],...
    'TooltipString', 'Choose the timeunits that the platereader was using');
handles = setTag(inputTimeUnitText, handles, 'text6');

% Define input time unit popupmenu

inputTimeUnitPopupmenu = uicontrol('Parent', timeOptionsPanel, 'Style', 'popupmenu');
set(inputTimeUnitPopupmenu, 'Units', 'normalized');
set(inputTimeUnitPopupmenu,...
    'Position', [0.08181818181818182 0.603703703703704 0.8181818181818181 0.08148148148148154],...
    'String', {'ms', 's', 'm', 'h'}, 'Value', 2,...
    'Background', [1 1 1],...
    'TooltipString', 'Choose the time units that the machine was using');
handles = setTag(inputTimeUnitPopupmenu, handles, 'inputTimeUnit');

set(inputTimeUnitPopupmenu, 'Callback', createCallback('inputTimeUnit_Callback'));

% Define MIDAS time unit text

MIDASTimeUnitText = uicontrol('Parent', timeOptionsPanel, 'Style', 'text');
set(MIDASTimeUnitText, 'Units', 'normalized');
set(MIDASTimeUnitText, 'String', 'MIDAS time unit', 'Position',...
    [0.08181818181818182 0.45555555555555555 0.7181818181818183 0.062962962962963],...
    'Background', [225/255 226/255 251/255],...
    'TooltipString', 'Choose the time units that will be used in the MIDAS file');
handles = setTag(MIDASTimeUnitText, handles, 'text7');

% Define MIDAS time unit popupmenu

MIDASTimeUnitPopupmenu = uicontrol('Parent', timeOptionsPanel, 'Style', 'popupmenu');
set(MIDASTimeUnitPopupmenu, 'Units', 'normalized');
set(MIDASTimeUnitPopupmenu,...
    'Position', [0.08181818181818182 0.3703703703703705 0.8181818181818181 0.0851851851851852],...
    'String', {'ms', 's', 'm', 'h'}, 'Value', 2,...
    'Background', [1 1 1],...
    'TooltipString', 'Choose the time units that will be used in the MIDAS file', 'Enable', 'off');
handles = setTag(MIDASTimeUnitPopupmenu, handles, 'outputTimeUnit');

set(MIDASTimeUnitPopupmenu, 'Callback', createCallback('outputTimeUnit_Callback'));

% Define time shift text

timeShiftText = uicontrol('Parent', timeOptionsPanel, 'Style', 'text');
set(timeShiftText, 'Units', 'normalized');
set(timeShiftText, 'String', 'Time before measurement start', 'Position',...
    [0.1090909090909091 0.0962962962962963 0.8272727272727273 0.12962962962962965],...
    'Background', [225/255 226/255 251/255],...
    'TooltipString', 'Enter time between adding treatments and the moment when Neo started measuring, it will have same units as input time unit');
handles = setTag(timeShiftText, handles, 'text8');

% Define time shift edit

timeShiftEdit = uicontrol('Parent', timeOptionsPanel, 'Style', 'edit');
set(timeShiftEdit, 'Units', 'normalized');
set(timeShiftEdit, 'String', '0', 'Position',...
    [0.08181818181818182 0.03703703703703704 0.7545454545454546 0.07777777777777778],...
    'Background', [1 1 1],...
    'TooltipString', 'Enter time between adding treatments and the moment when the machine started measuring, it will have same units as input time unit');
handles = setTag(timeShiftEdit, handles, 'timeShift');

set(timeShiftEdit, 'Callback', createCallback('timeShift_Callback'));
% end of timeOptionsPanel

% Define the plate options panel

plateOptionsPanel = uipanel('Parent', mainPanel);
set(plateOptionsPanel, 'Units', 'normalized');
set(plateOptionsPanel, 'Title', 'Plate options',...
    'Position', [0.029197080291970802 0.2794676806083651 0.8394160583941606 0.15779467680608367],...
    'Background', [225/255 226/255 251/255]);
handles = setTag(plateOptionsPanel, handles, 'uipanel10');

% Define children of plate options panel

% Define plate name

plateName = uicontrol('Parent', plateOptionsPanel, 'Style', 'edit');
set(plateName, 'Units', 'normalized');
set(plateName,  'String', 'My_Plate', 'Position',...
    [0.08181818181818182 0.1492537313432836 0.7927927927927928 0.328358208955224],...
    'Background', [1 1 1],...
    'TooltipString', 'Enter the plate name');
handles = setTag(plateName, handles, 'plateName');

set(plateName, 'Callback', createCallback('plateName_Callback'));

% end of plateOptionsPanel

% Define the Save/Export panel

saveExportPanel = uipanel('Parent', mainPanel);
set(saveExportPanel, 'Units', 'normalized');
set(saveExportPanel, 'Title', 'Save/Export',...
    'Position', [0.0364963503649635 0.015209125475285171 0.9124087591240875 0.23954372623574147],...
    'Background', [225/255 226/255 251/255]);
handles = setTag(saveExportPanel, handles, 'uipanel11');


% Define children of Save/Export panel

% Define SaveMIDASFile button

saveMIDASFileButton = uicontrol('Parent', saveExportPanel, 'Style', 'pushbutton');
set(saveMIDASFileButton, 'Units', 'normalized');
set(saveMIDASFileButton, 'Position', [0.01652892561983471 0.7090909090909094 0.9504132231404959 0.28181818181818175],...
    'Background', [156/255 175/255 212/255],...
    'String', 'Save MIDAS file',...
    'TooltipString', 'Click to save MIDAS file in xls or csv format');
handles = setTag(saveMIDASFileButton, handles, 'SaveMIDASFile');

set(saveMIDASFileButton, 'Callback', createCallback('SaveMIDASFile_Callback'));

% Define moveToMIDASTools button

moveToMidasTools = uicontrol('Parent', saveExportPanel, 'Style', 'pushbutton');
set(moveToMidasTools, 'Units', 'normalized');
set(moveToMidasTools, 'Position', [0.01652892561983471 0.40909090909090934 0.9504132231404959 0.28181818181818175],...
    'Background', [156/255 175/255 212/255],...
    'String', 'Move to MIDAS tools',...
    'TooltipString', 'Move this MIDAS table to MIDASTools');
handles = setTag(moveToMidasTools, handles, 'moveToMidasTools');

set(moveToMidasTools, 'Callback', createCallback('moveToMidasTools_Callback'));

% Define moveToExportWizard button

moveToExportWizard = uicontrol('Parent', saveExportPanel, 'Style', 'pushbutton');
set(moveToExportWizard, 'Units', 'normalized');
set(moveToExportWizard, 'Position', [0.01652892561983471 0.1090909090909091 0.9504132231404959 0.28181818181818175],...
    'Background', [156/255 175/255 212/255],...
    'String', 'Move to Export wizard',...
    'TooltipString', 'Move the MIDAS file straight to Export wizard');
handles = setTag(moveToExportWizard, handles, 'pushbutton9');

set(moveToExportWizard, 'Callback', createCallback('moveToExportWizard_Callback'));

% end of Save/Export panel

% end of mainPanel

end

