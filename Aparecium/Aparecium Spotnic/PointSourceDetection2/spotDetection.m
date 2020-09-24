function [spotNumber, nonthresholdedBinary, spotLocations, layersToRead] = spotDetection(varargin)

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

if length(varargin) < 7
    sigma = 1.8;
else
    sigma = varargin{7}; 
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

nonthresholdedBinary = cell(size(tifFilesNames,1), 1);
spotLocations = cell(size(tifFilesNames,1), 1);
for i = 1 : size(tifFilesNames,1)
    try
        frame = zeros(height{i}, width{i}, numel(layersToRead{i}));
    catch
        
    end
    if numel(varargin) < 6 || isempty(varargin{6})
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
    
    %frame = double(imread(tifFilesNames{i}));
    %frame(frame<threshold)=0;
    [pstruct, mask] = pointSourceDetection(frame, sigma);
    nonthresholdedBinary{i} = mask;
    spotLocations{i} = pstruct;
    if calculateVoronoi        
        [points, vertices] = voronoiDiagram(delaunayTriangulation(pstruct.x', pstruct.y'));
        areas = zeros(numel(vertices), 1);
        width = size(mask, 2);
        height = size(mask, 1);
        counter = 1;
        for polygon = 1 : numel(vertices)
           if sum(points(vertices{polygon},1) > width) == 0 && sum(points(vertices{polygon},2) > height) == 0 && sum(points(vertices{polygon},1) < 0) == 0 && sum(points(vertices{polygon},2) < 0) == 0
               areas(counter) = polyarea(points(vertices{polygon}, 1), points(vertices{polygon}, 2));
               counter = counter + 1;
           else
               %hold on;
               %plot(pstruct.x(polygon), pstruct.y(polygon), '*r');
           end
        end
        areas(areas == 0) = [];
        tifFileNames{i, 5} = mean(areas);
        tifFileNames{i, 6} = std(areas);
    end    

    % filter the spots by average spot intensity
    if size(pstruct, 1) ~= 0
        cc = bwconncomp(mask);
        se = strel('disk',1);
        B = cell(1, numel(cc.PixelIdxList));
        for ccIndex = 1 : numel(cc.PixelIdxList)
           a = false(size(frame));
           a(cc.PixelIdxList{ccIndex}) = true;
           b = imdilate(a, se);
           c = bwboundaries(b);
           B{ccIndex} = c{1};
        end
        %figure
        %imshow(mask)
        %hold on
        objectsCentroids = cell(numel(B), 1);
        for objectIndex = 1 : numel(B)
            objectsCentroids{objectIndex} = [];
            %plot(B{objectIndex}(:,2),B{objectIndex}(:,1));
            for centroidIndex = 1 : numel(pstruct.x)
                [in, on] = inpolygon(pstruct.x(centroidIndex),pstruct.y(centroidIndex),B{objectIndex}(:,2), B{objectIndex}(:,1));
                if in || on
                    objectsCentroids{objectIndex} = [objectsCentroids{objectIndex}, centroidIndex];
                end
            end
        end
        % distrubute all pixels among objects which have multiple centroids
        cc2 = struct();
        cc2.Connectivity = 8;
        cc2.ImageSize = size(frame);
        cc2.PixelIdxList = cell(1,0);
        centroidAssociationVector = ones(0, 0);
        for objectIndex = 1 : numel(objectsCentroids)

           [y, x] = ind2sub(size(frame),cc.PixelIdxList{objectIndex});
           centroidsX = pstruct.x(objectsCentroids{objectIndex});
           centroidsY = pstruct.y(objectsCentroids{objectIndex});
           if numel(objectsCentroids{objectIndex}) > 1
               distanceMatrix = zeros(numel(x), numel(centroidsX), 2);
               for pixelIndex = 1 : numel(x)
                    distanceMatrix(pixelIndex, :, 1) = (x(pixelIndex) - centroidsX).^2;
                    distanceMatrix(pixelIndex, :, 2) = (y(pixelIndex) - centroidsY).^2;
               end
               distances = sum(distanceMatrix, 3);
               [value, index] = min(distances,[], 2);
           else
               index = ones(numel(x), 1);
           end

           for centroid = 1 : numel(centroidsX)
               cc2.PixelIdxList{1, end + 1} = sub2ind(size(frame), y(index == centroid), x(index == centroid));
               centroidAssociationVector = [centroidAssociationVector, objectsCentroids{objectIndex}(centroid)];
            end

        end
        cc2.NumObjects = numel(cc2.PixelIdxList);
        intensitiesStruct = regionprops(cc2, frame, 'MeanIntensity');
        intensities = cell2mat(struct2cell(intensitiesStruct));
        overThresholdIndices = intensities > threshold;
        fn = fieldnames(pstruct);
        for k=1:numel(fn)
            temp = pstruct.(fn{k});
            try
                pstruct.(fn{k}) = temp(centroidAssociationVector(overThresholdIndices));
            catch MException
                ''
            end
        end
    
    
        tifFilesNames{i,2}=size(pstruct.x,2);
        %centers=[pstruct.x', pstruct.y'];
        %radii=5*ones(size(centers,1),1);
        %figure; 
        %subplot(1,2,1); imagesc(frame); colormap(gray(256)); axis image; title('Input');
        %subplot(1,2,2); imagesc(mask); axis image; title('Detection');
        %viscircles(centers,radii);
        tifFilesNames{i,3} = mean(mean(frame, 2));
        homogeneity = graycoprops(graycomatrix(frame, 'NumLevels',256,'G',[0,64000]), 'Homogeneity');
        
        tifFilesNames{i, 4} = mean(frame(mask));
        tifFilesNames{i, 5} = sum(frame(mask));
        tifFilesNames{i, 6} = tifFilesNames{i, 5} / mean(frame(~mask));
        tifFilesNames{i, 7} = homogeneity.Homogeneity(1);
    else
        tifFilesNames{i,2}=0;
        tifFilesNames{i,3}=mean(mean(frame),2);
        %figure; 
        %subplot(1,2,1); imagesc(frame); colormap(gray(256)); axis image; title('Input');
        %subplot(1,2,2); imagesc(mask); axis image; title('Detection');
        homogeneity=graycoprops(graycomatrix(frame, 'NumLevels',256,'G',[0,64000]), 'Homogeneity');     
        tifFilesNames{i, 4} = mean(frame(mask));
        tifFilesNames{i, 5} = sum(frame(mask));
        tifFilesNames{i, 6} = tifFilesNames{i, 5} / mean(frame(~mask));
        tifFilesNames{i, 7} = homogeneity.Homogeneity(1);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spotNumber=tifFilesNames;
%xlswrite(fullfile(folderName,'spotNumber'),spotNumber);
