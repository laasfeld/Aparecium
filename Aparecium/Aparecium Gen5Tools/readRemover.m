function varargout = readRemover(varargin)
% READREMOVER M-file for readRemover.fig
%      READREMOVER, by itself, creates a new READREMOVER or raises the existing
%      singleton*.
%
%      H = READREMOVER returns the handle to a new READREMOVER or the handle to
%      the existing singleton*.
%
%      READREMOVER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in READREMOVER.M with the given input arguments.
%
%      READREMOVER('Property','Value',...) creates a new READREMOVER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before readRemover_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to readRemover_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help readRemover

% Last Modified by GUIDE v2.5 01-Jan-2010 13:26:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @readRemover_OpeningFcn, ...
                   'gui_OutputFcn',  @readRemover_OutputFcn, ...
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


% --- Executes just before readRemover is made visible.
function readRemover_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to readRemover (see VARARGIN)

% Choose default command line output for readRemover
handles.output = hObject;

handles.startingReads = varargin{1};
handles.currentReads = handles.startingReads;
handles.indicesToDisplay = 1 : numel(handles.startingReads);
handles.indexingMode = 'Easy';
handles.startingIndex = 1;
handles.interval = 1;
handles.startingIndex = 1;
handles.interval = 1;
handles.endingIndex = 1;

set(handles.intervalBox, 'String', handles.interval);
set(handles.startIndexBox, 'String', handles.startingIndex);
set(handles.endIndexBox, 'String', handles.endingIndex);
set(handles.readRemoval, 'String', handles.startingReads);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes readRemover wait for user response (see UIRESUME)
% uiwait(handles.figure1);
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = readRemover_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles.output = handles.indicesToDisplay;
varargout{1} = handles.output;

delete(handles.figure1);


% --- Executes on selection change in readRemoval.
function readRemoval_Callback(hObject, eventdata, handles)
% hObject    handle to readRemoval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns readRemoval contents as cell array
%        contents{get(hObject,'Value')} returns selected item from readRemoval


% --- Executes during object creation, after setting all properties.
function readRemoval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to readRemoval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'max', 2)% this allows selection of multiple lines
guidata(hObject, handles);


% --- Executes on button press in removeSelectedButton.
function removeSelectedButton_Callback(hObject, eventdata, handles)
% hObject    handle to removeSelectedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectedItems = get(handles.readRemoval, 'Value');
handles.indicesToDisplay(selectedItems) = [];
set(handles.readRemoval, 'Value', 1);
handles = updateListboxToIndices(handles);
guidata(hObject, handles);


function handles = updateListboxToIndices(handles)

handles.currentReads = handles.startingReads(handles.indicesToDisplay);
set(handles.readRemoval, 'String', handles.currentReads);


% --- Executes on button press in keepSelectedButton.
function keepSelectedButton_Callback(hObject, eventdata, handles)
% hObject    handle to keepSelectedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectedItems = get(handles.readRemoval, 'Value');
handles.indicesToDisplay = handles.indicesToDisplay(selectedItems);
set(handles.readRemoval, 'Value', 1);
handles = updateListboxToIndices(handles);
guidata(hObject, handles);

% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(get(handles.figure1, 'waitstatus'),'waiting')
    uiresume(handles.figure1)
end

% --- Executes on button press in resetToOriginalButton.
function resetToOriginalButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetToOriginalButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.indicesToDisplay = 1 : numel(handles.startingReads);
handles = updateListboxToIndices(handles);
guidata(hObject, handles);


function intervalBox_Callback(hObject, eventdata, handles)
% hObject    handle to intervalBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intervalBox as text
%        str2double(get(hObject,'String')) returns contents of intervalBox as a double
if isempty(str2num(get(hObject, 'String')))
    warndlg('Please enter a number');
elseif str2num(get(hObject, 'String')) == 0
    warndlg('The interval must be an integer other than 0');
else
    handles.interval = str2num(get(hObject, 'String'));
end
set(handles.readRemoval, 'Value', handles.startingIndex:handles.interval:handles.endingIndex);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function intervalBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intervalBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startIndexBox_Callback(hObject, eventdata, handles)
% hObject    handle to startIndexBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startIndexBox as text
%        str2double(get(hObject,'String')) returns contents of startIndexBox as a double
if isempty(str2num(get(hObject, 'String')))
    if strcmp(get(hObject, 'String'), 'end')
        handles.endingIndex = numel(handles.indicesToDisplay);
    else
        warndlg('Please enter a number');
    end
elseif str2num(get(hObject, 'String')) < 0
    warndlg(['Index out of bounds. Possible values range from 1 to ', num2str(numel(handles.indicesToDisplay))]);
elseif str2num(get(hObject, 'String')) > numel(handles.indicesToDisplay)
    warndlg(['Index out of bounds. Possible values range from 1 to ', num2str(numel(handles.indicesToDisplay))]);
else
    handles.startingIndex = str2num(get(hObject, 'String'));
end
set(handles.readRemoval, 'Value', handles.startingIndex:handles.interval:handles.endingIndex);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function startIndexBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startIndexBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endIndexBox_Callback(hObject, eventdata, handles)
% hObject    handle to endIndexBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endIndexBox as text
%        str2double(get(hObject,'String')) returns contents of endIndexBox as a double
if isempty(str2num(get(hObject, 'String')))
    if strcmp(get(hObject, 'String'), 'end')
       handles.endingIndex = numel(handles.indicesToDisplay);
    else
        warndlg('Please enter a number');
    end
elseif str2num(get(hObject, 'String')) < 0
    warndlg(['Index out of bounds. Possible values range from 1 to ', num2str(numel(handles.indicesToDisplay)), ' and keyword end']);
elseif str2num(get(hObject, 'String')) > numel(handles.indicesToDisplay)
    warndlg(['Index out of bounds. Possible values range from 1 to ', num2str(numel(handles.indicesToDisplay)), ' and keyword end']);
else
    handles.endingIndex = str2num(get(hObject, 'String'));
end
set(handles.readRemoval, 'Value', handles.startingIndex:handles.interval:handles.endingIndex);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function endIndexBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endIndexBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function indicesBox_Callback(hObject, eventdata, handles)
% hObject    handle to indicesBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of indicesBox as text
%        str2double(get(hObject,'String')) returns contents of indicesBox as a double
indices = 1 : numel(cellstr(get(handles.readRemoval,'String')));
set(handles.readRemoval, 'Value', eval(['indices(', get(hObject,'String'), ')'])); 
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function indicesBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to indicesBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uipanel1.
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel1 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
if isequal(eventdata.NewValue, handles.easyButton)
   set(handles.indicesBox, 'Enable', 'off');
   set(handles.intervalBox, 'Enable', 'on');
   set(handles.startIndexBox, 'Enable', 'on');
   set(handles.endIndexBox, 'Enable', 'on');
elseif isequal(eventdata.NewValue, handles.matlabStyleButton)
   set(handles.indicesBox, 'Enable', 'on'); 
   set(handles.intervalBox, 'Enable', 'off');
   set(handles.startIndexBox, 'Enable', 'off');
   set(handles.endIndexBox, 'Enable', 'off');
end
guidata(hObject, handles);
