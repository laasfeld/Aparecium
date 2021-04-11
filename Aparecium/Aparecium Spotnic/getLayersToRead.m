function layersToRead = getLayersToRead(varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if length(varargin) < 1
    folderName = uigetdir; % the folder in which images exists
else
    folderName = varargin{1}; 
end

if length(varargin) < 2
    layersToUse = 1;
else
    layersToUse = varargin{2}; 
end

stackSizeThreshold = 0;

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
end

