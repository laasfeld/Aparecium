function varargout = TreatmentAndMeasurementConverter(varargin)
% TREATMENTANDMEASUREMENTCONVERTER MATLAB code for TreatmentAndMeasurementConverter.fig
%      TREATMENTANDMEASUREMENTCONVERTER, by itself, creates a new TREATMENTANDMEASUREMENTCONVERTER or raises the existing
%      singleton*.
%
%      H = TREATMENTANDMEASUREMENTCONVERTER returns the handle to a new TREATMENTANDMEASUREMENTCONVERTER or the handle to
%      the existing singleton*.
%
%      TREATMENTANDMEASUREMENTCONVERTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TREATMENTANDMEASUREMENTCONVERTER.M with the given input arguments.
%
%      TREATMENTANDMEASUREMENTCONVERTER('Property','Value',...) creates a new TREATMENTANDMEASUREMENTCONVERTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TreatmentAndMeasurementConverter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TreatmentAndMeasurementConverter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TreatmentAndMeasurementConverter

% Last Modified by GUIDE v2.5 05-Nov-2018 17:22:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TreatmentAndMeasurementConverter_OpeningFcn, ...
                   'gui_OutputFcn',  @TreatmentAndMeasurementConverter_OutputFcn, ...
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


% --- Executes just before TreatmentAndMeasurementConverter is made visible.
function TreatmentAndMeasurementConverter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TreatmentAndMeasurementConverter (see VARARGIN)

% Choose default command line output for TreatmentAndMeasurementConverter
handles.output = hObject;
handles = populateTables(handles, varargin{1});
% Update handles structure

guidata(hObject, handles);
uiwait(handles.figure1);

% UIWAIT makes TreatmentAndMeasurementConverter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TreatmentAndMeasurementConverter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);


function handles = populateTables(handles, treatmentTable)

treatmentNames = treatmentTable(:, 1);
set(handles.OriginalValuesTable, 'ColumnName', treatmentNames);
set(handles.originalUnitsTable, 'ColumnName', treatmentNames);
set(handles.conversionFormulaeTable, 'ColumnName', treatmentNames);
set(handles.finalValuesTable, 'ColumnName', treatmentNames);
set(handles.finalUnitsTable, 'ColumnName', treatmentNames);

values = treatmentTable(:, 2);
data = cell(1, numel(values));
for i = 1 : numel(data)
   splited = strsplit(values{i});
   data(1 : numel(splited), i) = splited; 
end
set(handles.OriginalValuesTable, 'data', data);

[columnFormat{1:size(treatmentTable,1)}] = deal({'log10(val)', '10^val', '10^(val+9)', 'val'});
clear data;
[data{1:size(treatmentTable,1)}] = deal('10^(val+9)');
set(handles.conversionFormulaeTable, 'ColumnEditable', true(1, size(treatmentTable, 1)), 'ColumnFormat', columnFormat, 'data', data);

set(handles.originalUnitsTable, 'data', treatmentTable(:, 3)');
set(handles.finalUnitsTable, 'data', treatmentTable(:, 3)');


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.OriginalValuesTable, 'data');
formulae = get(handles.conversionFormulaeTable, 'data');
unitData = get(handles.originalUnitsTable, 'data');
for column = 1 : size(data, 2)
    for row = 1 : size(data, 1)    
        if ~isempty(data{row, column})
            formula = regexprep(formulae{column}, 'val', num2str(data{row, column}));
            data{row, column} = num2str(eval(formula));
            
        end  
    end
    unitData{column} = regexprep(formulae{column}, 'val', unitData{column}); 
end
set(handles.finalUnitsTable, 'data', unitData);
set(handles.finalValuesTable, 'data', data);
guidata(hObject, handles);

function returnFocus(hObject)
set(hObject, 'Enable', 'off');
drawnow;
set(hObject, 'Enable', 'on');

% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = {get(handles.OriginalValuesTable, 'data'), get(handles.originalUnitsTable, 'data'), get(handles.finalValuesTable, 'data'), get(handles.finalUnitsTable, 'data')};
guidata(hObject, handles);
if isequal(get(handles.figure1, 'waitstatus'),'waiting')
    uiresume(handles.figure1)
else
    delete(handles.figure1);
end
returnFocus(hObject)


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


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


% --- Executes on button press in replace.
function replace_Callback(hObject, eventdata, handles)
% hObject    handle to replace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.finalValuesTable, 'data'); 
for row = 1 : size(data, 1)
    for column = 1 : size(data, 2)
        if strcmp(data{row, column}, get(handles.edit1, 'String'))
            data{row, column} = get(handles.edit2, 'String');
        end
    end
end
set(handles.finalValuesTable, 'data', data);
guidata(hObject, handles);


function customFormulaBox_Callback(hObject, eventdata, handles)
% hObject    handle to customFormulaBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of customFormulaBox as text
%        str2double(get(hObject,'String')) returns contents of customFormulaBox as a double


% --- Executes during object creation, after setting all properties.
function customFormulaBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to customFormulaBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addCustomFormula.
function addCustomFormula_Callback(hObject, eventdata, handles)
% hObject    handle to addCustomFormula (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
columnFormat = get(handles.conversionFormulaeTable, 'ColumnFormat');
for i = 1 : numel(columnFormat)
   columnFormat{i}{end + 1} = get(handles.customFormulaBox, 'String');  
end
set(handles.conversionFormulaeTable, 'ColumnFormat', columnFormat);
guidata(hObject, handles);
