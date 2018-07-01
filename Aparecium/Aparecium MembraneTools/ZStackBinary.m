function [dilatedEdges, edgeValues] = ZStackBinary(structure)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if isfield(structure, 'slopes')
    slopes = structure.slopes;
else
    path = structure.path;
    firstImageName = structure.firstImageName;
    ZIndex = strfind(firstImageName, 'Z');
    ZIndex = ZIndex(end); % for avoiding situations where the image name contains several Z-s, for example in the well name
    focusIndex = str2num(firstImageName(ZIndex+1))+1;
    slopes = stackLinearRegPartial(path, firstImageName, 'stdev',[focusIndex - 2:focusIndex+5]);
    %slopes = stackLinearReg(path, firstImageName, 'stdev');
end
if strcmp(class(slopes), 'uint8')
   slopes = double(slopes)/256; 
end
%slopes = imgaussfilt(slopes);% experimental extra step
normalizedSlopes = (slopes-min(min(slopes)))/max(max(slopes-min(min(slopes))));
[edges, thresh, bx, by] = edge(slopes, structure.method);

edges = edge(slopes, structure.method, thresh+structure.edgeThreshold);
edges(normalizedSlopes>structure.upper) = 0;
edges(normalizedSlopes<structure.lower) = 0;
se = strel('disk',1);
binaryEdges = logical(edges);

cc = bwconncomp(binaryEdges, 8);
for i = 1:size(cc.PixelIdxList,2)
    if numel(cc.PixelIdxList{i}) < structure.smallSizeCutoff
        binaryEdges(cc.PixelIdxList{i}) = 0;
    end
end

dilatedEdges = imdilate(binaryEdges, se);
cc = bwconncomp(dilatedEdges, 4);
for i = 1:size(cc.PixelIdxList,2)
    if numel(cc.PixelIdxList{i}) < structure.threshold
        dilatedEdges(cc.PixelIdxList{i}) = 0;
    end
end
%if nargout > 1
    edgeValues = 1*bx.*bx + 1*by.*by;
    edgeValues = edgeValues/max(max(edgeValues));
    LeviRandveeBin = dilatedEdges;
    for row = 2 : size(LeviRandveeBin, 1) - 1
        for col = 2 : size(LeviRandveeBin, 2) - 1

            if(sum(sum(LeviRandveeBin(row-1:row+1,col-1:col+1))) > 0 && edgeValues(row, col) > 0.3 && LeviRandveeBin(row, col) ~= 1)
                LeviRandveeBin(row, col) = 1;

            if col > 2 
                col = col - 1;
            end
            if row > 2
                row = row - 1;
            end

            end
        end
    end
    edgeValues = LeviRandveeBin;
    edgesValues(normalizedSlopes>structure.upper) = 0;
    edgesValues(normalizedSlopes<structure.lower) = 0;
%     edgeValues = 1*bx.*bx + 1*by.*by;
%     edgeValues(normalizedSlopes>structure.upper) = 0;
%     edgeValues(normalizedSlopes<structure.lower) = 0;
%     
%     cutoffLower = thresh^2;
%     cutoffUpper = (thresh+structure.edgeThreshold)^2;
%     edgeValues = (edgeValues - cutoffLower)/(cutoffUpper - cutoffLower);
%     edgeValues = edgeValues - 0.8;
%     edgeValues(0 > edgeValues) = 0; 
%     edgeValues(edgeValues > 1) = 1;
% 
%     edgeValues = exp(1).^edgeValues - 1;
%     se = strel('disk', 1);
%     edgeValues = imdilate(edgeValues, se);
%     edgeValues = edgeValues/max(max(edgeValues));
    
%end
dilatedEdges = LeviRandveeBin;

end

