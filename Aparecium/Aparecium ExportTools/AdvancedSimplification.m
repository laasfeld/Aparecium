function varargout = AdvancedSimplification(varargin)
% ADVANCEDSIMPLIFICATION MATLAB code for AdvancedSimplification.fig
%      ADVANCEDSIMPLIFICATION, by itself, creates a new ADVANCEDSIMPLIFICATION or raises the existing
%      singleton*.
%
%      H = ADVANCEDSIMPLIFICATION returns the handle to a new ADVANCEDSIMPLIFICATION or the handle to
%      the existing singleton*.
%
%      ADVANCEDSIMPLIFICATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADVANCEDSIMPLIFICATION.M with the given input arguments.
%
%      ADVANCEDSIMPLIFICATION('Property','Value',...) creates a new ADVANCEDSIMPLIFICATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AdvancedSimplification_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AdvancedSimplification_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AdvancedSimplification

% Last Modified by GUIDE v2.5 14-Jan-2020 15:57:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AdvancedSimplification_OpeningFcn, ...
                   'gui_OutputFcn',  @AdvancedSimplification_OutputFcn, ...
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


% --- Executes just before AdvancedSimplification is made visible.
function AdvancedSimplification_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AdvancedSimplification (see VARARGIN)

% Choose default command line output for AdvancedSimplification
handles.apareciumExperimentInput = varargin{1};
handles.subgroupNames = varargin{2};
uniqueSubgroupNames = [];
for group = 1 : numel(handles.subgroupNames)
    uniqueSubgroupNames = unique([uniqueSubgroupNames, cell(handles.subgroupNames(group))]);
end
set(handles.groupList, 'String', handles.apareciumExperimentInput.getGroups());
set(handles.subgroupList, 'String', uniqueSubgroupNames);
set(handles.wellsList, 'String', handles.apareciumExperimentInput.getWells());
treatmentsWrapped = handles.apareciumExperimentInput.getTreatments();
treatmentsCell = cell(numel(treatmentsWrapped), 1);
for treatment = 1 : numel(treatmentsWrapped)
    treatmentsCell{treatment} = treatmentsWrapped{treatment}{1};
end
handles.simplificationMap = containers.Map;
wellNames = handles.apareciumExperimentInput.getWells();
for well = 1 : numel(handles.apareciumExperimentInput.getWells())
    handles.simplificationStructure(wellNames{well}) = struct();
end
set(handles.componentsList, 'String', treatmentsCell);


handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AdvancedSimplification wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AdvancedSimplification_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in componentsList.
function componentsList_Callback(hObject, eventdata, handles)
% hObject    handle to componentsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns componentsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from componentsList
set(hObject, 'max', 2)% this allows selection of multiple lines

% --- Executes during object creation, after setting all properties.
function componentsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to componentsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in wellsList.
function wellsList_Callback(hObject, eventdata, handles)
% hObject    handle to wellsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns wellsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from wellsList


% --- Executes during object creation, after setting all properties.
function wellsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wellsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'max', 2)% this allows selection of multiple lines


% --- Executes on selection change in subgroupList.
function subgroupList_Callback(hObject, eventdata, handles)
% hObject    handle to subgroupList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns subgroupList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from subgroupList


% --- Executes during object creation, after setting all properties.
function subgroupList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subgroupList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'max', 2)% this allows selection of multiple lines


% --- Executes on selection change in groupList.
function groupList_Callback(hObject, eventdata, handles)
% hObject    handle to groupList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns groupList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from groupList


% --- Executes during object creation, after setting all properties.
function groupList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to groupList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'max', 2)% this allows selection of multiple lines



function eventFromBeginning_Callback(hObject, eventdata, handles)
% hObject    handle to eventFromBeginning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eventFromBeginning as text
%        str2double(get(hObject,'String')) returns contents of eventFromBeginning as a double


% --- Executes during object creation, after setting all properties.
function eventFromBeginning_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eventFromBeginning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
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
