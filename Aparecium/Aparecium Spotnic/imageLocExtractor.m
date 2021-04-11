function [imageLocationIndices, timeIndexVector] = imageLocExctractor(image, imageInfo) 

bioformatsImage = bfopen(image);

OME_XML = bioformatsImage{1, 4};

imageCount = OME_XML.getPlaneCount(0);

PositionX = zeros(imageCount, 1);
PositionY = zeros(imageCount, 1);
DeltaT = zeros(imageCount, 1);

for imageIndex = 0 : imageCount - 1 % java indexing
    PositionX(imageIndex + 1) = double(OME_XML.getPlanePositionX(0, imageIndex).value);
    PositionY(imageIndex + 1) = double(OME_XML.getPlanePositionY(0, imageIndex).value);
    DeltaT(imageIndex + 1) = double(OME_XML.getPlaneDeltaT(0, imageIndex).value);
end
 
locations = [PositionX, PositionY];
uniqueLocations = unique(locations,'rows');
imageLocationIndices = zeros(imageCount, 1);
for imageIndex = 1 : imageCount
    for uniqueLoc = 1 : size(uniqueLocations, 1)
        if isequal(locations(imageIndex, :), uniqueLocations(uniqueLoc, :))
            imageLocationIndices(imageIndex) = uniqueLoc;
            break;
        end
    end
end
 
timeIndexVector = zeros(imageCount, 1);
 
for uniqueLoc = 1 : size(uniqueLocations, 1)
    locationIndices = find(imageLocationIndices == uniqueLoc);
    locationDeltaT = DeltaT(locationIndices);
    [~, sortedIndeces] = sort(locationDeltaT);
    timeIndexVector(locationIndices) = sortedIndeces;
end

end
