function varargout = SettingsUI(varargin)
% SETTINGSUI M-file for SettingsUI.fig
%      SETTINGSUI, by itself, creates a new SETTINGSUI or raises the existing
%      singleton*.
%
%      H = SETTINGSUI returns the handle to a new SETTINGSUI or the handle to
%      the existing singleton*.
%
%      SETTINGSUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETTINGSUI.M with the given input arguments.
%
%      SETTINGSUI('Property','Value',...) creates a new SETTINGSUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SettingsUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SettingsUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SettingsUI

% Last Modified by GUIDE v2.5 02-Nov-2017 11:59:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SettingsUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SettingsUI_OutputFcn, ...
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


% --- Executes just before SettingsUI is made visible.
function SettingsUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SettingsUI (see VARARGIN)

% Choose default command line output for SettingsUI
if isequal(numel(varargin), 1) && strcmp(varargin{1}, 'returnStructure')
   handles.saveExistAndReturn = 1;
else
   handles.saveExitAndReturn = 0;
end
handles.output = hObject;
fullPath = [mfilename('fullpath'),'RANDOM556874'];
if isdeployed
    handles.folderPath = [pwd, '\'];
else  
    handles.folderPath = regexprep(fullPath, 'SettingsUIRANDOM556874','', 'once');
end
handles.folderImg = imread([regexprep(fullPath, 'SettingsUIRANDOM556874','\..\\Icons\', 'once'),'folder.png']);
set(handles.PHERAStarASCII, 'cdata', handles.folderImg);
set(handles.Excel, 'cdata', handles.folderImg);
set(handles.MIDAS, 'cdata', handles.folderImg);
set(handles.NeoASCII, 'cdata', handles.folderImg);
set(handles.PHERAStarDatabase, 'cdata', handles.folderImg);
set(handles.SBToolbox, 'cdata', handles.folderImg);
set(handles.Configurations, 'cdata', handles.folderImg);
set(handles.GCF, 'cdata', handles.folderImg);
set(handles.FCF, 'cdata', handles.folderImg);
set(handles.perkinElmer, 'cdata', handles.folderImg);
set(handles.magellan, 'cdata', handles.folderImg);
settings = [];
load([handles.folderPath, 'settings']); 
handles.settings = settings;
try
    set(handles.PHERAStarASCII_Path,'String', settings.PHERAStarASCII);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('PHERAStar path not found')
    else
        rethrow(MException)
    end
end

try
    set(handles.Excel_Path,'String', settings.Excel);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('Excel path not found')
    else
        rethrow(MException)
    end
end

try
    set(handles.MIDAS_Path,'String', settings.MIDAS);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('MIDAS path not found')
    else
        rethrow(MException)
    end
end

try
    set(handles.NeoASCII_Path,'String',settings.NeoASCII);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('Gen5 ASCII path not found')
    else
        rethrow(MException)
    end
end

try
    set(handles.PHERAStarDatabase_Path,'String',settings.PHERAStarDatabase);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('PHERAStar database path not found')
    else
        rethrow(MException)
    end
end

try
    set(handles.SBToolbox_Path,'String',settings.SBToolbox);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('SBToolbox2 path not found')
    else
        rethrow(MException)
    end
end

try
    set(handles.Configurations_Path,'String',settings.Configurations);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('Configuration file path not found')
    else
        rethrow(MException)
    end
end
try
    set(handles.GCFPath,'String',settings.GCFPath);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('Grouping configuration file path not found')
    else
        rethrow(MException)
    end
end
try
    set(handles.FCFPath,'String',settings.FCFPath);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('Formula configuration path not found')
    else
        rethrow(MException)
    end
end

try
    set(handles.showBlank, 'Value', settings.showBlank);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('Blank setting not found, using False')
    else
        rethrow(MException)
    end
end
% Update handles structure

guidata(hObject, handles);
uiwait(handles.figure1);

% UIWAIT makes SettingsUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SettingsUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.settings;
guidata(hObject, handles);



function PHERAStarASCII_Path_Callback(hObject, eventdata, handles)
% hObject    handle to PHERAStarASCII_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PHERAStarASCII_Path as text
%        str2double(get(hObject,'String')) returns contents of PHERAStarASCII_Path as a double
handles.settings.PHERAStarASCII = get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function PHERAStarASCII_Path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PHERAStarASCII_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NeoASCII_Path_Callback(hObject, eventdata, handles)
% hObject    handle to NeoASCII_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NeoASCII_Path as text
%        str2double(get(hObject,'String')) returns contents of NeoASCII_Path as a double
handles.settings.NeoASCII = get(hObject,'String');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function NeoASCII_Path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NeoASCII_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PHERAStarDatabase_Path_Callback(hObject, eventdata, handles)
% hObject    handle to PHERAStarDatabase_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PHERAStarDatabase_Path as text
%        str2double(get(hObject,'String')) returns contents of PHERAStarDatabase_Path as a double
handles.settings.PHERAStarDatabase = get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function PHERAStarDatabase_Path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PHERAStarDatabase_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MIDAS_Path_Callback(hObject, eventdata, handles)
% hObject    handle to MIDAS_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MIDAS_Path as text
%        str2double(get(hObject,'String')) returns contents of MIDAS_Path as a double
handles.settings.MIDAS = get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function MIDAS_Path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MIDAS_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Excel_Path_Callback(hObject, eventdata, handles)
% hObject    handle to Excel_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Excel_Path as text
%        str2double(get(hObject,'String')) returns contents of Excel_Path as a double
handles.settings.Excel = get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Excel_Path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Excel_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SBToolbox_Path_Callback(hObject, eventdata, handles)
% hObject    handle to SBToolbox_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SBToolbox_Path as text
%        str2double(get(hObject,'String')) returns contents of SBToolbox_Path as a double
handles.settings.SBToolbox = get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function SBToolbox_Path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SBToolbox_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
settings = handles.settings;
handles.folderPath;
try
    if isequal(handles.saveExistAndReturn, 0) % save as usual, do not return the structure
        save([handles.folderPath, '\settings'],'settings');
    elseif isequal(handles.saveExistAndReturn, 1)
        % here should be code for the case when settings should be returned -
        % code not complete
    end
catch
    save([handles.folderPath, '\settings'], 'settings');
end

% --- Executes on button press in PHERAStarASCII.
function PHERAStarASCII_Callback(hObject, eventdata, handles)
% hObject    handle to PHERAStarASCII (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.settings.PHERAStarASCII = uigetdir('','Select standard folder for PHERAStar ASCII files');
set(handles.PHERAStarASCII_Path,'String',handles.settings.PHERAStarASCII);
guidata(hObject,handles);
% --- Executes on button press in NeoASCII.
function NeoASCII_Callback(hObject, eventdata, handles)
% hObject    handle to NeoASCII (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.settings.NeoASCII = uigetdir('','Select standard folder for Synergy Neo ASCII files');
set(handles.NeoASCII_Path,'String',handles.settings.NeoASCII);
guidata(hObject,handles);

% --- Executes on button press in PHERAStarDatabase.
function PHERAStarDatabase_Callback(hObject, eventdata, handles)
% hObject    handle to PHERAStarDatabase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.settings.PHERAStarDatabase = uigetdir('','Select standard folder for PHERAStar database files');
set(handles.PHERAStarDatabase_Path,'String',handles.settings.PHERAStarDatabase);
guidata(hObject,handles);

% --- Executes on button press in MIDAS.
function MIDAS_Callback(hObject, eventdata, handles)
% hObject    handle to MIDAS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.settings.MIDAS = uigetdir('','Select standard folder for MIDAS files');
set(handles.MIDAS_Path,'String',handles.settings.MIDAS);
guidata(hObject,handles);

% --- Executes on button press in Excel.
function Excel_Callback(hObject, eventdata, handles)
% hObject    handle to Excel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.settings.Excel = uigetdir('','Select standard folder for Excel/Prism files');
set(handles.Excel_Path,'String',handles.settings.Excel);
guidata(hObject,handles);

% --- Executes on button press in SBToolbox.
function SBToolbox_Callback(hObject, eventdata, handles)
% hObject    handle to SBToolbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.settings.SBToolbox = uigetdir('','Select standard folder for SBToolbox files');
set(handles.SBToolbox_Path,'String',handles.settings.SBToolbox);
guidata(hObject,handles);


function Configurations_Path_Callback(hObject, eventdata, handles)
% hObject    handle to Configurations_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Configurations_Path as text
%        str2double(get(hObject,'String')) returns contents of Configurations_Path as a double
handles.settings.Configurations = get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Configurations_Path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Configurations_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Configurations.
function Configurations_Callback(hObject, eventdata, handles)
% hObject    handle to Configurations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.settings.Configurations = uigetdir('','Select standard folder for configuration files');
set(handles.Configurations_Path,'String',handles.settings.Configurations);
guidata(hObject,handles);

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



function GCFPath_Callback(hObject, eventdata, handles)
% hObject    handle to GCFPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCFPath as text
%        str2double(get(hObject,'String')) returns contents of GCFPath as a double
handles.settings.GCFPath = get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function GCFPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCFPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GCF.
function GCF_Callback(hObject, eventdata, handles)
% hObject    handle to GCF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.settings.GCFPath = uigetdir('','Select standard folder for group configuration files (GCF)');
set(handles.GCFPath,'String',handles.settings.GCFPath);
guidata(hObject,handles);


function FCFPath_Callback(hObject, eventdata, handles)
% hObject    handle to FCFPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FCFPath as text
%        str2double(get(hObject,'String')) returns contents of FCFPath as a double
handles.settings.FCFPath = get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function FCFPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FCFPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in FCF.
function FCF_Callback(hObject, eventdata, handles)
% hObject    handle to FCF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.settings.FCFPath = uigetdir('','Select standard folder for formula configuration files(FCF)');
set(handles.FCFPath,'String',handles.settings.FCFPath);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Configurations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Configurations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in perkinElmer.
function perkinElmer_Callback(hObject, eventdata, handles)
% hObject    handle to perkinElmer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in magellan.
function magellan_Callback(hObject, eventdata, handles)
% hObject    handle to magellan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
channelNameOptions()


% --- Executes on button press in showBlank.
function showBlank_Callback(hObject, eventdata, handles)
% hObject    handle to showBlank (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showBlank
handles.settings.showBlank = get(hObject, 'Value');
guidata(hObject, handles)
