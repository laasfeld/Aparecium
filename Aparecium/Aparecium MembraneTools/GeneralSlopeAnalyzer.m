binaryImageNameFolder = 'C:\Users\Kasutaja\Desktop\Membrane Tools example dataset\BinaryBF_and_FL';
imagePath = 'C:\Users\Kasutaja\Desktop\Membrane Tools example dataset\BF_and_FL\';
manualMaskPath = 'C:\Users\Kasutaja\Desktop\Masinõpe HEK rakkude analüüsiks\Manual training images - 4 classes\';
directoryContents = dir(binaryImageNameFolder);
directoryContents(1:2) = [];
firstImageNames = cell(numel(directoryContents), 1);
for i = 1 : numel(directoryContents)
    firstImageNames{i} = directoryContents(i).name;
end

directoryOfLabels = dir(manualMaskPath);
directoryOfLabels(1:2) = [];
GTImageNames = cell(numel(directoryOfLabels), 1);
for i = 1 : numel(directoryOfLabels)
    GTImageNames{i} = directoryOfLabels(i).name;
end

% remove images without GT
stackOrderConnector = [];
for i = numel(firstImageNames): -1 : 1
    found = false;
    for j = 1 : numel(GTImageNames)
        if strcmp(GTImageNames{j}(1:4), firstImageNames{i}(1:4))
            found = true;
            stackOrderConnector(j) = (i);
            break;
        end
    end
    if ~found
        firstImageNames(i) = [];
    end
end

stackOrderConnector = [];
for i = numel(firstImageNames): -1 : 1
    found = false;
    for j = 1 : numel(GTImageNames)
        if strcmp(GTImageNames{j}(1:4), firstImageNames{i}(1:4))
            found = true;
            stackOrderConnector(j) = (i);
            break;
        end
    end
    if ~found
        firstImageNames(i) = [];
    end
end

stack = nan(904,1224,14,numel(firstImageNames));
for i = 1 : numel(firstImageNames)
    ZIndex = strfind(firstImageNames{i}, 'Z');
    ZIndex = ZIndex(end); % for avoiding situations where the image name contains several Z-s, for example in the well name
    focusIndex = str2num(firstImageNames{i}(ZIndex+1))+1;
    stack(:,:,focusIndex-2:focusIndex+9, i) = stackFromImages(imagePath, firstImageNames{i}, 'stdev',1:12);
end

membraneStack = cell(14, 1);
BGStack = cell(14, 1);
NMBG = cell(14, 1);
IC = cell(14, 1);
% create classes
for i = 1 : numel(GTImageNames)
    GTimage = imread([manualMaskPath, GTImageNames{i}]);
    % find membranes
    se = strel('disk', 1);
    membranes = imdilate(sum(GTimage(:,:,1:3), 3)==255*3, se);    
    nearMembrane = GTimage(:,:,3)==255 & GTimage(:,:,1)==0;  
    intracellular = GTimage(:,:,1)==255 & GTimage(:,:,3)==0;
    background = GTimage(:,:,1)~=255 & GTimage(:,:,2)~=255 & GTimage(:,:,3)~=255 & membranes~=1;
    for j = 1 : 14
        substack = stack(:, :, j, i);
        membraneStack{j} = [membraneStack{j}; substack(membranes == 1)];
        BGStack{j} = [BGStack{j}; substack(background == 1)]; 
        NMBG{j} = [NMBG{j}; substack(nearMembrane == 1)];
        IC{j} = [IC{j}; substack(intracellular == 1)];
    end 
end

membraneMat = cell2mat(membraneStack');
membraneVec = nanmean(membraneMat, 1);

BGMat = cell2mat(BGStack');
BGVec = nanmean(BGMat, 1);

NMBGMat = cell2mat(NMBG');
NMBGVec = nanmean(NMBGMat, 1);

ICMat = cell2mat(IC');
ICVec = nanmean(ICMat, 1);

figure
hold on
plot(membraneVec/2^16);
plot(BGVec/2^16);
plot(NMBGVec/2^16);
plot(ICVec/2^16);
