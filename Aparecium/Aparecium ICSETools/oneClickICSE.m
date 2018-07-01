function varargout = oneClickICSE(varargin)
% ONECLICKICSE M-file for oneClickICSE.fig
%      ONECLICKICSE, by itself, creates a new ONECLICKICSE or raises the existing
%      singleton*.
%
%      H = ONECLICKICSE returns the handle to a new ONECLICKICSE or the handle to
%      the existing singleton*.
%
%      ONECLICKICSE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ONECLICKICSE.M with the given input arguments.
%
%      ONECLICKICSE('Property','Value',...) creates a new ONECLICKICSE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before oneClickICSE_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to oneClickICSE_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help oneClickICSE

% Last Modified by GUIDE v2.5 16-Jun-2016 00:25:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @oneClickICSE_OpeningFcn, ...
                   'gui_OutputFcn',  @oneClickICSE_OutputFcn, ...
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


% --- Executes just before oneClickICSE is made visible.
function oneClickICSE_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to oneClickICSE (see VARARGIN)

% Choose default command line output for oneClickICSE
addApareciumToPath();
handles.imageImporter = ImageImporter();
handles.imageProcessingParameters = ImageProcessingParameters();
handles.imageAnalyzer = ImageAnalyzer();
handles.output = hObject;
handles.outputChannelNames = [];
handles.midasTableController = MidasTableController('empty');
handles.midasTableController.addTreatmentColumn(' ', '', '');
handles.apareciumExperimentInput = ApareciumExperimentInput();
handles.plateSimulatorInterface = PlateSimulatorInterface();
handles.cameraAndLensParameters = CameraAndLensParameters();
handles.simPlateHandle = [];
handles.analysisMode = 'Completed';
handles.observationStarted = 0;
set(handles.figure1, 'Color', [225/255, 226/255, 251/255]);
set(handles.figure1, 'name', 'ICSE Tools')

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes oneClickICSE wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = oneClickICSE_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
