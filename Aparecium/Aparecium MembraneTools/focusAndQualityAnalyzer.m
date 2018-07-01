function varargout = focusAndQualityAnalyzer(varargin)
% FOCUSANDQUALITYANALYZER M-file for focusAndQualityAnalyzer.fig
%      FOCUSANDQUALITYANALYZER, by itself, creates a new FOCUSANDQUALITYANALYZER or raises the existing
%      singleton*.
%
%      H = FOCUSANDQUALITYANALYZER returns the handle to a new FOCUSANDQUALITYANALYZER or the handle to
%      the existing singleton*.
%
%      FOCUSANDQUALITYANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FOCUSANDQUALITYANALYZER.M with the given input arguments.
%
%      FOCUSANDQUALITYANALYZER('Property','Value',...) creates a new FOCUSANDQUALITYANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before focusAndQualityAnalyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to focusAndQualityAnalyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help focusAndQualityAnalyzer

% Last Modified by GUIDE v2.5 01-Jan-2010 12:03:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @focusAndQualityAnalyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @focusAndQualityAnalyzer_OutputFcn, ...
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


% --- Executes just before focusAndQualityAnalyzer is made visible.
function focusAndQualityAnalyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to focusAndQualityAnalyzer (see VARARGIN)

% Choose default command line output for focusAndQualityAnalyzer
handles.directoryName = varargin{1};
handles.requiredPattern = varargin{2};
handles.lowerBound = varargin{3}(1);
handles.upperBound = varargin{3}(2);
handles.spaceAllowed = 1;
handles.wellID = ImageImporter.getWellIDOfFolder(handles.directoryName, handles.requiredPattern);
handles.wellIndex = 1;
handles.selectingBadAreas = 0;
if numel(varargin) > 3
    handles.imageIndex = varargin{4};
    handles.standardIndex = varargin{4};
    set(handles.undefinedFocus, 'enable', 'on');
else
    handles.imageIndex = ones(numel(handles.wellID), 1)*-1;
    set(handles.undefinedFocus, 'enable', 'off');
    set(handles.focusDown, 'enable', 'off');
end
handles.imagesOfWell = [];
handles.masks = cell(numel(handles.wellID), 1);
for wellIndex = 1 : numel(handles.wellID)
    handles.masks{wellIndex} = false(904, 1224);
end
handles.focusImageNames = cell(numel(handles.wellID), 1);
for index = 1 : numel(handles.focusImageNames)
   handles.focusImageNames{index} = []; 
end
handles = createImageNameArrays(handles);
handles = displayImages(handles);
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1);
% UIWAIT makes focusAndQualityAnalyzer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.2]
function varargout = focusAndQualityAnalyzer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
names = handles.output;
names(cellfun(@isempty,handles.output)) = [];
varargout{1} = names;
if nargout > 1
    handles.imageIndex(cellfun(@isempty,handles.output)) = [];
    varargout{2} = handles.imageIndex;
end
if nargout > 2
    handles.masks(cellfun(@isempty,handles.output)) = [];
    varargout{3} = handles.masks;
end
delete(handles.figure1);

function handles = createImageNameArrays(handles)

fileListArray = dir([handles.directoryName,'\*.tif']);
%%reorganize the fileListArray to get all the file names
handles.nameArray = cell(length(fileListArray),1);
for i = 1 : length(fileListArray)
    if ~isempty(regexp(fileListArray(i).name, handles.requiredPattern))
        handles.nameArray{i} = fileListArray(i).name;
    end
end
handles.nameArray(cellfun(@isempty,handles.nameArray)) = [];
handles.imagesOfWell = cell(numel(handles.wellID), 1);
for wellIndex = 1 : numel(handles.wellID)
    handles.imagesOfWell{wellIndex} = [];
    for pic = 1 : size(handles.nameArray,1)
         if strfind(handles.nameArray{pic}, handles.wellID{wellIndex})
             zindex = strfind(handles.nameArray{pic}, '1Z') + 1;
             if(strcmp(handles.nameArray{pic}(zindex+2), '_'))
                 imageIndex = str2num(handles.nameArray{pic}(zindex+1))+1;
             else
                 imageIndex = str2num(handles.nameArray{pic}(zindex+1:zindex+2))+1;
             end
             handles.imagesOfWell{wellIndex}(imageIndex) = pic;
         end
    end
end

function handles = displayImages(handles)
try
    if handles.imageIndex(handles.wellIndex) <= handles.lowerBound
        if handles.wellIndex <= handles.lowerBound + 1
            handles.imageIndex(handles.wellIndex) = handles.lowerBound + 1;
        else
            handles.imageIndex(handles.wellIndex) = handles.imageIndex(handles.wellIndex-1);
        end
    end
    set(handles.fileName, 'String', ['Current image is ', handles.nameArray{handles.imagesOfWell{handles.wellIndex}(handles.imageIndex(handles.wellIndex))}]);
    if( isequal(get(handles.normalize,'Value'), 0) )
        image = imread([handles.directoryName, '\', handles.nameArray{handles.imagesOfWell{handles.wellIndex}(handles.imageIndex(handles.wellIndex))}]);
        image(handles.masks{handles.wellIndex}) = 0;
        imshow(image, 'Parent', handles.axes1);
    else
        image = double(imread([handles.directoryName, '\', handles.nameArray{handles.imagesOfWell{handles.wellIndex}(handles.imageIndex(handles.wellIndex))}]));
        image = (image - min(min(image)));
        image = image/max(max(image));
        image(handles.masks{handles.wellIndex}) = 0;
        imshow(image, 'Parent', handles.axes1);
    end
catch
    
end


% --- Executes on button press in focusUp.
function focusUp_Callback(hObject, eventdata, handles)
% hObject    handle to focusUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.imageIndex(handles.wellIndex) = handles.imageIndex(handles.wellIndex) + 1;
handles = displayImages(handles);
set(handles.focusDown, 'Enable', 'on');
if handles.imageIndex(handles.wellIndex) >= numel(handles.imagesOfWell{handles.wellIndex}) - handles.upperBound
    set(hObject, 'Enable', 'off'); 
end
guidata(hObject, handles);

% --- Executes on button press in focusDown.
function focusDown_Callback(hObject, eventdata, handles)
% hObject    handle to focusDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.imageIndex(handles.wellIndex) = handles.imageIndex(handles.wellIndex) - 1;
handles = displayImages(handles);
set(handles.focusUp, 'Enable', 'on');
if handles.imageIndex(handles.wellIndex) <= handles.lowerBound + 1
    set(hObject, 'Enable', 'off');  
end
guidata(hObject, handles);

% --- Executes on button press in declineImage.
function declineImage_Callback(hObject, eventdata, handles)
% hObject    handle to declineImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.focusImageNames{handles.wellIndex} = [];

 handles.focusImageNames{handles.wellIndex} = [];
 set(handles.previousImage, 'Enable', 'on'); 
 if(handles.wellIndex < numel(handles.wellID))
    handles.wellIndex = handles.wellIndex + 1;  
    handles = displayImages(handles);
 else
    set(handles.done, 'Enable', 'on'); 
 end
 if handles.imageIndex(handles.wellIndex) >= numel(handles.imagesOfWell{handles.wellIndex}) - handles.upperBound
    set(handles.focusUp, 'Enable', 'off'); 
else
    set(handles.focusUp, 'Enable', 'on'); 
end

if handles.imageIndex(handles.wellIndex) <= handles.lowerBound + 1
    set(handles.focusDown, 'Enable', 'off');  
else
    set(handles.focusDown, 'Enable', 'on');
end
 guidata(hObject, handles);

% --- Executes on button press in acceptImage.
function acceptImage_Callback(hObject, eventdata, handles)
% hObject    handle to acceptImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 handles.focusImageNames{handles.wellIndex} = handles.nameArray{handles.imagesOfWell{handles.wellIndex}(handles.imageIndex(handles.wellIndex))};
 set(handles.previousImage, 'Enable', 'on'); 
 if(handles.wellIndex < numel(handles.wellID))   
    handles.wellIndex = handles.wellIndex + 1;
    try
        handles = displayImages(handles);
    catch
        
    end
 else
    set(handles.done, 'Enable', 'on');  
 end
if handles.imageIndex(handles.wellIndex) >= numel(handles.imagesOfWell{handles.wellIndex}) - handles.upperBound
    set(handles.focusUp, 'Enable', 'off'); 
else
    set(handles.focusUp, 'Enable', 'on'); 
end

if handles.imageIndex(handles.wellIndex) <= handles.lowerBound + 1
    set(handles.focusDown, 'Enable', 'off');  
else
    set(handles.focusDown, 'Enable', 'on');
end
 guidata(hObject, handles);
% --- Executes on button press in previousImage.
function previousImage_Callback(hObject, eventdata, handles)
% hObject    handle to previousImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.done, 'Enable', 'off');  
if handles.wellIndex > 1
    handles.wellIndex = handles.wellIndex - 1;
else
    set(hObject, 'Enable', 'off'); 
end
if handles.imageIndex(handles.wellIndex) >= numel(handles.imagesOfWell{handles.wellIndex}) - handles.upperBound
    set(handles.focusUp, 'Enable', 'off'); 
else
    set(handles.focusUp, 'Enable', 'on'); 
end

if handles.imageIndex(handles.wellIndex) <= handles.lowerBound + 1
    set(handles.focusDown, 'Enable', 'off');  
else
    set(handles.focusDown, 'Enable', 'on');
end
handles = displayImages(handles);
guidata(hObject, handles);
% --- Executes on button press in undefinedFocus.
function undefinedFocus_Callback(hObject, eventdata, handles)
% hObject    handle to undefinedFocus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.focusUp, 'Enable', 'on');
set(handles.focusDown, 'Enable', 'on');
handles.focusImageNames{handles.wellIndex} = handles.nameArray{handles.imagesOfWell{handles.wellIndex}(handles.standardIndex(handles.wellIndex))};
set(handles.previousImage, 'Enable', 'on'); 
if(handles.wellIndex < numel(handles.wellID))   
    handles.wellIndex = handles.wellIndex + 1;  
    handles = displayImages(handles);
else
    set(handles.done, 'Enable', 'on');  
end
guidata(hObject, handles);

handles.standardIndex

% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = handles.focusImageNames;
%set(handles.fileName,'String',ans)
guidata(hObject, handles);
if isequal(get(handles.figure1, 'waitstatus'),'waiting')
    uiresume(handles.figure1)
    guidata(hObject, handles);
else
    delete(handles.figure1);
end

function returnFocus(hObject)
set(hObject, 'Enable', 'off');
drawnow;
set(hObject, 'Enable', 'on');


% --- Executes on button press in badQualitySelection.
function badQualitySelection_Callback(hObject, eventdata, handles)
% hObject    handle to badQualitySelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.selectingBadAreas = 1;
set(handles.focusUp, 'enable', 'off');
set(handles.focusDown, 'enable', 'off');
set(handles.declineImage, 'enable', 'off');
set(handles.acceptImage, 'enable', 'off');
set(handles.previousImage, 'enable', 'off');
set(handles.undefinedFocus, 'enable', 'off');
set(handles.done, 'enable', 'off');
set(handles.badQualitySelection, 'enable', 'off');
handles.spaceAllowed = 0;
set(handles.resumeToNormal, 'enable', 'off');
try
    k = imfreehand(handles.axes1);
    fcn = makeConstrainToRectFcn('imfreehand', [0, 1224], [0 904]);
    k.setPositionConstraintFcn(fcn);
    wait(k);
    mask = k.createMask();
    set(handles.figure1, 'waitstatus', 'waiting');% do not let wait meant for imfreehand interfere with the main figure
    if isempty(handles.masks{handles.wellIndex})
        handles.masks{handles.wellIndex} = mask;
    else
        handles.masks{handles.wellIndex} = or(handles.masks{handles.wellIndex}, mask);
    end
    image = double(imread([handles.directoryName, '\', handles.nameArray{handles.imagesOfWell{handles.wellIndex}(handles.imageIndex(handles.wellIndex))}]))/(2^16);
    mask = handles.masks{handles.wellIndex};
    % bg = bgest(image, 40);
    % image(mask) = bg(mask);
    % bounds = bwboundaries(mask);
    % for boundIndex = 1 : numel(bounds)
    %     for index = 1 : size(bounds{boundIndex}, 1)
    %         try
    %             y = bounds{boundIndex}(index, 1);
    %             x = bounds{boundIndex}(index, 2);
    %             for yt = y-5 : y + 5
    %                 for xt = x - 5 : x + 5
    %                     image(yt, xt) = mean(mean(image(yt - 3 : yt + 3 , xt - 3 : xt + 3)));
    %                 end
    %             end
    %         catch
    %             %'err'
    %         end
    %     end
    % end
    % image(mask) = image(mask) + 0.3*(image(round(rand(sum(sum(mask)), 1)*numel(image)))-mean(mean(image)));
    image(mask) = 0;
    imshow(image, 'Parent', handles.axes1);
catch
    'stop'
end

if handles.imageIndex(handles.wellIndex) >= numel(handles.imagesOfWell{handles.wellIndex}) - handles.upperBound
    set(handles.focusUp, 'Enable', 'off'); 
else
    set(handles.focusUp, 'Enable', 'on'); 
end

if handles.imageIndex(handles.wellIndex) <= handles.lowerBound + 1
    set(handles.focusDown, 'Enable', 'off');  
else
    set(handles.focusDown, 'Enable', 'on');
end
set(handles.declineImage, 'enable', 'on');
set(handles.acceptImage, 'enable', 'on');
set(handles.previousImage, 'enable', 'on');
set(handles.undefinedFocus, 'enable', 'on');
set(handles.badQualitySelection, 'enable', 'on');
handles.spaceAllowed = 1;
set(handles.resumeToNormal, 'enable', 'on');
guidata(hObject, handles);




% --- Executes on button press in resumeToNormal.
function resumeToNormal_Callback(hObject, eventdata, handles)
% hObject    handle to resumeToNormal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in normalize.
function normalize_Callback(hObject, eventdata, handles)
% hObject    handle to normalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of normalize
handles = displayImages(handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.wellIndex = 1;
for index = 1 : numel(handles.wellID)
 handles.focusImageNames{handles.wellIndex} = handles.nameArray{handles.imagesOfWell{handles.wellIndex}(handles.imageIndex(handles.wellIndex))};
 set(handles.previousImage, 'Enable', 'on'); 
 if(handles.wellIndex < numel(handles.wellID))   
    handles.wellIndex = handles.wellIndex + 1;  
    handles = displayImages(handles);
 else
    set(handles.done, 'Enable', 'on');  
 end
end
guidata(hObject, handles)


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
key = eventdata.Key;
if strcmp(key, 'b') && handles.spaceAllowed
    badQualitySelection_Callback(handles.badQualitySelection, [], handles);
end


% --- Executes on button press in loadMasks.
function loadMasks_Callback(hObject, eventdata, handles)
% hObject    handle to loadMasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadMasks
imageDir = uigetdir('','Choose the folder with corresponding masks');
files = dir(imageDir);
files(1:2) = [];
nameArray = cell(0, 0);
for index = 1 : numel(files)
    if ~isempty(strfind(files(index).name, '.tif'))
        nameArray{end+1} = files(index).name;
    end
end
nameArray = ImageImporter.sortWellID(nameArray);
masks = cell(numel(nameArray), 1);
for index = 1 : numel(nameArray)
    masks{index} = imread([imageDir, '\' ,nameArray{index}]);
end
guidata(hObject, handles);

%answer = questdlg('Do you want to remove images, that do not have a mask?');
%if strcmp(answer, 'Yes')
    wellID = ImageImporter.getWellIDOfStringArray(nameArray, '.tif');
    handles.focusImageNames = nameArray;
    handles.masks = masks;
    indices = zeros(numel(wellID), 1);
    for index = 1 : numel(wellID)
        indices(index) = find(strcmp(handles.wellID, wellID{index}) == 1);
    end
    handles.wellID = handles.wellID(indices);
    handles.imagesOfWell = handles.imagesOfWell(indices);
    handles.imageIndex = handles.imageIndex(indices);
    for wellIndex = 1 : numel(handles.wellID)
        for imIndex = 1 : numel(handles.imagesOfWell{wellIndex})
            imageName = handles.nameArray{handles.imagesOfWell{wellIndex}(imIndex)};
            if strcmp(imageName, nameArray{wellIndex})
               handles.imageIndex(wellIndex) = imIndex;
            end
        end
    end
%elseif strcmp(answer, 'No')
    
%else
    
%end
displayImages(handles);
guidata(hObject, handles);
