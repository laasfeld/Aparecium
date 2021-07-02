function varargout = ChooseOutlierFolders(varargin)
% CHOOSEOUTLIERFOLDERS MATLAB code for ChooseOutlierFolders.fig
%      CHOOSEOUTLIERFOLDERS, by itself, creates a new CHOOSEOUTLIERFOLDERS or raises the existing
%      singleton*.
%
%      H = CHOOSEOUTLIERFOLDERS returns the handle to a new CHOOSEOUTLIERFOLDERS or the handle to
%      the existing singleton*.
%
%      CHOOSEOUTLIERFOLDERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHOOSEOUTLIERFOLDERS.M with the given input arguments.
%
%      CHOOSEOUTLIERFOLDERS('Property','Value',...) creates a new CHOOSEOUTLIERFOLDERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ChooseOutlierFolders_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ChooseOutlierFolders_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ChooseOutlierFolders

% Last Modified by GUIDE v2.5 03-Dec-2020 21:39:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChooseOutlierFolders_OpeningFcn, ...
                   'gui_OutputFcn',  @ChooseOutlierFolders_OutputFcn, ...
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


% --- Executes just before ChooseOutlierFolders is made visible.
function ChooseOutlierFolders_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ChooseOutlierFolders (see VARARGIN)

% Choose default command line output for ChooseOutlierFolders

set(handles.includedFolders, 'String', varargin{1});
handles.allFolders = varargin{1};
handles.namesToIndices = containers.Map;
for folderIndex = 1 : numel(varargin{1})
    handles.namesToIndices(varargin{1}{folderIndex}) = folderIndex;
end
set(handles.excludedFolders, 'Value', []);

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ChooseOutlierFolders wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ChooseOutlierFolders_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

values = get(handles.includedFolders, 'Value');
names = get(handles.includedFolders, 'String');
origValues = zeros(1, numel(names));
for index = 1 : numel(names)
    origValues(index) = handles.namesToIndices(names{index});
end
origValues = sort(origValues);
varargout{1} = origValues;
guidata(hObject, handles);
delete(hObject);


% --- Executes on selection change in includedFolders.
function includedFolders_Callback(hObject, eventdata, handles)
% hObject    handle to includedFolders (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns includedFolders contents as cell array
%        contents{get(hObject,'Value')} returns selected item from includedFolders


% --- Executes during object creation, after setting all properties.
function includedFolders_CreateFcn(hObject, eventdata, handles)
% hObject    handle to includedFolders (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in excludedFolders.
function excludedFolders_Callback(hObject, eventdata, handles)
% hObject    handle to excludedFolders (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns excludedFolders contents as cell array
%        contents{get(hObject,'Value')} returns selected item from excludedFolders


% --- Executes during object creation, after setting all properties.
function excludedFolders_CreateFcn(hObject, eventdata, handles)
% hObject    handle to excludedFolders (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function handles = moveNames(sourceHandle, targetHandle, handles)

values = get(sourceHandle, 'Value');
names = get(sourceHandle, 'String');
origValues = zeros(numel(values) + numel(get(targetHandle, 'Value')), 1);
for index = 1 : numel(values)
    origValues(index) = handles.namesToIndices(names{values(index)});
end
excludedNames = get(targetHandle, 'String');
counter = 1;
for index = numel(values) + 1 : numel(get(targetHandle, 'String')) + numel(values)
    origValues(index) = handles.namesToIndices(excludedNames{counter});
    counter = counter + 1;
end
allValues = cell2mat(handles.namesToIndices.values);
foldersToInclude = setdiff(allValues, origValues);
foldersToInclude = sort(foldersToInclude);
origValues = sort(origValues);
set(targetHandle, 'String', handles.allFolders(origValues));
set(sourceHandle, 'String', handles.allFolders(foldersToInclude));
set(sourceHandle, 'Value', []);

% --- Executes on button press in Exclude.
function Exclude_Callback(hObject, eventdata, handles)
% hObject    handle to Exclude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = moveNames(handles.includedFolders, handles.excludedFolders, handles);

guidata(hObject, handles);

% --- Executes on button press in Include.
function Include_Callback(hObject, eventdata, handles)
% hObject    handle to Include (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = moveNames(handles.excludedFolders, handles.includedFolders, handles);
guidata(hObject, handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);
if isequal(get(handles.figure1, 'waitstatus'),'waiting')
    uiresume(handles.figure1)
else
    delete(handles.figure1);
end
