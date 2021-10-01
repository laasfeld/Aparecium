function [ output_args ] = generateObjectWiseExcel(results, path)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

[name, xlspath] = uiputfile({'*.xlsx'},'Save object wise results to file');
homogeneityAnalysis = true;
finalTableArray = cell(numel(results{1}.imageData), 1);
tableRows = [];
for well = 1 : numel(results{1}.imageData)
    well
    finalTable = [];
    counter = 1;
    for imageIdx = 1 : numel(results{1}.imageData{well})
        im = results{1}.imageData{well}{imageIdx}.image;
        cc = bwconncomp(getBinaryImage(im));
        % read primary image
        im1 = imread(fullfile(path, results{1}.imageData{well}{imageIdx}.imageName));
        res = regionprops('table',cc, im1, 'Area', 'Eccentricity', 'MeanIntensity');
        res.Properties.VariableNames = {'Area', 'Eccentricity', 'DAPI_intensity'};
        im2 = imread([path, '/', results{1}.imageData{well}{imageIdx}.secondaryImageName]);
        res2 = regionprops('table',cc, im2, 'MeanIntensity');
        res2.Properties.VariableNames = {'RFP_intensity'};
        if homogeneityAnalysis
            labeledImage = bwlabel(im);
            objIndices = getObjIndices(labeledImage, cc);
            % perform the homogeneity analysis
            % calculate separate intensities for object borders and central
            % areas as well as calculate the homogeneity of intensities and
            % correlation between DAPI and RFP coloring intensities.
            ''
            se = strel('disk', 2);
            eroded = imerode(im, se);
            boundaries = im - eroded;
            ccEroded = bwconncomp(eroded);
            ccBoundaries = bwconncomp(boundaries);
            objIndicesEroded = getObjIndices(labeledImage, ccEroded);
            objIndicesBoundaries = getObjIndices(labeledImage, ccBoundaries);
            ccEroded = reconnectCC(ccEroded, objIndicesEroded);
            ccBoundaries = reconnectCC(ccBoundaries, objIndicesBoundaries);
            
            resEroded = regionprops('table',ccEroded, im1, 'Area', 'MeanIntensity');
            resEroded2 = regionprops('table',ccEroded, im2, 'MeanIntensity');
            
            resBoundaries = regionprops('table', ccBoundaries, im1, 'Area', 'MeanIntensity');
            resBoundaries2 = regionprops('table', ccBoundaries, im2, 'MeanIntensity');
            
            gaussFiltered = cell(4, 2);
            
            gaussFiltered{1, 1} = imgaussfilt(im1, 1);
            gaussFiltered{2, 1} = imgaussfilt(im1, 2);
            gaussFiltered{3, 1} = imgaussfilt(im1, 3);
            gaussFiltered{4, 1} = imgaussfilt(im1, 4);
            
            gaussFiltered{1, 2} = imgaussfilt(im2, 1);
            gaussFiltered{2, 2} = imgaussfilt(im2, 2);
            gaussFiltered{3, 2} = imgaussfilt(im2, 3);
            gaussFiltered{4, 2} = imgaussfilt(im2, 4);
            
            % Choose one after analysis
            gaussFilteredTable = cell(4, 2);
            
            gaussFilteredTable{1, 1} = regionprops('table',cc, gaussFiltered{1, 1}, 'MeanIntensity', 'PixelValues');
            gaussFilteredTable{2, 1} = regionprops('table',cc, gaussFiltered{2, 1}, 'MeanIntensity', 'PixelValues');
            gaussFilteredTable{3, 1} = regionprops('table',cc, gaussFiltered{3, 1}, 'MeanIntensity', 'PixelValues');
            gaussFilteredTable{4, 1} = regionprops('table',cc, gaussFiltered{4, 1}, 'MeanIntensity', 'PixelValues');
            gaussFilteredTable{1, 2} = regionprops('table',cc, gaussFiltered{1, 2}, 'MeanIntensity', 'PixelValues');
            gaussFilteredTable{2, 2} = regionprops('table',cc, gaussFiltered{2, 2}, 'MeanIntensity', 'PixelValues');
            gaussFilteredTable{3, 2} = regionprops('table',cc, gaussFiltered{3, 2}, 'MeanIntensity', 'PixelValues');
            gaussFilteredTable{4, 2} = regionprops('table',cc, gaussFiltered{4, 2}, 'MeanIntensity', 'PixelValues');
            
            for filtSizeIndex = 1 : 4
                for imageIndex = 1 : 2
                    for obj = 1 : size(gaussFilteredTable{filtSizeIndex, imageIndex}, 1)
                        gaussFilteredTable{filtSizeIndex, imageIndex}.PixelValues{obj, 1} = std(double(gaussFilteredTable{filtSizeIndex, imageIndex}.PixelValues{obj, 1}));
                    end
                    gaussFilteredTable{filtSizeIndex, imageIndex}.Properties.VariableNames([1]) = {'IntensitySTD'};
                end
            end
        end
        subtable = [res res2];
        subtable = subtable(subtable{:,1} > 200, :);
        if isequal(counter, 1)
            finalTable = subtable;            
        else         
            finalTable = [finalTable; subtable];
        end
        counter = counter + 1;
    end
    tableRows(well) = size(finalTable, 1);
    finalTableArray{well} = finalTable;
end

exportableCell = cell(max(tableRows(well))+2, numel(results{1}.imageData)*4);
for well = 1 : numel(results{1}.imageData)
    tableRowsWell = size(finalTableArray{well}, 1);
    exportableCell(3:tableRowsWell + 2, (well - 1)*4+1:well*4) = table2cell(finalTableArray{well});
    
    exportableCell(2, (well - 1)*4+1:well*4) = finalTableArray{well}.Properties.VariableNames;
    exportableCell{1, (well - 1)*4+1} = results{1}.ID{well};
    
end

xlswrite([xlspath, name], exportableCell);
end

function objIndices = getObjIndices(labeledImage, cc)
    objIndices = zeros(cc.NumObjects, 1);
    for objIndex = 1 : cc.NumObjects
        objIndices(objIndex) = labeledImage(cc.PixelIdxList{objIndex}(1));
    end
end

function reconnectedCC = reconnectCC(cc, objIndices)
    [C,IA,IC] = unique(objIndices);
    finalPixelIdxList = cell(numel(C), 1);
    for index = C'
        pxIdxList = cc.PixelIdxList(objIndices == index);
        finalPixelIdxList{index} = [];
        for innerIndex = 1 : numel(pxIdxList)
            finalPixelIdxList{index} = [finalPixelIdxList{index}; pxIdxList{innerIndex}];
        end
    end
    reconnectedCC = struct;
    reconnectedCC.Connectivity = cc.Connectivity;
    reconnectedCC.ImageSize = cc.ImageSize;
    reconnectedCC.NumObjects = numel(C);
    reconnectedCC.PixelIdxList = finalPixelIdxList';    
end

