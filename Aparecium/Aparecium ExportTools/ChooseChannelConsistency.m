function varargout = ChooseChannelConsistency(varargin)
% CHOOSECHANNELCONSISTENCY M-file for ChooseChannelConsistency.fig
%      CHOOSECHANNELCONSISTENCY, by itself, creates a new CHOOSECHANNELCONSISTENCY or raises the existing
%      singleton*.
%
%      H = CHOOSECHANNELCONSISTENCY returns the handle to a new CHOOSECHANNELCONSISTENCY or the handle to
%      the existing singleton*.
%
%      CHOOSECHANNELCONSISTENCY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHOOSECHANNELCONSISTENCY.M with the given input arguments.
%
%      CHOOSECHANNELCONSISTENCY('Property','Value',...) creates a new CHOOSECHANNELCONSISTENCY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ChooseChannelConsistency_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ChooseChannelConsistency_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ChooseChannelConsistency

% Last Modified by GUIDE v2.5 17-Jul-2017 22:15:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChooseChannelConsistency_OpeningFcn, ...
                   'gui_OutputFcn',  @ChooseChannelConsistency_OutputFcn, ...
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


% --- Executes just before ChooseChannelConsistency is made visible.
function ChooseChannelConsistency_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ChooseChannelConsistency (see VARARGIN)

% Choose default command line output for ChooseChannelConsistency
handles.output = hObject;
handles.MIDASChannels = varargin{1};
handles.formulaChannels = varargin{2};
set(handles.uitable1, 'data', [handles.formulaChannels', handles.MIDASChannels(1:numel(handles.formulaChannels))']);
%set(handles.uitable1, 'data', [handles.formulaChannels', handles.formulaChannels'])
set(handles.uitable1,'ColumnFormat', {'numeric', handles.MIDASChannels});
% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1);

% UIWAIT makes ChooseChannelConsistency wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ChooseChannelConsistency_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.outputTable;
delete(handles.figure1);


% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
aa = 0;

% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data  = get(handles.uitable1, 'data');
midasTable = data(:,2)';

for midasChannel = 1 : size(data, 1)
    for originalMidasChannel = 1 : numel(handles.MIDASChannels)
        if strcmp(data{midasChannel, 2}, handles.MIDASChannels{originalMidasChannel})
            handles.outputTable{originalMidasChannel, 1} = data{midasChannel, 1}
        end
    end
end
handles.outputTable = handles.outputTable'        
% check if all channels are different
uniqueChannels = 1;
for firstChannel = 1 : numel(midasTable)
    for secondChannel = firstChannel + 1 : numel(midasTable)
        if strcmp(midasTable{firstChannel}, midasTable{secondChannel})
            uniqueChannels = 0;
            handles.outputTable = '';
        end
    end
end
if isequal(uniqueChannels, 0) 
    answer = questdlg('With current selection one or more MIDAS channels correspond to more than one channel in the formula. Would you like to abort function loading or correct the channels ?', 'Question', 'Abort', 'Correct channels', 'Correct channels');
    switch answer
        case 'Abort'
            
        case 'Correct channels'
            return;
    end          
end
%set(handles.text1,'String',ans)
guidata(hObject, handles);
if isequal(get(handles.figure1, 'waitstatus'),'waiting')
    uiresume(handles.figure1)
else
    delete(handles.figure1);
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
handles.outputTable = '';
guidata(hObject, handles);
if isequal(get(hObject, 'waitstatus'),'waiting')
    uiresume(hObject)
else
    delete(hObject);
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
