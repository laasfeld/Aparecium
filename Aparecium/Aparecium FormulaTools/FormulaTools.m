function varargout = FormulaTools(varargin)
% FORMULATOOLS M-file for FormulaTools.fig
%      FORMULATOOLS, by itself, creates a new FORMULATOOLS or raises the existing
%      singleton*.
%
%      H = FORMULATOOLS returns the handle to a new FORMULATOOLS or the handle to
%      the existing singleton*.
%
%      FORMULATOOLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FORMULATOOLS.M with the given input arguments.
%
%      FORMULATOOLS('Property','Value',...) creates a new FORMULATOOLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FormulaTools_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FormulaTools_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FormulaTools

% Last Modified by GUIDE v2.5 19-Oct-2015 00:04:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FormulaTools_OpeningFcn, ...
                   'gui_OutputFcn',  @FormulaTools_OutputFcn, ...
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


% --- Executes just before FormulaTools is made visible.
function FormulaTools_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FormulaTools (see VARARGIN)

% Choose default command line output for FormulaTools
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FormulaTools wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FormulaTools_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
