function [outliers, goodImageIndices] = findSpotnicOutliers(spotAnalysisResults, imageIndicesOfFolder, includedWellIndices)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
spotVector = [];
totalNormalizedIntensityVector = [];
pointerVector = [];
counter = 1;
for wellIndex = includedWellIndices'
    imageIndices = imageIndicesOfFolder{wellIndex};
    for imageIndex = 1 : numel(imageIndices)
        for subDir = 1 : numel(imageIndicesOfFolder)
            for imageIndexInFolder = 1 : numel(imageIndicesOfFolder{subDir})
                if isequal(imageIndices(imageIndex), imageIndicesOfFolder{subDir}(imageIndexInFolder))
                    spotVector = [spotVector, spotAnalysisResults{subDir}(imageIndexInFolder, 1)];
                    totalNormalizedIntensityVector = [totalNormalizedIntensityVector, spotAnalysisResults{subDir}(imageIndexInFolder, 5)];
                    pointerVector = [pointerVector, counter];
                    counter = counter + 1;
                end
            end
        end
    end
end

goodImageIndices = find2DOutliers(spotVector', totalNormalizedIntensityVector', pointerVector);
outliers = setdiff(pointerVector, goodImageIndices);

end

