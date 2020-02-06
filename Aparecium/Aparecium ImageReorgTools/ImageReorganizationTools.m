function varargout = ImageReorganizationTools(varargin)
% IMAGEREORGANIZATIONTOOLS M-file for ImageReorganizationTools.fig
%      IMAGEREORGANIZATIONTOOLS, by itself, creates a new IMAGEREORGANIZATIONTOOLS or raises the existing
%      singleton*.
%
%      H = IMAGEREORGANIZATIONTOOLS returns the handle to a new IMAGEREORGANIZATIONTOOLS or the handle to
%      the existing singleton*.
%
%      IMAGEREORGANIZATIONTOOLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGEREORGANIZATIONTOOLS.M with the given input arguments.
%
%      IMAGEREORGANIZATIONTOOLS('Property','Value',...) creates a new IMAGEREORGANIZATIONTOOLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageReorganizationTools_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageReorganizationTools_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageReorganizationTools

% Last Modified by GUIDE v2.5 06-Feb-2020 08:38:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageReorganizationTools_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageReorganizationTools_OutputFcn, ...
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


% --- Executes just before ImageReorganizationTools is made visible.
function ImageReorganizationTools_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageReorganizationTools (see VARARGIN)

% Choose default command line output for ImageReorganizationTools
handles.output = hObject;
handles.inputDirectory = [];
handles.outputDirectory = [];
handles.reorganizationLogic = 1;
% 1 - By timepoint
% 2 - By read
% 3 - By read and then timepoint
handles.nameSource = 1;
% 1 - use image names
% 2 - use OME-TIFF data
handles.copyOrCut = 1;
% 1 - cut and paste the data
% 2 - copy and paste the data
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ImageReorganizationTools wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ImageReorganizationTools_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in chooseStartingFolderButton.
function chooseStartingFolderButton_Callback(hObject, eventdata, handles)
% hObject    handle to chooseStartingFolderButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dir = uigetdir();
handles.inputDirectory = dir;
set(handles.inFolderName, 'String', handles.inputDirectory);
guidata(hObject, handles);

% --- Executes on button press in chooseDestinationFolderButton.
function chooseDestinationFolderButton_Callback(hObject, eventdata, handles)
% hObject    handle to chooseDestinationFolderButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dir = uigetdir();
handles.outputDirectory = dir;
set(handles.outFolderName, 'String', handles.outputDirectory);
guidata(hObject, handles);


function inFolderName_Callback(hObject, eventdata, handles)
% hObject    handle to inFolderName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inFolderName as text
%        str2double(get(hObject,'String')) returns contents of inFolderName as a double
handles.inputDirectory = get(hObject, 'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function inFolderName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inFolderName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function outFolderName_Callback(hObject, eventdata, handles)
% hObject    handle to outFolderName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outFolderName as text
%        str2double(get(hObject,'String')) returns contents of outFolderName as a double
handles.outputDirectory = get(hObject, 'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function outFolderName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outFolderName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in startReorganization.
function startReorganization_Callback(hObject, eventdata, handles)
% hObject    handle to startReorganization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    success = reorganizeImages(handles.inputDirectory, handles.outputDirectory, handles.reorganizationLogic, handles.nameSource, handles.copyOrCut);
catch MException
    success = 0;
end
if isequal(success, 1) 
    successBox('Images moved successfully!', 'Success');
else
    warndlg('Something went wrong with image moving', 'Fail');
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


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4
handles.reorganizationLogic = 3;
guidata(hObject, handles);

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
handles.reorganizationLogic = 1;
guidata(hObject, handles);

% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
handles.reorganizationLogic = 2;
guidata(hObject, handles);


% --- Executes on button press in cut.
function cut_Callback(hObject, eventdata, handles)
% hObject    handle to cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cut
handles.copyOrCut = 1;
guidata(hObject, handles);


% --- Executes on button press in copy.
function copy_Callback(hObject, eventdata, handles)
% hObject    handle to copy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of copy
handles.copyOrCut = 2;
guidata(hObject, handles);


% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5
handles.nameSource = 1;
guidata(hObject, handles);


% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton6
handles.nameSource = 2;
guidata(hObject, handles);