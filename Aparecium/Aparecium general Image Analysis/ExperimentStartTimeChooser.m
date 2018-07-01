function varargout = ExperimentStartTimeChooser(varargin)
% EXPERIMENTSTARTTIMECHOOSER M-file for ExperimentStartTimeChooser.fig
%      EXPERIMENTSTARTTIMECHOOSER, by itself, creates a new EXPERIMENTSTARTTIMECHOOSER or raises the existing
%      singleton*.
%
%      H = EXPERIMENTSTARTTIMECHOOSER returns the handle to a new EXPERIMENTSTARTTIMECHOOSER or the handle to
%      the existing singleton*.
%
%      EXPERIMENTSTARTTIMECHOOSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPERIMENTSTARTTIMECHOOSER.M with the given input arguments.
%
%      EXPERIMENTSTARTTIMECHOOSER('Property','Value',...) creates a new EXPERIMENTSTARTTIMECHOOSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExperimentStartTimeChooser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExperimentStartTimeChooser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExperimentStartTimeChooser

% Last Modified by GUIDE v2.5 29-Jan-2016 15:30:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExperimentStartTimeChooser_OpeningFcn, ...
                   'gui_OutputFcn',  @ExperimentStartTimeChooser_OutputFcn, ...
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


% --- Executes just before ExperimentStartTimeChooser is made visible.
function ExperimentStartTimeChooser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ExperimentStartTimeChooser (see VARARGIN)

% Choose default command line output for ExperimentStartTimeChooser
handles.output = hObject;
handles.year = str2num(datestr(now, 'yyyy'));
handles.month = str2num(datestr(now, 'mm'));
handles.day = str2num(datestr(now, 'dd'));;
handles.h = 0;
handles.minute = 0;
handles.second = 0;
% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1);
% UIWAIT makes ExperimentStartTimeChooser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ExperimentStartTimeChooser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);



function hour_Callback(hObject, eventdata, handles)
% hObject    handle to hour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hour as text
%        str2double(get(hObject,'String')) returns contents of hour as a double
if str2double(get(hObject,'String')) <= 24 && str2double(get(hObject,'String')) >=0 
   handles.h = floor(str2double(get(hObject,'String')));
   set(hObject, 'String', num2str(handles.h));
else
   set(hObject, 'String', num2str(handles.h));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function hour_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function min_Callback(hObject, eventdata, handles)
% hObject    handle to min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min as text
%        str2double(get(hObject,'String')) returns contents of min as a double
if str2double(get(hObject,'String')) <= 60 && str2double(get(hObject,'String')) >=0 
   handles.minute = floor(str2double(get(hObject,'String')));
   set(hObject, 'String', num2str(handles.minute));
else
   set(hObject, 'String', num2str(handles.minute));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function s_Callback(hObject, eventdata, handles)
% hObject    handle to s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of s as text
%        str2double(get(hObject,'String')) returns contents of s as a double
if str2double(get(hObject,'String')) <= 60 && str2double(get(hObject,'String')) >=0 
   handles.second = floor(str2double(get(hObject,'String')));
   set(hObject, 'String', num2str(handles.second));
else
   set(hObject, 'String', num2str(handles.second));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function s_CreateFcn(hObject, eventdata, handles)
% hObject    handle to s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function activex1_AfterUpdate(hObject, eventdata, handles)
% hObject    handle to activex1 (see GCBO)
% eventdata  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)
handles.year = eventdata.Source.year;
handles.month = eventdata.Source.month;
handles.day = eventdata.Source.day;
guidata(handles.figure1, handles)


% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.year, handles.month, handles.day] = datevec(get(handles.date, 'String'), 'dd/mm/yyyy');
fullDate = [handles.year, handles.month, handles.day, handles.h, handles.minute, handles.second];
handles.output = datenum(fullDate);
guidata(hObject, handles);
figure1_CloseRequestFcn(handles.figure1, eventdata, handles)


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



function date_Callback(hObject, eventdata, handles)
% hObject    handle to date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of date as text
%        str2double(get(hObject,'String')) returns contents of date as a double


% --- Executes during object creation, after setting all properties.
function date_CreateFcn(hObject, eventdata, handles)
% hObject    handle to date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', datestr(now, 24))
guidata(hObject, handles);


% --- Executes on button press in chooseDate.
function chooseDate_Callback(hObject, eventdata, handles)
% hObject    handle to chooseDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if license('test', 'financial_toolbox')
    uicalendar('OutputDateFormat', 'dd/mm/yyyy', 'DestinationUI', handles.date);
else %looks like the financial toolbox is not available
    dateString = datestr(uigetdate(), 'dd/mm/yyyy');
    set(handles.date, 'String', dateString);
end
guidata(hObject, handles);
