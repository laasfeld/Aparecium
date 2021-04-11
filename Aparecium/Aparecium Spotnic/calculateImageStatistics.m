function tifFilesNames = calculateImageStatistics(varargin)

if length(varargin) < 1
    threshold = 0;
else
    threshold = varargin{1};
end

if length(varargin) < 2
    folderName = uigetdir; % the folder in which images exists
else
    folderName = varargin{2}; 
end

if length(varargin) < 3
    calculateVoronoi = false;
else
    calculateVoronoi = varargin{3}; 
end

if length(varargin) < 4
    layersToUse = 1;
else
    layersToUse = varargin{4}; 
end

if length(varargin) < 5
    stackSizeThreshold = 0;
else
    stackSizeThreshold = varargin{5}; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collect tif files names and path from folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dirInfo = dir(fullfile(folderName,'*.tif'));

tifFilesNames = {};
layersToRead = {};
width = {};
height = {};
counter = 1;
for i=1:size(dirInfo, 1)
    info = imfinfo(fullfile(folderName, dirInfo(i).name));
    if isequal(numel(info), 1) 
        tifFilesNames{counter,1} = fullfile(folderName, dirInfo(i).name);
        layersToRead{counter, 1} = 1;
        width{counter, 1} = info(1).Width;
        height{counter, 1} = info(1).Height;
        counter = counter + 1;
    elseif stackSizeThreshold < numel(info)
        [imageLocationIndices, timeIndexVector] = imageLocExtractor(fullfile(folderName, dirInfo(i).name));
        uniqueLocations = unique(imageLocationIndices);
        for locationIndex = 1 : numel(uniqueLocations)
            tifFilesNames{counter, 1} = fullfile(folderName, dirInfo(i).name);
            rows = find(imageLocationIndices == locationIndex);
            timeIndices = timeIndexVector(rows);
            if strcmp(layersToUse, 'max')
                layersToRead{counter, 1} = rows(timeIndices(:));
            else
                layersToRead{counter, 1} = rows(timeIndices(layersToUse));
            end
            width{counter, 1} = info(1).Width;
            height{counter, 1} = info(1).Height;
            counter = counter + 1;
        end       
    end    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check tif files in subfolders and if exist collect tif files names and path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dirInfo = dir(folderName);
dirInfo(~[dirInfo.isdir]) = [];


for k = 3 : size(dirInfo,1)
    subDirInfo = dir(fullfile(folderName, dirInfo(k).name, '*.tif'));
    if size(subDirInfo, 1) ~= 0
        for i=1:size(subDirInfo, 1)            
            tifFilesNames{end+1,1} = fullfile(folderName, dirInfo(k).name, subDirInfo(i).name);
        end
    else        
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Detect spots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for i = 1 : size(tifFilesNames,1)
    frame = zeros(height{i}, width{i}, numel(layersToRead{i}));
    if numel(varargin) < 6
        for k = 1 : numel(layersToRead{i})
            frame(:,:,k) = imread(tifFilesNames{i}, layersToRead{i}(k));
        end
    else
        image = varargin{6}(tifFilesNames{i});
        for k = 1 : numel(layersToRead{i})
            frame(:,:,k) = image(:,:, layersToRead{i}(k));
        end
    end
    frame = mean(frame, 3);
    
    tifFilesNames{i, 2} = mean(reshape(frame, numel(frame), 1));
    tifFilesNames{i, 3} = median(reshape(frame, numel(frame), 1));
    tifFilesNames{i, 4} = std(reshape(frame, numel(frame), 1));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%xlswrite(fullfile(folderName,'spotNumber'),spotNumber);
