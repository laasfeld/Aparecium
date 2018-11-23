function varargout = autoSequenceGenerator(varargin)
% AUTOSEQUENCEGENERATOR M-file for autoSequenceGenerator.fig
%      AUTOSEQUENCEGENERATOR, by itself, creates a new AUTOSEQUENCEGENERATOR or raises the existing
%      singleton*.
%
%      H = AUTOSEQUENCEGENERATOR returns the handle to a new AUTOSEQUENCEGENERATOR or the handle to
%      the existing singleton*.
%
%      AUTOSEQUENCEGENERATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUTOSEQUENCEGENERATOR.M with the given input arguments.
%
%      AUTOSEQUENCEGENERATOR('Property','Value',...) creates a new AUTOSEQUENCEGENERATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before autoSequenceGenerator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to autoSequenceGenerator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help autoSequenceGenerator

% Last Modified by GUIDE v2.5 08-Aug-2016 14:32:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @autoSequenceGenerator_OpeningFcn, ...
                   'gui_OutputFcn',  @autoSequenceGenerator_OutputFcn, ...
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


% --- Executes just before autoSequenceGenerator is made visible.
function autoSequenceGenerator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to autoSequenceGenerator (see VARARGIN)

% Choose default command line output for autoSequenceGenerator
fullPath = [mfilename('fullpath'), 'RANDOM556874'];
if isdeployed
    handles.folderPath = [pwd, '\'];
else  
    handles.folderPath = regexprep(fullPath, 'autoSequenceGeneratorRANDOM556874','', 'once');
end
handles.refreshImg = imread([regexprep(fullPath, 'autoSequenceGeneratorRANDOM556874','\..\\Icons\', 'once'), 'refresh.png']);
set(handles.refresh, 'cdata', handles.refreshImg);
handles.output = hObject;
handles.firstValue = [];
handles.step = [];
handles.numberOfValues = [];
handles.sequence = 'geometric';
handles.tableStyle = 'log10';
handles.tableData = [];
set(handles.uitable1, 'Data', {''});
handles.workspaceVariables = extractWorkspaceVariables();
handles.workspaceVariableNames = extractVariableNames(handles.workspaceVariables);
set(handles.popupmenu3, 'String', handles.workspaceVariableNames);
% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1);
% UIWAIT makes autoSequenceGenerator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = autoSequenceGenerator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);

function originalVariables = extractWorkspaceVariables()
originalVariables = evalin('base', 'whos');
incorrectVariables = [];
for variableIndex = 1 : numel(originalVariables)
   class = originalVariables(variableIndex).class;
   size = originalVariables(variableIndex).size;
   allowed = {'double', 'integer', 'int8', 'uint8', 'int16','unint16','int32','unint32','int64','unint64','single','float'};
   if sum(strcmp(allowed, class))
       if numel(size) < 3
          dimOneFound = 0;
          dimZeroFound = 0;
          for index = 1 : 2
             if isequal(size(index), 1)
                 dimOneFound = 1;
             elseif isequal(size(index), 0)
                 dimZeroFound = 1;
             end
          end         
          if dimOneFound && ~dimZeroFound
              
          else
              incorrectVariables(end+1) = variableIndex;
          end
       else
          incorrectVariables(end+1) = variableIndex; 
       end
   else
      incorrectVariables(end+1) = variableIndex; 
   end
end
originalVariables(incorrectVariables) = [];

function variableNames = extractVariableNames(variables)

variableNames = cell(numel(variables), 1);
for index = 1 : numel(variables)
   variableNames{index} = variables(index).name;
end
variableNames{end+1} = '';

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
handles.firstValue = str2double(regexprep(get(hObject,'String'),',','.'));
logFirstValue = num2str(log10(handles.firstValue));
set(handles.edit4, 'String', logFirstValue);
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
handles.step = str2double(regexprep(get(hObject,'String'),',','.'));
dilutionFactor = 1/handles.step;
set(handles.edit5, 'String', num2str(dilutionFactor));
guidata(hObject, handles);
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


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
contents = get(hObject,'String');
switch contents{get(hObject, 'Value')}
    case 'Linear'
        set(handles.text3, 'String','Common difference');
        set(handles.edit5, 'Enable', 'off');
        handles.sequence = 'linear';
    case 'Logarithmic (Geometric)'
        set(handles.edit5, 'Enable', 'on');
        set(handles.text3, 'String','Common ratio');
        handles.sequence = 'geometric';
end
guidata(hObject, handles);     

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch handles.sequence
    case 'linear'
        handles.tableData = zeros(handles.numberOfValues, 1);
        handles.tableData(1) = handles.firstValue;
        for valueIndex = 2 : handles.numberOfValues
           handles.tableData(valueIndex) = handles.tableData(valueIndex - 1) + handles.step; 
        end
    case 'geometric'
        handles.tableData = zeros(handles.numberOfValues, 1);
        handles.tableData(1) = handles.firstValue;
        for valueIndex = 2 : handles.numberOfValues
           handles.tableData(valueIndex) = handles.tableData(valueIndex - 1) * handles.step; 
        end
end

switch handles.tableStyle 
    case 'linear'
        
    case 'log10'
        handles.tableData = log10(handles.tableData);
end
set(handles.uitable1, 'Data', handles.tableData);
guidata(hObject, handles);


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
contents = get(hObject, 'String');
switch contents{get(hObject, 'Value')}
    case 'Linear'
        handles.tableStyle = 'linear';
    case 'Log10'
        handles.tableStyle = 'log10';
end
guidata(hObject, handles);  


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
contents = get(hObject,'String');
variableName = contents{get(hObject,'Value')};
if ~strcmp(variableName, '')
    values = evalin('base', variableName);
    if size(values, 1) < size(values, 2)
       values = values'; 
    end
    set(handles.uitable1, 'Data', values);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
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
handles.numberOfValues = round(str2double(regexprep(get(hObject,'String'),',','.')));
guidata(hObject, handles);

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


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = num2str(get(handles.uitable1, 'Data')');
handles.output = data;
%set(handles.text1,'String',ans)
guidata(hObject, handles);
if isequal(get(handles.figure1, 'waitstatus'),'waiting')
    uiresume(handles.figure1);
else
    delete(handles.figure1);
end


% --- Executes on button press in refresh.
function refresh_Callback(hObject, eventdata, handles)
% hObject    handle to refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.workspaceVariables = extractWorkspaceVariables();
handles.workspaceVariableNames = extractVariableNames(handles.workspaceVariables);
set(handles.popupmenu3, 'String', handles.workspaceVariableNames);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
log10Value = str2double(regexprep(get(hObject,'String'),',','.'));
handles.firstValue = power(10, log10Value);
set(handles.edit1, 'String', num2str(handles.firstValue));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
dilutionFactor = str2double(regexprep(get(hObject,'String'),',','.'));
handles.step = 1/dilutionFactor;
set(handles.edit2,'String', num2str(handles.step));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
