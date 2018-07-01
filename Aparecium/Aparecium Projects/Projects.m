function varargout = Projects(varargin)
% PROJECTS MATLAB code for Projects.fig
%      PROJECTS, by itself, creates a new PROJECTS or raises the existing
%      singleton*.
%
%      H = PROJECTS returns the handle to a new PROJECTS or the handle to
%      the existing singleton*.
%
%      PROJECTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECTS.M with the given input arguments.
%
%      PROJECTS('Property','Value',...) creates a new PROJECTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Projects_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Projects_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Projects

% Last Modified by GUIDE v2.5 20-Jan-2018 16:59:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Projects_OpeningFcn, ...
                   'gui_OutputFcn',  @Projects_OutputFcn, ...
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


% --- Executes just before Projects is made visible.
function Projects_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Projects (see VARARGIN)

% Choose default command line output for Projects
handles.output = hObject;
projects = [];
load('projects.mat');
handles.projects = projects;
handles = setProjectListboxContents(handles);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Projects wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Projects_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function handles = setProjectListboxContents(handles)
allData = struct2cell(handles.projects);
set(handles.Projects_listbox, 'String', allData(:, :, 1));


% --- Executes on button press in createNew.
function createNew_Callback(hObject, eventdata, handles)
% hObject    handle to createNew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in Projects_listbox.
function Projects_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Projects_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Projects_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Projects_listbox


% --- Executes during object creation, after setting all properties.
function Projects_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Projects_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in editSelected.
function editSelected_Callback(hObject, eventdata, handles)
% hObject    handle to editSelected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in setAsDefault.
function setAsDefault_Callback(hObject, eventdata, handles)
% hObject    handle to setAsDefault (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
