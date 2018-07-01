function varargout = ChoosePredefinedChannels(varargin)
% CHOOSEPREDEFINEDCHANNELS M-file for ChoosePredefinedChannels.fig
%      CHOOSEPREDEFINEDCHANNELS, by itself, creates a new CHOOSEPREDEFINEDCHANNELS or raises the existing
%      singleton*.
%
%      H = CHOOSEPREDEFINEDCHANNELS returns the handle to a new CHOOSEPREDEFINEDCHANNELS or the handle to
%      the existing singleton*.
%
%      CHOOSEPREDEFINEDCHANNELS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHOOSEPREDEFINEDCHANNELS.M with the given input arguments.
%
%      CHOOSEPREDEFINEDCHANNELS('Property','Value',...) creates a new CHOOSEPREDEFINEDCHANNELS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ChoosePredefinedChannels_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ChoosePredefinedChannels_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ChoosePredefinedChannels

% Last Modified by GUIDE v2.5 08-Nov-2016 22:37:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChoosePredefinedChannels_OpeningFcn, ...
                   'gui_OutputFcn',  @ChoosePredefinedChannels_OutputFcn, ...
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


% --- Executes just before ChoosePredefinedChannels is made visible.
function ChoosePredefinedChannels_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ChoosePredefinedChannels (see VARARGIN)

% Choose default command line output for ChoosePredefinedChannels
handles.output = hObject;
handles.numberOfChannels = varargin{1};
channelManager = ChannelManager();
handles.channelNamesStruct = channelManager.getChannels();
handles.MIDASChannelNames = cell(numel(handles.channelNamesStruct), 1);
handles.channelNames = cell(numel(handles.channelNamesStruct), 1);
for channelIndex = 1 : numel(handles.channelNames)
    handles.MIDASChannelNames{channelIndex} = handles.channelNamesStruct(channelIndex).MIDASChannelName;
    handles.channelNames{channelIndex} = handles.channelNamesStruct(channelIndex).channelName;
end
set(handles.uitable1, 'data', [handles.channelNames(1 : handles.numberOfChannels), handles.MIDASChannelNames(1 : handles.numberOfChannels)]);
set(handles.uitable1,'ColumnFormat', {handles.channelNames', 'char'});
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ChoosePredefinedChannels wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ChoosePredefinedChannels_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);


% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.uitable1, 'Data');
MIDASChannelsReal = data(:, 2);
newChannelName = data{eventdata.Indices(1), eventdata.Indices(2)};
index = findStringFromCellArray(handles.channelNames, newChannelName);
MIDASChannelsReal(eventdata.Indices(1)) = handles.MIDASChannelNames(index);
set(handles.uitable1, 'data', [data(:, 1), MIDASChannelsReal]);
set(handles.uitable1,'ColumnFormat', {handles.channelNames', 'char'});


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = get(handles.uitable1, 'data');

guidata(hObject, handles);
if isequal(get(handles.figure1, 'waitstatus'),'waiting')
    uiresume(handles.figure1)
else
    delete(handles.figure1);
end