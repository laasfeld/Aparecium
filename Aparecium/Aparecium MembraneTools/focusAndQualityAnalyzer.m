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

% Last Modified by GUIDE v2.5 17-Jan-2023 01:27:10

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
if ischar(varargin{1})
    handles.directoryName = varargin{1};
    handles.requiredPattern = varargin{2};
    handles.lowerBound = varargin{3}(1);
    handles.upperBound = varargin{3}(2);
    handles.spaceAllowed = 1;
    [handles.wellID, handles.wellID_location_indices, handles.nameArray] = ImageImporter.getWellIDOfFolder(handles.directoryName, handles.requiredPattern);
    handles.wellIndex = 1;
    handles.imageInWellIndex = 1;
    handles.selectingBadAreas = 0;

    if numel(varargin) > 4 
        handles.focusAndQualityAnalyzerHandle = varargin{5}{1};
    else
        handles.focusAndQualityAnalyzerHandle = FocusAndQualityAnalyzerHandle();
    end

    if numel(varargin) > 3 && ~isempty(varargin{4})
        handles.imageIndex = varargin{4};
        handles.standardIndex = varargin{4};
        set(handles.undefinedFocus, 'enable', 'on');
    else
        handles.imageIndex = cell(numel(handles.wellID), 1);
        for index = 1 : numel(handles.imageIndex)
            handles.imageIndex{index} = ones(numel(handles.wellID_location_indices{index}), 1)*-1;
        end

        set(handles.undefinedFocus, 'enable', 'off');
        set(handles.focusDown, 'enable', 'off');
    end
    handles.imagesOfWell = [];
    handles.masks = cell(numel(handles.wellID), 1);
    handles.historySteps = 5;
    for wellIndex = 1 : numel(handles.wellID)
        for wellImageLocation = 1 : numel(handles.wellID_location_indices{wellIndex})
            handles.masks{wellIndex}{wellImageLocation} = false(904, 1224);
            for historyIndex = 1 : handles.historySteps
                handles.masks_history{wellIndex}{wellImageLocation}{historyIndex} = [];
            end
        end
    end
    handles.focusImageNames = cell(numel(handles.wellID), 1);
    for index = 1 : numel(handles.focusImageNames)
        for wellImageLocation = 1 : numel(handles.wellID_location_indices{wellIndex})
            handles.focusImageNames{index}{wellImageLocation} = []; 
        end
    end
    handles = createImageNameArrays(handles);
    handles = displayImages(handles);
    handles.output = hObject;
    handles.qualityFilterNetwork = [];
    handles.qualityFilterThreshold = 0.5;
    set(handles.modelThresholdField, 'String', num2str(handles.qualityFilterThreshold));

    % Update handles structure
    handles.focusAndQualityAnalyzerHandle.updateHandles(handles);
else
    handle_fields = fields(handles);
    needed_fields = fields(varargin{1}{1}.handle);
    missing_fields = setdiff(needed_fields, handle_fields);
    for field_index = 1 : numel(missing_fields)
        handles.(missing_fields{field_index}) = varargin{1}{1}.handle.(missing_fields{field_index});
    end
    handles = displayImages(handles);
    %handles = varargin{1}{1}.handle;
    
end
handles.loadedMaskMode = 'binary';
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
%handles.nameArray = cell(length(fileListArray),1);
%for i = 1 : length(fileListArray)
%    if ~isempty(regexp(fileListArray(i).name, handles.requiredPattern))
%        handles.nameArray{i} = fileListArray(i).name;
%    end
%end
handles.nameArray(cellfun(@isempty,handles.nameArray)) = [];
handles.imagesOfWellAtLocation = cell(numel(handles.wellID), 1);
for pic = 1 : size(handles.nameArray, 1)
    wellID = ImageImporter.findWellIDOfString(handles.nameArray{pic});
    wellIDIndex = find(strcmp(handles.wellID, wellID));
    imagingLocation = ImageImporter.getImageInWellIndexOfString(handles.nameArray{pic});
    imagingLocationIndex = handles.wellID_location_indices{wellIDIndex} == imagingLocation;
    ZplaneIndex = ImageImporter.getImagePlaneIndexOfString(handles.nameArray{pic}) + 1;
    handles.imagesOfWell{wellIDIndex}{imagingLocationIndex}(ZplaneIndex) = pic;
end
% if some images were missing then remove zeros
for wellIDIndex = 1 : numel(handles.imagesOfWell)
    for imageLocationIndex = 1 : numel(handles.imagesOfWell{wellIDIndex})
        handles.imagesOfWell{wellIDIndex}{imageLocationIndex}(handles.imagesOfWell{wellIDIndex}{imageLocationIndex} == 0) = [];
    end
end

% for wellIndex = 1 : numel(handles.wellID)
%     handles.imagesOfWell{wellIndex} = [];
%     for pic = 1 : size(handles.nameArray,1)
%          if strfind(handles.nameArray{pic}, handles.wellID{wellIndex})
%              zindex = strfind(handles.nameArray{pic}, '1Z') + 1;
%              if(strcmp(handles.nameArray{pic}(zindex+2), '_'))
%                  imageIndex = str2num(handles.nameArray{pic}(zindex+1))+1;
%              else
%                  imageIndex = str2num(handles.nameArray{pic}(zindex+1:zindex+2))+1;
%              end
%              handles.imagesOfWell{wellIndex}(imageIndex) = pic;
%          end
%     end
% end

function handles = displayImages(handles, varargin)

if numel(varargin) > 0
    doDisplay = varargin{1};
else
    doDisplay = true;
end

try
    if handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex) <= handles.lowerBound % impossible image index in this context
        if isequal(handles.wellIndex, 1) && isequal(handles.imageInWellIndex, 1) % handle the case where no previous image focus is available
            handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex) = handles.lowerBound + 1;
        elseif isequal(handles.imageInWellIndex, 1) % handle the case where previous image focus is available but in previous well
            handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex) = handles.imageIndex{handles.wellIndex - 1}(end);
        else
            handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex) = handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex - 1);
        end
    end
    if doDisplay
        fileName = handles.nameArray{handles.imagesOfWell{handles.wellIndex}{handles.imageInWellIndex}(handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex))};
        set(handles.fileName, 'String', ['Current image is ', fileName]);
        if( isequal(get(handles.normalize,'Value'), 0) )
            image = imread(fullfile(handles.directoryName, fileName));
        else
            image = double(imread(fullfile(handles.directoryName, fileName)));
            image = (image - min(min(image)));
            image = image/max(max(image));
        end
        mask = handles.masks{handles.wellIndex}{handles.imageInWellIndex};
        masked = image;
        masked(mask) = 0;
        image = cat(3, cat(3, image, masked), masked);
        %image = zeros(904, 1224, 3);
        if get(handles.displayProbabilityMap, 'Value') && strcmp(handles.loadedMaskMode, 'probability')
            image(:,:,1) = image(:,:,1) + uint16(log2(double(handles.probabilityMaps{handles.wellIndex}{handles.imageInWellIndex}))*(2^12)*0.5);
            image(:,:,3) = image(:,:,3) - uint16(log2(double(handles.probabilityMaps{handles.wellIndex}{handles.imageInWellIndex}))*(2^12)*0.5);
        end
        imshow(image, 'Parent', handles.axes1);
    end
catch
    
end

function handles = setMask(mask, wellIndex, wellImageLocation, handles)

for historyIndex = 1 : handles.historySteps - 1
    handles.masks_history{wellIndex}{wellImageLocation}{historyIndex} = handles.masks_history{wellIndex}{wellImageLocation}{historyIndex + 1};
end
handles.masks_history{wellIndex}{wellImageLocation}{handles.historySteps} = handles.masks{wellIndex}{wellImageLocation};
handles.masks{wellIndex}{wellImageLocation} = mask;%or(mask, handles.masks{handles.wellIndex}{handles.imageInWellIndex});
guidata(handles.figure1, handles);

function reversable = isMaskReversable(wellIndex, wellImageLocation, handles)

reversable = ~isempty(handles.masks_history{wellIndex}{wellImageLocation}{handles.historySteps});

function handles = reverseMask(wellIndex, wellImageLocation, handles)

handles.masks{handles.wellIndex}{handles.imageInWellIndex} = handles.masks_history{wellIndex}{wellImageLocation}{handles.historySteps};

for historyIndex = handles.historySteps : -1 : 2
    handles.masks_history{wellIndex}{wellImageLocation}{historyIndex} = handles.masks_history{wellIndex}{wellImageLocation}{historyIndex - 1};
end
handles.masks_history{wellIndex}{wellImageLocation}{1} = [];

guidata(handles.figure1, handles);

% --- Executes on button press in focusUp.
function focusUp_Callback(hObject, eventdata, handles)
% hObject    handle to focusUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex) = handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex) + 1;
handles = displayImages(handles);
set(handles.focusDown, 'Enable', 'on');
if handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex) >= numel(handles.imagesOfWell{handles.wellIndex}{handles.imageInWellIndex}) - handles.upperBound
    set(hObject, 'Enable', 'off'); 
end
handles.focusAndQualityAnalyzerHandle.updateHandles(handles);
guidata(hObject, handles);

% --- Executes on button press in focusDown.
function focusDown_Callback(hObject, eventdata, handles)
% hObject    handle to focusDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex) = handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex) - 1;
handles = displayImages(handles);
set(handles.focusUp, 'Enable', 'on');
if handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex) <= handles.lowerBound + 1
    set(hObject, 'Enable', 'off');  
end
handles.focusAndQualityAnalyzerHandle.updateHandles(handles);
guidata(hObject, handles);

function handles = nextImageSelection(handles, varargin)

if numel(varargin) > 0
    doDisplay = varargin{1};
else
    doDisplay = true;
end

if handles.imageInWellIndex < numel(handles.wellID_location_indices{handles.wellIndex})  
    handles.imageInWellIndex = handles.imageInWellIndex + 1;
    set(handles.previousImage, 'Enable', 'on'); 
    try
        handles = displayImages(handles, doDisplay);
    catch

    end
elseif handles.wellIndex < numel(handles.wellID)
    handles.wellIndex = handles.wellIndex + 1;
    handles.imageInWellIndex = 1;
    set(handles.previousImage, 'Enable', 'on'); 
    try
        handles = displayImages(handles, doDisplay);
    catch

    end  
else
    set(handles.done, 'Enable', 'on');  
end
handles = setFocusButtonStates(handles);

function handles = previousImageSelection(handles)
 
if handles.imageInWellIndex > 1  
    handles.imageInWellIndex = handles.imageInWellIndex - 1;
    try
        handles = displayImages(handles);
    catch

    end
elseif handles.wellIndex > 1
    handles.wellIndex = handles.wellIndex - 1;
    handles.imageInWellIndex = numel(handles.wellID_location_indices{handles.wellIndex});
    try
        handles = displayImages(handles);
    catch

    end  
else

end
handles = setFocusButtonStates(handles);


function handles = setFocusButtonStates(handles)

try
    if handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex) >= numel(handles.imagesOfWell{handles.wellIndex}{handles.imageInWellIndex}) - handles.upperBound
        set(handles.focusUp, 'Enable', 'off'); 
    else
        set(handles.focusUp, 'Enable', 'on'); 
    end
catch
    ''
end

if handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex) <= handles.lowerBound + 1
    set(handles.focusDown, 'Enable', 'off');  
else
    set(handles.focusDown, 'Enable', 'on');
end


% --- Executes on button press in declineImage.
function declineImage_Callback(hObject, eventdata, handles)
% hObject    handle to declineImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.focusImageNames{handles.wellIndex}{handles.imageInWellIndex} = [];
handles = nextImageSelection(handles);
handles.focusAndQualityAnalyzerHandle.updateHandles(handles);
guidata(hObject, handles);

% --- Executes on button press in acceptImage.
function acceptImage_Callback(hObject, eventdata, handles)
% hObject    handle to acceptImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.focusImageNames{handles.wellIndex}{handles.imageInWellIndex} = handles.nameArray{handles.imagesOfWell{handles.wellIndex}{handles.imageInWellIndex}(handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex))};
handles = nextImageSelection(handles);
handles.focusAndQualityAnalyzerHandle.updateHandles(handles);
guidata(hObject, handles);

% --- Executes on button press in previousImage.
function previousImage_Callback(hObject, eventdata, handles)
% hObject    handle to previousImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.done, 'Enable', 'off');  
handles = previousImageSelection(handles);
handles.focusAndQualityAnalyzerHandle.updateHandles(handles);
guidata(hObject, handles);

% --- Executes on button press in undefinedFocus.
function undefinedFocus_Callback(hObject, eventdata, handles)
% hObject    handle to undefinedFocus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.focusImageNames{handles.wellIndex}{handles.imageInWellIndex} = handles.nameArray{handles.imagesOfWell{handles.wellIndex}{handles.imageInWellIndex}(handles.standardIndex{handles.wellIndex}(handles.imageInWellIndex))};
handles = nextImageSelection(handles);
handles.focusAndQualityAnalyzerHandle.updateHandles(handles);
guidata(hObject, handles);


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
set(handles.pushbutton17, 'enable', 'off');
set(handles.done, 'enable', 'off');
set(handles.badQualitySelection, 'enable', 'off');
handles.spaceAllowed = 0;
set(handles.resumeToNormal, 'enable', 'off');
try
    k = imfreehand(handles.axes1);
    fcn = makeConstrainToRectFcn('imfreehand', [0, 1224], [0 904]);
    k.setPositionConstraintFcn(fcn);
    handles.freehandHandle = k;
    set(handles.resumeToNormal, 'enable', 'on');
    guidata(hObject, handles);
    wait(k);
    mask = k.createMask();
    set(handles.figure1, 'waitstatus', 'waiting');% do not let wait meant for imfreehand interfere with the main figure
    if isempty(handles.masks{handles.wellIndex}{handles.imageInWellIndex})

    else
        mask = or(handles.masks{handles.wellIndex}{handles.imageInWellIndex}, mask);
    end
    handles = setMask(mask, handles.wellIndex, handles.imageInWellIndex, handles);

    
    fileName = handles.nameArray{handles.imagesOfWell{handles.wellIndex}{handles.imageInWellIndex}(handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex))};

    image = double(imread([handles.directoryName, '\', fileName]))/(2^16);
    mask = handles.masks{handles.wellIndex}{handles.imageInWellIndex};
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
    masked = image;
    masked(mask) = 0;
    image = cat(3, cat(3, image, masked), masked);
    %image(mask) = 0;
    imshow(image, 'Parent', handles.axes1);
catch
    'stop'
end

handles = setFocusButtonStates(handles);
set(handles.declineImage, 'enable', 'on');
set(handles.acceptImage, 'enable', 'on');
set(handles.previousImage, 'enable', 'on');
set(handles.undefinedFocus, 'enable', 'on');
set(handles.badQualitySelection, 'enable', 'on');
set(handles.pushbutton17, 'enable', 'on');
handles.spaceAllowed = 1;
set(handles.resumeToNormal, 'enable', 'on');
handles.focusAndQualityAnalyzerHandle.updateHandles(handles);
displayImages(handles);
guidata(hObject, handles);


% --- Executes on button press in resumeToNormal.
function resumeToNormal_Callback(hObject, eventdata, handles)
% hObject    handle to resumeToNormal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
resume(handles.freehandHandle);

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
handles.focusAndQualityAnalyzerHandle.updateHandles(handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.wellIndex = 1;
handles.imageInWellIndex = 1;
for index = 1 : numel(handles.wellID)
    index
    for imageInWellIndex = 1 : numel(handles.imageIndex{index})
        try
            handles.focusImageNames{index}{imageInWellIndex} = handles.nameArray{handles.imagesOfWell{index}{imageInWellIndex}...
                (handles.imageIndex{index}(imageInWellIndex))};
        catch
            ''
        end
        handles = nextImageSelection(handles, false);
    end
end
nextImageSelection(handles);
handles.focusAndQualityAnalyzerHandle.updateHandles(handles);
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
    return
end
if strcmp(key, 's') && handles.spaceAllowed
    pushbutton22_Callback(handles.pushbutton22, eventdata, handles);
    return
end
if strcmp(key, 'd') && handles.spaceAllowed
    pushbutton23_Callback(handles.pushbutton23, eventdata, handles);
    return
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
%nameArray = ImageImporter.sortWellID(nameArray);
masks = cell(numel(nameArray), 1);
for index = 1 : numel(nameArray)
    masks{index} = imread([imageDir, '\', nameArray{index}]);
end
handles.focusAndQualityAnalyzerHandle.updateHandles(handles);
guidata(hObject, handles);

%answer = questdlg('Do you want to remove images, that do not have a mask?');
%if strcmp(answer, 'Yes')
wellID = ImageImporter.getWellIDOfStringArray(nameArray, '.tif');
%handles.focusImageNames = nameArray;
for pic = 1 : numel(masks)
    wellIDName = ImageImporter.findWellIDOfString(nameArray{pic});
    wellIDIndex = find(strcmp(handles.wellID, wellIDName) == 1);
    imagingLocation = ImageImporter.getImageInWellIndexOfString(nameArray{pic});
    imagingLocationIndex = handles.wellID_location_indices{wellIDIndex} == imagingLocation;
    wellIDIndex
    imagingLocationIndex
    handles = setMask(masks{pic}, wellIDIndex, find(imagingLocationIndex==1), handles);
end

indices = zeros(numel(wellID), 1);
for index = 1 : numel(wellID)
    indices(index) = find(strcmp(handles.wellID, wellID{index}) == 1);
end
%handles.wellID = handles.wellID(indices);
%handles.imagesOfWell = handles.imagesOfWell(indices);
%handles.imageIndex = handles.imageIndex(indices);
%handles.masks = handles.masks(indices);
%handles.focusImageNames = handles.focusImageNames(indices);
for wellIndex = 1 : numel(handles.wellID)
    for imagingLocation = 1 : numel(handles.imagesOfWell{wellIndex})
        for imIndex = 1 : numel(handles.imagesOfWell{wellIndex}{imagingLocation})
            imageName = handles.nameArray{handles.imagesOfWell{wellIndex}{imagingLocation}(imIndex)};
            if ~isempty(find(strcmp(nameArray, imageName)))
                handles.imageIndex{wellIndex}(imagingLocation) = imIndex;
                handles.focusImageNames{wellIndex}{imagingLocation} = imageName;
                break;
            end
            handles.focusImageNames{wellIndex}{imagingLocation} = [];
        end
    end
    handles.wellIndex = wellIndex;
    handles.imageInWellIndex = imagingLocation;
end
%elseif strcmp(answer, 'No')
    
%else
    
%end
set(handles.previousImage, 'enable', 'on');
guidata(hObject, handles);
displayImages(handles);
handles.focusAndQualityAnalyzerHandle.updateHandles(handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    fileName = handles.nameArray{handles.imagesOfWell{handles.wellIndex}{handles.imageInWellIndex}(handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex))};
    handles = setMask(zeros(size(double(imread([handles.directoryName, '\', fileName]))/(2^16))), handles.wellIndex, handles.imageInWellIndex, handles);
    %handles.masks{handles.wellIndex}{handles.imageInWellIndex} = zeros(size(double(imread([handles.directoryName, '\', fileName]))/(2^16)));

    image = double(imread([handles.directoryName, '\', fileName]))/(2^16);
    mask = handles.masks{handles.wellIndex}{handles.imageInWellIndex};
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
    masked = image;
    masked(mask) = 0;
    image = cat(3, cat(3, image, masked), masked);
    %image(mask) = 0;
    imshow(image, 'Parent', handles.axes1);
catch
    'stop'
end
handles.focusAndQualityAnalyzerHandle.updateHandles(handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.selectingBadAreas = 1;
set(handles.focusUp, 'enable', 'off');
set(handles.focusDown, 'enable', 'off');
set(handles.declineImage, 'enable', 'off');
set(handles.acceptImage, 'enable', 'off');
set(handles.previousImage, 'enable', 'off');
set(handles.undefinedFocus, 'enable', 'off');
set(handles.pushbutton17, 'enable', 'off');
set(handles.done, 'enable', 'off');
set(handles.badQualitySelection, 'enable', 'off');
handles.spaceAllowed = 0;
set(handles.resumeToNormal, 'enable', 'off');
try
    k = imfreehand(handles.axes1);
    fcn = makeConstrainToRectFcn('imfreehand', [0, 1224], [0 904]);
    k.setPositionConstraintFcn(fcn);
    handles.freehandHandle = k;
    set(handles.resumeToNormal, 'enable', 'on');
    guidata(hObject, handles);
    wait(k);
    mask = k.createMask();
    set(handles.figure1, 'waitstatus', 'waiting');% do not let wait meant for imfreehand interfere with the main figure
    if isempty(handles.masks{handles.wellIndex}{handles.imageInWellIndex})
        handles = setMask(zeros(size(mask)), handles.wellIndex, handles.imageInWellIndex, handles);
    else
        handles = setMask(and(handles.masks{handles.wellIndex}{handles.imageInWellIndex}, ~mask), handles.wellIndex, handles.imageInWellIndex, handles);
    end
    
    fileName = handles.nameArray{handles.imagesOfWell{handles.wellIndex}{handles.imageInWellIndex}(handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex))};

    image = double(imread([handles.directoryName, '\', fileName]))/(2^16);
    mask = handles.masks{handles.wellIndex}{handles.imageInWellIndex};
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
    masked = image;
    masked(mask) = 0;
    image = cat(3, cat(3, image, masked), masked);
    %image(mask) = 0;
    imshow(image, 'Parent', handles.axes1);
catch
    'stop'
end

handles = setFocusButtonStates(handles);
set(handles.declineImage, 'enable', 'on');
set(handles.acceptImage, 'enable', 'on');
set(handles.previousImage, 'enable', 'on');
set(handles.undefinedFocus, 'enable', 'on');
set(handles.badQualitySelection, 'enable', 'on');
set(handles.pushbutton17, 'enable', 'on');
handles.spaceAllowed = 1;
set(handles.resumeToNormal, 'enable', 'on');
handles.focusAndQualityAnalyzerHandle.updateHandles(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function loadMasks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadMasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in load_quality_filter.
function load_quality_filter_Callback(hObject, eventdata, handles)
% hObject    handle to load_quality_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName, filePath] = uigetfile({'*.hdf5','Keras model'; '*.h5', 'Keras model'});
handles.qualityFilterNetwork = importKerasNetwork(fullfile(filePath, fileName));
guidata(hObject, handles);

% --- Executes on button press in Apply_filter.
function Apply_filter_Callback(hObject, eventdata, handles)
% hObject    handle to Apply_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.qualityFilterNetwork
mask = handles.masks{handles.wellIndex}{handles.imageInWellIndex};
fileName = handles.nameArray{handles.imagesOfWell{handles.wellIndex}{handles.imageInWellIndex}(handles.imageIndex{handles.wellIndex}(handles.imageInWellIndex))};
image = imread([handles.directoryName, '\', fileName]);
predictedMask = imresize(handles.qualityFilterNetwork.predict(imresize(double(image)/(2^16), handles.qualityFilterNetwork.Layers(1).InputSize(1:2))), size(image));
autoMask = predictedMask > handles.qualityFilterThreshold;
handles = setMask(or(mask, autoMask), handles.wellIndex, handles.imageInWellIndex, handles);
guidata(hObject, handles);
displayImages(handles);



function modelThresholdField_Callback(hObject, eventdata, handles)
% hObject    handle to modelThresholdField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of modelThresholdField as text
%        str2double(get(hObject,'String')) returns contents of modelThresholdField as a double
handles.qualityFilterThreshold = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function modelThresholdField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to modelThresholdField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in loadProbabilityMapsAndFocus.
function loadProbabilityMapsAndFocus_Callback(hObject, eventdata, handles)
% hObject    handle to loadProbabilityMapsAndFocus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imageDir = uigetdir('','Choose the folder with corresponding masks');
files = dir(imageDir);
files(1:2) = [];
nameArray = cell(0, 0);
for index = 1 : numel(files)
    if ~isempty(strfind(files(index).name, '.tif'))
        nameArray{end+1} = files(index).name;
    end
end
%nameArray = ImageImporter.sortWellID(nameArray);
probabilityMaps = cell(numel(nameArray), 1);
for index = 1 : numel(nameArray)
    probabilityMaps{index} = imread([imageDir, '\', nameArray{index}]);
end
handles.focusAndQualityAnalyzerHandle.updateHandles(handles);
guidata(hObject, handles);

%answer = questdlg('Do you want to remove images, that do not have a mask?');
%if strcmp(answer, 'Yes')
wellID = ImageImporter.getWellIDOfStringArray(nameArray, '.tif');
%handles.focusImageNames = nameArray;
for pic = 1 : numel(probabilityMaps)
    wellIDName = ImageImporter.findWellIDOfString(nameArray{pic});
    wellIDIndex = strcmp(handles.wellID, wellIDName);
    imagingLocation = ImageImporter.getImageInWellIndexOfString(nameArray{pic});
    imagingLocationIndex = handles.wellID_location_indices{wellIDIndex} == imagingLocation;    
    handles.probabilityMaps{wellIDIndex}{imagingLocationIndex} = probabilityMaps{pic};
end

indices = zeros(numel(wellID), 1);
for index = 1 : numel(wellID)
    indices(index) = find(strcmp(handles.wellID, wellID{index}) == 1);
end
%handles.wellID = handles.wellID(indices);
%handles.imagesOfWell = handles.imagesOfWell(indices);
%handles.imageIndex = handles.imageIndex(indices);
%handles.masks = handles.masks(indices);
%handles.focusImageNames = handles.focusImageNames(indices);
for wellIndex = 1 : numel(handles.wellID)
    for imagingLocation = 1 : numel(handles.imagesOfWell{wellIndex})
        for imIndex = 1 : numel(handles.imagesOfWell{wellIndex}{imagingLocation})
            imageName = handles.nameArray{handles.imagesOfWell{wellIndex}{imagingLocation}(imIndex)};
            if ~isempty(find(strcmp(nameArray, imageName)))
                handles.imageIndex{wellIndex}(imagingLocation) = imIndex;
                handles.focusImageNames{wellIndex}{imagingLocation} = imageName;
                break;
            end
            handles.focusImageNames{wellIndex}{imagingLocation} = [];
        end
    end
    handles.wellIndex = wellIndex;
    handles.imageInWellIndex = imagingLocation;
end
%elseif strcmp(answer, 'No')
    
%else
    
%end
handles.loadedMaskMode = 'probability';
guidata(hObject, handles);
displayImages(handles);
handles.focusAndQualityAnalyzerHandle.updateHandles(handles);
set(handles.previousImage, 'Enable', 'on'); 
guidata(hObject, handles);

% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
while true
    axes(handles.axes1);
    h = drawpoint(handles.axes1);
    if isempty(h.Position)       
        break
    end
    position = round(h.Position);
    probabilityValue = handles.probabilityMaps{handles.wellIndex}{handles.imageInWellIndex}(position(2), position(1));
    probabilityValue
    maskedProbability = handles.probabilityMaps{handles.wellIndex}{handles.imageInWellIndex} >= probabilityValue;
    cc = bwconncomp(maskedProbability);
    ind = sub2ind(size(maskedProbability), position(2), position(1)); 
    for ccindex = 1 : numel(cc.PixelIdxList)
        if find(cc.PixelIdxList{ccindex} == ind)
            object_index = ccindex;
            break
        end
    end
    %figure
    mask = zeros(size(maskedProbability));
    mask(cc.PixelIdxList{object_index}) = 1;
    %mask = mask';
    %imshow(mask);
    addedMask = logical(handles.masks{handles.wellIndex}{handles.imageInWellIndex} + logical(maskedProbability));
    handles = setMask(addedMask,handles.wellIndex,handles.imageInWellIndex, handles);
    guidata(hObject, handles);
    displayImages(handles);
end


% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
while true
    h = drawpoint(handles.axes1);
    if isempty(h.Position)       
        break
    end
    position = round(h.Position);
    guidata(hObject, handles);
    
    probabilityValue = handles.probabilityMaps{handles.wellIndex}{handles.imageInWellIndex}(position(2), position(1));
    probabilityValue
    maskedProbability = handles.probabilityMaps{handles.wellIndex}{handles.imageInWellIndex} >= probabilityValue;
    cc = bwconncomp(maskedProbability);
    ind = sub2ind(size(maskedProbability), position(2), position(1)); 
    for ccindex = 1 : numel(cc.PixelIdxList)
        if find(cc.PixelIdxList{ccindex} == ind)
            object_index = ccindex;
            break
        end
    end
    %figure
    mask = zeros(size(maskedProbability));
    mask(cc.PixelIdxList{object_index}) = 1;
    %mask = mask';
    %imshow(mask);
    addedMask = logical(handles.masks{handles.wellIndex}{handles.imageInWellIndex} + logical(mask));
    handles = setMask(addedMask,handles.wellIndex,handles.imageInWellIndex, handles);
    guidata(hObject, handles);

    displayImages(handles);
end
guidata(hObject, handles);

% --- Executes on button press in displayProbabilityMap.
function displayProbabilityMap_Callback(hObject, eventdata, handles)
% hObject    handle to displayProbabilityMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayImages(handles);
% Hint: get(hObject,'Value') returns toggle state of displayProbabilityMap


% --- Executes on button press in reverseMask.
function reverseMask_Callback(hObject, eventdata, handles)
% hObject    handle to reverseMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isMaskReversable(handles.wellIndex, handles.imageInWellIndex, handles)
    handles = reverseMask(handles.wellIndex, handles.imageInWellIndex, handles);
end
displayImages(handles);
guidata(hObject, handles)
