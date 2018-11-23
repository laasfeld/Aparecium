function varargout = SBStateNameOptions(varargin)
%SBSTATENAMEOPTIONS MATLAB code file for SBStateNameOptions.fig
%      SBSTATENAMEOPTIONS, by itself, creates a new SBSTATENAMEOPTIONS or raises the existing
%      singleton*.
%
%      H = SBSTATENAMEOPTIONS returns the handle to a new SBSTATENAMEOPTIONS or the handle to
%      the existing singleton*.
%
%      SBSTATENAMEOPTIONS('Property','Value',...) creates a new SBSTATENAMEOPTIONS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to SBStateNameOptions_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SBSTATENAMEOPTIONS('CALLBACK') and SBSTATENAMEOPTIONS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SBSTATENAMEOPTIONS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SBStateNameOptions

% Last Modified by GUIDE v2.5 12-Nov-2018 12:06:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SBStateNameOptions_OpeningFcn, ...
                   'gui_OutputFcn',  @SBStateNameOptions_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before SBStateNameOptions is made visible.
function SBStateNameOptions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for SBStateNameOptions
handles.output = hObject;

updateChannelsList(handles)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SBStateNameOptions wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SBStateNameOptions_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function updateChannelsList(handles)
channelNames = MIDAS2SBNameManager.getChannels();
names = cell(0, 0);
for channel = 1 : numel(channelNames)
   names{channel} = channelNames(channel).channelName;
end
set(handles.listbox1, 'String', names);

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
index = get(hObject,'Value');
channelNames = MIDAS2SBNameManager.getChannels();
set(handles.standardName, 'String', channelNames(index).MIDASChannelName);
try
    if ~isempty(channelNames(index).includeDefault) 
        set(handles.includeByDefault, 'Value', channelNames(index).includeDefault);
    else
        warndlg('Could not find default include information. Using include as default');
        set(handles.includeByDefault, 'Value', true);
    end
catch
    set(handles.includeByDefault, 'Value', true);
end
try
    if strcmp(channelNames(index).stateOrParam, 'state')
        set(handles.stateButton, 'Value', true);
    elseif strcmp(channelNames(index).stateOrParam, 'param')
        set(handles.paramButton, 'Value', true);
    else
        warndlg('Could not find state or parameter information. Using state as default');
        set(handles.stateButton, 'Value', true);
    end
catch
    warndlg('Could not find state or parameter information. Using state as default');
    set(handles.stateButton, 'Value', true);
end

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



function standardName_Callback(hObject, eventdata, handles)
% hObject    handle to standardName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of standardName as text
%        str2double(get(hObject,'String')) returns contents of standardName as a double
newName = get(hObject,'String');
index = get(handles.listbox1,'Value');
MIDAS2SBNameManager.changeMIDASChannelName(index, newName);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function standardName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to standardName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
channelName = inputdlg('Enter new channel (Copy and paste it from the .txt file)','New channel name');
MIDAS2SBNameManager.addNewChannel(channelName{1}, channelName{1}, 'state', true);
updateChannelsList(handles);
guidata(hObject, handles)

% --- Executes on button press in deleteChannel.
function deleteChannel_Callback(hObject, eventdata, handles)
% hObject    handle to deleteChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = get(handles.listbox1,'Value');
MIDAS2SBNameManager.deleteChannel(index);
updateChannelsList(handles);
if index > numel(MIDAS2SBNameManager.getChannels())
    set(handles.listbox1, 'Value', numel(MIDAS2SBNameManager.getChannels()));
end
listbox1_Callback(handles.listbox1, '', handles)


% --- Executes on button press in includeByDefault.
function includeByDefault_Callback(hObject, eventdata, handles)
% hObject    handle to includeByDefault (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of includeByDefault
index = get(handles.listbox1,'Value');
MIDAS2SBNameManager.changeDefaultInclude(index, get(hObject,'Value'));
guidata(hObject, handles);

% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.stateButton, 'Value')
    newStateOrParam = 'state';
else
    newStateOrParam = 'param';
end
index = get(handles.listbox1,'Value');
MIDAS2SBNameManager.changeStateOrParam(index, newStateOrParam);
guidata(hObject, handles);
