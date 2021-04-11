function varargout = ImageAligner(varargin)
% IMAGEALIGNER MATLAB code for ImageAligner.fig
%      IMAGEALIGNER, by itself, creates a new IMAGEALIGNER or raises the existing
%      singleton*.
%
%      H = IMAGEALIGNER returns the handle to a new IMAGEALIGNER or the handle to
%      the existing singleton*.
%
%      IMAGEALIGNER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGEALIGNER.M with the given input arguments.
%
%      IMAGEALIGNER('Property','Value',...) creates a new IMAGEALIGNER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageAligner_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageAligner_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageAligner

% Last Modified by GUIDE v2.5 28-Jun-2020 23:40:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageAligner_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageAligner_OutputFcn, ...
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


% --- Executes just before ImageAligner is made visible.
function ImageAligner_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageAligner (see VARARGIN)

% Choose default command line output for ImageAligner
handles.imageImporter = varargin{1};

firstChannelList = cell(0, 1);
for well = 1 : numel(handles.imageImporter.nameArray)
    for imageInWell = 1 : numel(handles.imageImporter.nameArray{well})
        firstChannelList{end + 1} = handles.imageImporter.nameArray{well}{imageInWell};
    end
end

secondChannelList = cell(0, 1);
for well = 1 : numel(handles.imageImporter.secondaryNameArray)
    for imageInWell = 1 : numel(handles.imageImporter.secondaryNameArray{well})
        secondChannelList{end + 1} = handles.imageImporter.secondaryNameArray{well}{imageInWell};
    end
end

set(handles.listbox1, 'String', firstChannelList);
set(handles.listbox2, 'String', secondChannelList);
handles.mouseDown = false;
handles.output = hObject;
guidata(hObject, handles);
handles.horizontalShift = 0;
handles.verticalShift = 0;
handles.mouseDownHorizontal = [];
handles.mouseDownVertical = [];
handles.mouseDownHorizontalShift = 0;
handles.mouseDownVerticalShift = 0;
handles.imageHasSwaped = true;
handles.dataCursor = dataCursor(handles.figure1, handles, @mouseMove, @mouseDown, @mouseUp);
handles.dataCursor.setHandles(handles);
%set(handles.figure1, 'WindowButtonMotionFcn', @mouseMove);

%handles.dataCursor




% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1);
% UIWAIT makes ImageAligner wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ImageAligner_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = [round(handles.horizontalShift), round(handles.verticalShift)];
delete(handles.figure1);



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
handles.verticalShift = str2double(get(hObject,'String'));
updateDisplay(handles);

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


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
set(handles.listbox2, 'Value', get(hObject,'Value'));
handles.imageHasSwaped = true;
updateDisplay(handles);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
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
handles.horizontalShift = str2double(get(hObject,'String'));
updateDisplay(handles);

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


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updateDisplay(handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
set(handles.listbox1, 'Value', get(hObject,'Value'));
handles.imageHasSwaped = true;
updateDisplay(handles);


function updateDisplay(handles)
contents = cellstr(get(handles.listbox2,'String'));
secondaryImageName = contents{get(handles.listbox2,'Value')};

contents = cellstr(get(handles.listbox1,'String'));
primaryImageName = contents{get(handles.listbox1,'Value')};
if handles.imageHasSwaped == true;
    mainPath = [handles.imageImporter.mainDirectory, '\', handles.imageImporter.usedDirectories{1}, '\'];
    primaryImage = imread([mainPath, primaryImageName]);
    secondaryImage = imread([mainPath, secondaryImageName]);
    handles.primaryImage = primaryImage;
    handles.secondaryImage = secondaryImage;
    handles.imageHasSwaped = false;
else
    primaryImage = handles.primaryImage;
    secondaryImage = handles.secondaryImage;
end

secondaryImageAfterShift = zeros(size(primaryImage));
try
    if floor(handles.verticalShift) <= -1 && floor(handles.horizontalShift) <= -1
        secondaryImageAfterShift(1:end+floor(handles.verticalShift), 1:end+floor(handles.horizontalShift)) = secondaryImage(-floor(handles.verticalShift) + 1:end, -floor(handles.horizontalShift) + 1:end);
    elseif floor(handles.verticalShift) <= -1 && floor(handles.horizontalShift) == 0
        secondaryImageAfterShift(1:end+floor(handles.verticalShift), :) = secondaryImage(-floor(handles.verticalShift) + 1:end, :);      
    elseif floor(handles.verticalShift) == 0 && floor(handles.horizontalShift) <= -1
        secondaryImageAfterShift(:, 1:end+floor(handles.horizontalShift)) = secondaryImage(:, -floor(handles.horizontalShift) + 1:end);
    elseif floor(handles.verticalShift) <= -1
        secondaryImageAfterShift(1:end+floor(handles.verticalShift), floor(handles.horizontalShift):end) = secondaryImage(-floor(handles.verticalShift) + 1:end, 1:end-floor(handles.horizontalShift)+1);            
    elseif floor(handles.horizontalShift) <= -1
        secondaryImageAfterShift(floor(handles.verticalShift):end, 1:end+floor(handles.horizontalShift)) = secondaryImage(1:end-floor(handles.verticalShift)+1, -floor(handles.horizontalShift) + 1:end);           
    elseif floor(handles.verticalShift) == 0 && floor(handles.horizontalShift) == 0
        secondaryImageAfterShift = secondaryImage;
    elseif floor(handles.horizontalShift) == 0
        secondaryImageAfterShift(floor(handles.verticalShift):end, :) = secondaryImage(1:end-floor(handles.verticalShift)+1, :);  
    elseif floor(handles.verticalShift) == 0
        secondaryImageAfterShift(:, floor(handles.horizontalShift):end) = secondaryImage(:, 1:end-floor(handles.horizontalShift)+1);  
    else
        secondaryImageAfterShift(floor(handles.verticalShift):end, floor(handles.horizontalShift):end) = secondaryImage(1:end-floor(handles.verticalShift)+1, 1:end-floor(handles.horizontalShift)+1);  
    end
catch

end
if floor(handles.horizontalShift) ~= str2num(get(handles.edit3, 'String'))
    set(handles.edit3, 'String', num2str(floor(handles.horizontalShift)));
    'here'
end
if floor(handles.verticalShift) ~= str2num(get(handles.edit2, 'String'))
    set(handles.edit2, 'String', num2str(floor(handles.verticalShift)));
end

sliderValue = get(handles.slider1, 'Value');
combinedImage = double(sliderValue*primaryImage) + double((1 - sliderValue)*secondaryImageAfterShift);
combinedImage = combinedImage/2^16;
imshow(combinedImage, 'Parent', handles.axes1);
handles.dataCursor.setHandles(handles);
guidata(handles.figure1, handles);

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function returnFocus(hObject)
set(hObject, 'Enable', 'off');
drawnow;
set(hObject, 'Enable', 'on');

% --- Executes on button press in Done.
function Done_Callback(hObject, eventdata, handles)
% hObject    handle to Done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%set(handles.text1,'String',ans)
guidata(hObject, handles);
if isequal(get(handles.figure1, 'waitstatus'),'waiting')
    uiresume(handles.figure1);

else
    delete(handles.figure1);
end
returnFocus(hObject)


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
