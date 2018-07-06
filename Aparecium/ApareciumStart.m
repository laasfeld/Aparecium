function varargout = ApareciumStart(varargin)
% APARECIUMSTART M-file for ApareciumStart.fig
%      APARECIUMSTART, by itself, creates a new APARECIUMSTART or raises the existing
%      singleton*.
%
%      H = APARECIUMSTART returns the handle to a new APARECIUMSTART or the handle to
%      the existing singleton*.
%
%      APARECIUMSTART('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in APARECIUMSTART.M with the given input arguments.
%
%      APARECIUMSTART('Property','Value',...) creates a new APARECIUMSTART or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ApareciumStart_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ApareciumStart_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ApareciumStart

% Last Modified by GUIDE v2.5 05-Jan-2018 00:55:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ApareciumStart_OpeningFcn, ...
                   'gui_OutputFcn',  @ApareciumStart_OutputFcn, ...
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


% --- Executes just before ApareciumStart is made visible.
function ApareciumStart_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ApareciumStart (see VARARGIN)

% Choose default command line output for ApareciumStart
handles.output = hObject;
addApareciumToPath();
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ApareciumStart wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ApareciumStart_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in BMGTools.
function BMGTools_Callback(hObject, eventdata, handles)
% hObject    handle to BMGTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.figure1, 'visible' ,'off');
BMGTools();


% --- Executes on button press in neoTools.
function neoTools_Callback(hObject, eventdata, handles)
% hObject    handle to neoTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.figure1, 'visible' ,'off');
Gen5Tools();

% --- Executes on button press in ICSETools.
function ICSETools_Callback(hObject, eventdata, handles)
% hObject    handle to ICSETools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.figure1, 'visible' ,'off');
ICSETools();

% --- Executes on button press in midasTools.
function midasTools_Callback(hObject, eventdata, handles)
% hObject    handle to midasTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.figure1, 'visible' ,'off');
MIDASTools();

% --------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)
% hObject    handle to file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function openHelp_Callback(hObject, eventdata, handles)
% hObject    handle to openHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
openApareciumHelp();

% --------------------------------------------------------------------
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);

% --- Executes during object creation, after setting all properties.
function midasTools_CreateFcn(hObject, eventdata, handles)
% hObject    handle to midasTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns
addApareciumToPath();
handles.MIDASTools = hObject;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function BMGTools_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BMGTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.BMGTools = hObject;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function neoTools_CreateFcn(hObject, eventdata, handles)
% hObject    handle to neoTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.neoTools = hObject;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ICSETools_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ICSETools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.ICSETools = hObject;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.figure1 = hObject;
guidata(hObject, handles);


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.figure1, 'visible' ,'off');
PerkinElmerTools();

% --- Executes during object creation, after setting all properties.
function pushbutton14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.perkinElmerTools = hObject;
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.figure1, 'visible' ,'off');
MembraneTools();

% --- Executes during object creation, after setting all properties.
function pushbutton15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.membraneTools = hObject;
guidata(hObject, handles)


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.figure1, 'visible' ,'off');
ImageReorganizationTools();



% --- Executes during object creation, after setting all properties.
function pushbutton16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.imageReorganizationTools = hObject;
guidata(hObject, handles);
