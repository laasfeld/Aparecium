function varargout = listboxSelectionAdvanced(varargin)
% LISTBOXSELECTIONADVANCED MATLAB code for listboxSelectionAdvanced.fig
%      LISTBOXSELECTIONADVANCED, by itself, creates a new LISTBOXSELECTIONADVANCED or raises the existing
%      singleton*.
%
%      H = LISTBOXSELECTIONADVANCED returns the handle to a new LISTBOXSELECTIONADVANCED or the handle to
%      the existing singleton*.
%
%      LISTBOXSELECTIONADVANCED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LISTBOXSELECTIONADVANCED.M with the given input arguments.
%
%      LISTBOXSELECTIONADVANCED('Property','Value',...) creates a new LISTBOXSELECTIONADVANCED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before listboxSelectionAdvanced_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to listboxSelectionAdvanced_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help listboxSelectionAdvanced

% Last Modified by GUIDE v2.5 17-Sep-2018 14:37:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @listboxSelectionAdvanced_OpeningFcn, ...
                   'gui_OutputFcn',  @listboxSelectionAdvanced_OutputFcn, ...
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


% --- Executes just before listboxSelectionAdvanced is made visible.
function listboxSelectionAdvanced_OpeningFcn(hObject, eventdata, handles, exportTimeMomentController)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to listboxSelectionAdvanced (see VARARGIN)

% Choose default command line output for listboxSelectionAdvanced
handles.output = hObject;

handles.indexingMode = 'Easy'; % manual for selecting from listbox, indexes for selecting from index box and periodic for selecting from the interval and starting index box
handles.startingIndex = 1;
handles.interval = 1;
handles.exportTimeMomentController = exportTimeMomentController;
handles.exportTimeMomentController.changeCycleListHandle(handles.timeRemoval);
handles.exportTimeMomentController.updateTable();

handles.startingIndex = 1;
handles.interval = 1;
handles.endingIndex = 1;

set(handles.intervalBox, 'String', handles.interval);
set(handles.startIndexBox, 'String', handles.startingIndex);
set(handles.endIndexBox, 'String', handles.endingIndex);

set(handles.timeRemoval, 'Value', handles.startingIndex:handles.interval:handles.endingIndex);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes listboxSelectionAdvanced wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function listboxSelectionAdvanced_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

delete(handles.figure1);


% --- Executes on selection change in timeRemoval.
function timeRemoval_Callback(hObject, eventdata, handles)
% hObject    handle to timeRemoval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns timeRemoval contents as cell array
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



function indicesBox_Callback(hObject, eventdata, handles)
% hObject    handle to indicesBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of indicesBox as text
%        str2double(get(hObject,'String')) returns contents of indicesBox as a double
indices = 1 : numel(cellstr(get(handles.timeRemoval,'String')));
set(handles.timeRemoval, 'Value', eval(['indices(', get(hObject,'String'), ')'])); 

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
set(handles.timeRemoval, 'Value', handles.startingIndex:handles.interval:handles.endingIndex);
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


% --- Executes on button press in removeSelectedButton.
function removeSelectedButton_Callback(hObject, eventdata, handles)
% hObject    handle to removeSelectedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.exportTimeMomentController.removeSelectedCycles();
guidata(hObject, handles);

% --- Executes on button press in keepSelectedButton.
function keepSelectedButton_Callback(hObject, eventdata, handles)
% hObject    handle to keepSelectedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.exportTimeMomentController.removeDeselectedCycles();
guidata(hObject, handles);

% --- Executes on selection change in outputTimeUnitDropdown.
function outputTimeUnitDropdown_Callback(hObject, eventdata, handles)
% hObject    handle to outputTimeUnitDropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns outputTimeUnitDropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from outputTimeUnitDropdown
contents = get(hObject,'String');
unit = contents{get(hObject,'Value')};
handles.exportTimeMomentController.setTimeUnit(unit);
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



function startIndexBox_Callback(hObject, eventdata, handles)
% hObject    handle to startIndexBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startIndexBox as text
%        str2double(get(hObject,'String')) returns contents of startIndexBox as a double
if isempty(str2num(get(hObject, 'String')))
    if strcmp(get(hObject, 'String'), 'end')
        handles.endingIndex = numel(handles.exportTimeMomentController.getCyclesInUse());
    else
        warndlg('Please enter a number');
    end
elseif str2num(get(hObject, 'String')) < 0
    warndlg(['Index out of bounds. Possible values range from 1 to ', num2str(numel(handles.exportTimeMomentController.getCyclesInUse()))]);
elseif str2num(get(hObject, 'String')) > numel(handles.exportTimeMomentController.getCyclesInUse())
    warndlg(['Index out of bounds. Possible values range from 1 to ', num2str(numel(handles.exportTimeMomentController.getCyclesInUse()))]);
else
    handles.startingIndex = str2num(get(hObject, 'String'));
end
set(handles.timeRemoval, 'Value', handles.startingIndex:handles.interval:handles.endingIndex);
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
       handles.endingIndex = numel(handles.exportTimeMomentController.getCyclesInUse());
    else
        warndlg('Please enter a number');
    end
elseif str2num(get(hObject, 'String')) < 0
    warndlg(['Index out of bounds. Possible values range from 1 to ', num2str(numel(handles.exportTimeMomentController.getCyclesInUse())), ' and keyword end']);
elseif str2num(get(hObject, 'String')) > numel(handles.exportTimeMomentController.getCyclesInUse())
    warndlg(['Index out of bounds. Possible values range from 1 to ', num2str(numel(handles.exportTimeMomentController.getCyclesInUse())), ' and keyword end']);
else
    handles.endingIndex = str2num(get(hObject, 'String'));
end
set(handles.timeRemoval, 'Value', handles.startingIndex:handles.interval:handles.endingIndex);
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


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(get(handles.figure1, 'waitstatus'),'waiting')
    uiresume(handles.figure1)
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.exportTimeMomentController.resetToExperiment();
set(handles.outputTimeUnitDropdown, 'Value', 2); 
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
