function varargout = defineNewChannel(varargin)
% DEFINENEWCHANNEL M-file for defineNewChannel.fig
%      DEFINENEWCHANNEL, by itself, creates a new DEFINENEWCHANNEL or raises the existing
%      singleton*.
%
%      H = DEFINENEWCHANNEL returns the handle to a new DEFINENEWCHANNEL or the handle to
%      the existing singleton*.
%
%      DEFINENEWCHANNEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEFINENEWCHANNEL.M with the given input arguments.
%
%      DEFINENEWCHANNEL('Property','Value',...) creates a new DEFINENEWCHANNEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before defineNewChannel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to defineNewChannel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help defineNewChannel

% Last Modified by GUIDE v2.5 05-Jun-2016 16:48:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @defineNewChannel_OpeningFcn, ...
                   'gui_OutputFcn',  @defineNewChannel_OutputFcn, ...
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


% --- Executes just before defineNewChannel is made visible.
function defineNewChannel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to defineNewChannel (see VARARGIN)

% Choose default command line output for defineNewChannel
handles.output = hObject;
handles.exitationFilter = [];
handles.emissionFilter = [];
handles.channelName = [];
% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1);
% UIWAIT makes defineNewChannel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = defineNewChannel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = [handles.exitationFilter,',', handles.emissionFilter];
displayName = regexprep([handles.exitationFilter,',', handles.emissionFilter],'EM ', '');
displayName = regexprep(displayName,'EX ', '');
displayName = regexprep(displayName,'FP ', '');
displayName = regexprep(displayName,'LUM ', '');
varargout{2} = displayName;
varargout{3} = handles.channelName;
delete(handles.figure1);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load NeoFilters.mat
filterNames = cell(0,0);
for filterIndex = 1 : numel(definedFilterStruct)
    filterNames{filterIndex} = definedFilterStruct(1, filterIndex).BTIBarcodeFilterCube(1,1).BTIBarcodeFilterPosition(1,1).PositionName;
end
[index, success] = listdlg('Name', 'Select the filter', 'ListString', filterNames, 'SelectionMode', 'single')
if success
    set(handles.text1, 'String', ['Chosen filter: ', filterNames{index}]);
    handles.exitationFilter = filterNames{index};
end

guidata(hObject, handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load NeoFilters.mat
filterNames = cell(0,0);
for filterIndex = 1 : numel(definedFilterStruct)
    filterNames{filterIndex} = definedFilterStruct(1, filterIndex).BTIBarcodeFilterCube(1,1).BTIBarcodeFilterPosition(1,1).PositionName;
end
[index, success] = listdlg('Name', 'Select the filter', 'ListString', filterNames, 'SelectionMode', 'single')
if success
    
end
set(handles.text2, 'String', ['Chosen filter: ', filterNames{index}]);
handles.emissionFilter = filterNames{index};

guidata(hObject, handles);

% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(get(handles.figure1, 'waitstatus'),'waiting')
    uiresume(handles.figure1)
else
    delete(handles.figure1);
end

% --- Executes on button press in importFilters.
function importFilters_Callback(hObject, eventdata, handles)
% hObject    handle to importFilters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.xml'}, 'Pick a filter cube describing XML file');
fileName = [pathname, filename];
importNewFilters(fileName);

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
handles.channelName = get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
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



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
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

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'),'waiting')
    uiresume(hObject)
else
    delete(hObject);
end
