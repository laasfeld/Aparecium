function varargout = newProject(varargin)
% NEWPROJECT MATLAB code for newProject.fig
%      NEWPROJECT, by itself, creates a new NEWPROJECT or raises the existing
%      singleton*.
%
%      H = NEWPROJECT returns the handle to a new NEWPROJECT or the handle to
%      the existing singleton*.
%
%      NEWPROJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEWPROJECT.M with the given input arguments.
%
%      NEWPROJECT('Property','Value',...) creates a new NEWPROJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before newProject_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to newProject_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help newProject

% Last Modified by GUIDE v2.5 21-Jan-2018 15:38:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @newProject_OpeningFcn, ...
                   'gui_OutputFcn',  @newProject_OutputFcn, ...
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


% --- Executes just before newProject is made visible.
function newProject_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to newProject (see VARARGIN)

% Choose default command line output for newProject
handles.projectName = 'New project';
handles.projectLocation = 'C:\';
fullPath = [mfilename('fullpath'),'RANDOM556874'];
if isdeployed
    handles.folderPath = [pwd, '\'];
else  
    handles.folderPath = regexprep(fullPath, 'newProjectRANDOM556874','', 'once');
end
handles.folderImg = imread([regexprep(fullPath, 'newProjectRANDOM556874','\..\\Icons\', 'once'),'folder.png']);
set(handles.chooseFolderButton, 'cdata', handles.folderImg);

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes newProject wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = newProject_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function projectNameField_Callback(hObject, eventdata, handles)
% hObject    handle to projectNameField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of projectNameField as text
%        str2double(get(hObject,'String')) returns contents of projectNameField as a double
handles.projectName = get(hObject, 'String');
guidata(hObject, handleS);

% --- Executes during object creation, after setting all properties.
function projectNameField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to projectNameField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function projectLocationField_Callback(hObject, eventdata, handles)
% hObject    handle to projectLocationField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of projectLocationField as text
%        str2double(get(hObject,'String')) returns contents of projectLocationField as a double


% --- Executes during object creation, after setting all properties.
function projectLocationField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to projectLocationField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in openSettings.
function openSettings_Callback(hObject, eventdata, handles)
% hObject    handle to openSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in doneButton.
function doneButton_Callback(hObject, eventdata, handles)
% hObject    handle to doneButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in chooseFolderButton.
function chooseFolderButton_Callback(hObject, eventdata, handles)
% hObject    handle to chooseFolderButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
