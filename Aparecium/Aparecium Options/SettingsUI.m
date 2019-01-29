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

% Last Modified by GUIDE v2.5 28-Jan-2019 12:53:52

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
set(handles.MembraneTools, 'cdata', handles.folderImg);
settings = [];
load([handles.folderPath, 'settings']); 
handles.settings = settings;
try
    set(handles.PHERAStarASCII_Path,'String', settings.PHERAStarASCII);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('PHERAStar path not found')
        handles.settings.PHERAStarASCII = '';
    else
        rethrow(MException)
    end
end

try
    set(handles.Excel_Path,'String', settings.Excel);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('Excel path not found')
        handles.settings.Excel = '';
    else
        rethrow(MException)
    end
end

try
    set(handles.MIDAS_Path,'String', settings.MIDAS);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('MIDAS path not found')
        handles.settings.MIDAS = '';
    else
        rethrow(MException)
    end
end

try
    set(handles.NeoASCII_Path,'String',settings.NeoASCII);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('Gen5 ASCII path not found')
        handles.settings.NeoASCII = '';
    else
        rethrow(MException)
    end
end

try
    set(handles.PHERAStarDatabase_Path,'String',settings.PHERAStarDatabase);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('PHERAStar database path not found')
        handles.settings.PHERAStarDatabase = '';
    else
        rethrow(MException)
    end
end

try
    set(handles.SBToolbox_Path,'String',settings.SBToolbox);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('SBToolbox2 path not found')
        handles.settings.SBToolbox = '';
    else
        rethrow(MException)
    end
end

try
    set(handles.Configurations_Path,'String',settings.Configurations);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('Configuration file path not found')
        handles.settings.Configurations = '';
    else
        rethrow(MException)
    end
end
try
    set(handles.GCFPath,'String',settings.GCFPath);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('Grouping configuration file path not found')
        handles.settings.GCFPath = '';
    else
        rethrow(MException)
    end
end

try
    set(handles.FCFPath,'String',settings.FCFPath);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('Formula configuration path not found')
        handles.settings.FCFPath = '';
    else
        rethrow(MException)
    end
end

try
    set(handles.MembraneToolsPath,'String',settings.MembraneToolsPath);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('Membrane Tools configuration path not found')
        handles.settings.MembraneToolsPath = '';
    else
        rethrow(MException)
    end
end

try
    set(handles.magellanPath,'String',settings.magellanPath);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('Membrane Tools configuration path not found')
        handles.settings.magellanPath = '';
    else
        rethrow(MException)
    end
end

try
    set(handles.PerkinElmerPath,'String',settings.PerkinElmerPath);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('Membrane Tools configuration path not found')
        handles.settings.PerkinElmerPath = '';
    else
        rethrow(MException)
    end
end

try
    set(handles.showBlank, 'Value', settings.showBlank);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('Blank setting not found, using False')
        handles.settings.showBlank = false;
    else
        rethrow(MException)
    end
end

try
    set(handles.PHERAStarASCII_useLast, 'Value', settings.PHERAStarASCII_useLast);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('PHERAStarASCII_useLast setting not found, using False')
        handles.settings.PHERAStarASCII_useLast = false;
    else
        rethrow(MException)
    end
end

try
    set(handles.NeoASCII_useLast, 'Value', settings.NeoASCII_useLast);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('NeoASCII_useLast setting not found, using False')
        handles.settings.NeoASCII_useLast = false;
    else
        rethrow(MException)
    end
end

try
    set(handles.PHERAStarDatabase_useLast, 'Value', settings.PHERAStarDatabase_useLast);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('PHERAStarDatabase_useLast setting not found, using False')
        handles.settings.PHERAStarDatabase_useLast = false;
    else
        rethrow(MException)
    end
end

try
    set(handles.MIDAS_useLast, 'Value', settings.MIDAS_useLast);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('MIDAS_useLast setting not found, using False')
        handles.settings.MIDAS_useLast = false;
    else
        rethrow(MException)
    end
end

try
    set(handles.Excel_useLast, 'Value', settings.Excel_useLast);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('Excel_useLast setting not found, using False')
        handles.settings.Excel_useLast = false;
    else
        rethrow(MException)
    end
end

try
    set(handles.SBToolbox_useLast, 'Value', settings.SBToolbox_useLast);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('SBToolbox_useLast setting not found, using False')
        handles.settings.SBToolbox_useLast = false;
    else
        rethrow(MException)
    end
end

try
    set(handles.Configurations_useLast, 'Value', settings.Configurations_useLast);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('Configurations_useLast setting not found, using False')
        handles.settings.Configurations_useLast = false;
    else
        rethrow(MException)
    end
end

try
    set(handles.GCF_useLast, 'Value', settings.GCF_useLast);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('GCF_useLast setting not found, using False')
        handles.settings.GCF_useLast = false;
    else
        rethrow(MException)
    end
end

try
    set(handles.FCF_useLast, 'Value', settings.FCF_useLast);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('FCF_useLast setting not found, using False')
        handles.settings.FCF_useLast = false;
    else
        rethrow(MException)
    end
end

try
    set(handles.perkinElmer_useLast, 'Value', settings.perkinElmer_useLast);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('perkinElmer_useLast setting not found, using False')
        handles.settings.perkinElmer_useLast = false;
    else
        rethrow(MException)
    end
end

try
    set(handles.magellan_useLast, 'Value', settings.magellan_useLast);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('magellan_useLast setting not found, using False')
        handles.settings.magellan_useLast = false;
    else
        rethrow(MException)
    end
end

try
    set(handles.MembraneTools_useLast, 'Value', settings.MembraneTools_useLast);
catch MException
    if isequal(MException.identifier, 'MATLAB:nonExistentField')
        disp('MembraneTools_useLast setting not found, using False')
        handles.settings.MembraneTools_useLast = false;
    else
        rethrow(MException)
    end
end

try
    if(strcmp(userpath, regexprep(fullPath, '\\Aparecium Options\\SettingsUIRANDOM556874', ';'))) % Userpath already corresponds to the Aparecium folder
        set(handles.userPathOption, 'Value', 1);
        set(handles.userPathOption, 'Enable', 'off');
    end

catch MException
    
end

try
    if strcmp(fileread('startup.m'), sprintf('cd(regexprep(mfilename(''fullpath''), ''startup'', ''''));\naddApareciumToPath();\nApareciumStart();')) % Startup.m already corresonds to the specified value
        set(handles.startupOption, 'Value', 1);
        set(handles.startupOption, 'Enable', 'off');
    end

catch MException
    
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
if isfield(handles, 'settings')
    varargout{1} = handles.settings;
    guidata(hObject, handles);
end




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

function handles = updateLastFolderSettings(handles)
handles.settings.PHERAStarASCII_useLast = get(handles.PHERAStarASCII_useLast, 'Value');
handles.settings.NeoASCII_useLast = get(handles.NeoASCII_useLast, 'Value');
handles.settings.PHERAStarDatabase_useLast = get(handles.PHERAStarDatabase_useLast, 'Value');
handles.settings.MIDAS_useLast = get(handles.MIDAS_useLast, 'Value');
handles.settings.Excel_useLast = get(handles.Excel_useLast, 'Value');
handles.settings.SBToolbox_useLast = get(handles.SBToolbox_useLast, 'Value');
handles.settings.Configurations_useLast = get(handles.Configurations_useLast, 'Value');
handles.settings.GCF_useLast = get(handles.GCF_useLast, 'Value');
handles.settings.FCF_useLast = get(handles.FCF_useLast, 'Value');
handles.settings.perkinElmer_useLast = get(handles.perkinElmer_useLast, 'Value');
handles.settings.magellan_useLast = get(handles.magellan_useLast, 'Value');
handles.settings.MembraneTools_useLast = get(handles.MembraneTools_useLast, 'Value');


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = updateLastFolderSettings(handles);
settings = handles.settings;
handles.folderPath;

if(isequal(get(handles.userPathOption, 'Value'), 1))
    userpath(regexprep(mfilename('fullpath'), '\\Aparecium Options\\SettingsUI', ''));
end

if isequal(get(handles.startupOption, 'Value'), 1)
    fileID = fopen([regexprep(regexprep(mfilename('fullpath'), '\Aparecium Options\\\SettingsUI',''), '\\', '\\\\') '\\startup.m'],'w+');
    fprintf(fileID, sprintf('cd(regexprep(mfilename(''fullpath''), ''startup'', ''''));\naddApareciumToPath();\nApareciumStart();'));
    fclose(fileID);
end

try
    if isequal(handles.saveExitAndReturn, 0) % save as usual, do not return the structure
        save([handles.folderPath, '\settings'],'settings');
        guidata(hObject, handles);
        uiresume(handles.figure1);
        delete(handles.figure1);
    elseif isequal(handles.saveExistAndReturn, 1)
        save([handles.folderPath, '\settings'],'settings');
        guidata(hObject, handles);
        if isequal(get(handles.figure1, 'waitstatus'),'waiting')
            uiresume(handles.figure1);
        else
            delete(handles.figure1);
        end
    end
catch MException
    save([handles.folderPath, '\settings'], 'settings');
end



% --- Executes on button press in PHERAStarASCII.
function PHERAStarASCII_Callback(hObject, eventdata, handles)
% hObject    handle to PHERAStarASCII (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
result = uigetdir(handles.settings.PHERAStarASCII, 'Select standard folder for PHERAStar ASCII files');
if ~isequal(result, 0)
    handles.settings.PHERAStarASCII = result;
    set(handles.PHERAStarASCII_Path,'String',handles.settings.PHERAStarASCII);
end
guidata(hObject,handles);
% --- Executes on button press in NeoASCII.
function NeoASCII_Callback(hObject, eventdata, handles)
% hObject    handle to NeoASCII (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
result = uigetdir(handles.settings.NeoASCII, 'Select standard folder for Synergy Neo ASCII files');
if ~isequal(result, 0)
    handles.settings.NeoASCII = result;
    set(handles.NeoASCII_Path,'String',handles.settings.NeoASCII);
end
guidata(hObject,handles);

% --- Executes on button press in PHERAStarDatabase.
function PHERAStarDatabase_Callback(hObject, eventdata, handles)
% hObject    handle to PHERAStarDatabase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
result = uigetdir(handles.settings.PHERAStarDatabase, 'Select standard folder for PHERAStar database files');
if ~isequal(result, 0)
    handles.settings.PHERAStarDatabase = result;
    set(handles.PHERAStarDatabase_Path,'String',handles.settings.PHERAStarDatabase);
end
guidata(hObject,handles);

% --- Executes on button press in MIDAS.
function MIDAS_Callback(hObject, eventdata, handles)
% hObject    handle to MIDAS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
result = uigetdir(handles.settings.MIDAS, 'Select standard folder for MIDAS files');
if ~isequal(result, 0)
    handles.settings.MIDAS = result;
    set(handles.MIDAS_Path,'String',handles.settings.MIDAS);
end
guidata(hObject,handles);

% --- Executes on button press in Excel.
function Excel_Callback(hObject, eventdata, handles)
% hObject    handle to Excel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
result = uigetdir(handles.settings.Excel, 'Select standard folder for Excel/Prism files');
if ~isequal(result, 0)
    handles.settings.Excel = result;
    set(handles.Excel_Path,'String',handles.settings.Excel);
end
guidata(hObject,handles);

% --- Executes on button press in SBToolbox.
function SBToolbox_Callback(hObject, eventdata, handles)
% hObject    handle to SBToolbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
result = uigetdir(handles.settings.SBToolbox, 'Select standard folder for SBToolbox files');
if ~isequal(result, 0)
    handles.settings.SBToolbox = result;
    set(handles.SBToolbox_Path,'String',handles.settings.SBToolbox);
end
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
result = uigetdir(handles.settings.Configurations, 'Select standard folder for configuration files');
if ~isequal(result, 0)
    handles.settings.Configurations = result;
    set(handles.Configurations_Path,'String',handles.settings.Configurations);
end
guidata(hObject,handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
guidata(hObject, handles);
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
result = uigetdir(handles.settings.GCFPath, 'Select standard folder for group configuration files (GCF)');
if ~isequal(result, 0)
    handles.settings.GCFPath = result;
    set(handles.GCFPath,'String',handles.settings.GCFPath);
end
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
result = uigetdir(handles.settings.FCFPath, 'Select standard folder for formula configuration files(FCF)');
if ~isequal(result, 0)
    handles.settings.FCFPath = result;
    set(handles.FCFPath,'String',handles.settings.FCFPath);
end
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


% --- Executes on button press in startupOption.
function startupOption_Callback(hObject, eventdata, handles)
% hObject    handle to startupOption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of startupOption


% --- Executes on button press in userPathOption.
function userPathOption_Callback(hObject, eventdata, handles)
% hObject    handle to userPathOption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of userPathOption


% --- Executes on button press in SBStateNameOptions.
function SBStateNameOptions_Callback(hObject, eventdata, handles)
% hObject    handle to SBStateNameOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SBStateNameOptions()



function MembraneToolsPath_Callback(hObject, eventdata, handles)
% hObject    handle to MembraneToolsPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MembraneToolsPath as text
%        str2double(get(hObject,'String')) returns contents of MembraneToolsPath as a double


% --- Executes during object creation, after setting all properties.
function MembraneToolsPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MembraneToolsPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MembraneTools.
function MembraneTools_Callback(hObject, eventdata, handles)
% hObject    handle to MembraneTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
result = uigetdir(handles.settings.MembraneToolsPath, 'Select standard image import folder for MembraneTools');
if ~isequal(result, 0)
    handles.settings.MembraneToolsPath = result;
    set(handles.MembraneToolsPath,'String',handles.settings.MembraneToolsPath);
end
guidata(hObject,handles);

% --- Executes on button press in allCheckbox.
function allCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to allCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of allCheckbox
value = get(hObject,'Value');
tickBoxes = [handles.PHERAStarASCII_useLast, handles.NeoASCII_useLast, handles.PHERAStarDatabase_useLast, handles.MIDAS_useLast, handles.Excel_useLast,... 
    handles.SBToolbox_useLast, handles.Configurations_useLast, handles.GCF_useLast, handles.FCF_useLast, handles.perkinElmer_useLast, handles.magellan_useLast, handles.MembraneTools_useLast];
for i = 1 : numel(tickBoxes)
   set(tickBoxes(i), 'Value', value);
end
guidata(hObject, handles);

% --- Executes on button press in PHERAStarASCII_useLast.
function PHERAStarASCII_useLast_Callback(hObject, eventdata, handles)
% hObject    handle to PHERAStarASCII_useLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PHERAStarASCII_useLast


% --- Executes on button press in NeoASCII_useLast.
function NeoASCII_useLast_Callback(hObject, eventdata, handles)
% hObject    handle to NeoASCII_useLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NeoASCII_useLast


% --- Executes on button press in PHERAStarDatabase_useLast.
function PHERAStarDatabase_useLast_Callback(hObject, eventdata, handles)
% hObject    handle to PHERAStarDatabase_useLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PHERAStarDatabase_useLast


% --- Executes on button press in MIDAS_useLast.
function MIDAS_useLast_Callback(hObject, eventdata, handles)
% hObject    handle to MIDAS_useLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MIDAS_useLast


% --- Executes on button press in Excel_useLast.
function Excel_useLast_Callback(hObject, eventdata, handles)
% hObject    handle to Excel_useLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Excel_useLast


% --- Executes on button press in SBToolbox_useLast.
function SBToolbox_useLast_Callback(hObject, eventdata, handles)
% hObject    handle to SBToolbox_useLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SBToolbox_useLast


% --- Executes on button press in Configurations_useLast.
function Configurations_useLast_Callback(hObject, eventdata, handles)
% hObject    handle to Configurations_useLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Configurations_useLast


% --- Executes on button press in GCF_useLast.
function GCF_useLast_Callback(hObject, eventdata, handles)
% hObject    handle to GCF_useLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GCF_useLast


% --- Executes on button press in FCF_useLast.
function FCF_useLast_Callback(hObject, eventdata, handles)
% hObject    handle to FCF_useLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FCF_useLast


% --- Executes on button press in perkinElmer_useLast.
function perkinElmer_useLast_Callback(hObject, eventdata, handles)
% hObject    handle to perkinElmer_useLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of perkinElmer_useLast


% --- Executes on button press in magellan_useLast.
function magellan_useLast_Callback(hObject, eventdata, handles)
% hObject    handle to magellan_useLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of magellan_useLast


% --- Executes on button press in MembraneTools_useLast.
function MembraneTools_useLast_Callback(hObject, eventdata, handles)
% hObject    handle to MembraneTools_useLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MembraneTools_useLast
