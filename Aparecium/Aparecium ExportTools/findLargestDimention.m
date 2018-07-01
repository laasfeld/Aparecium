function largestDimention = findLargestDimention(multiDimCellArray, uniquenessTable)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
multiDimMatrix = cellfun(@str2num, multiDimCellArray);
uniqueValues = zeros(size(multiDimMatrix, numel(size(multiDimMatrix))),1);
for index = 1 : numel(uniqueValues)
    uniqueValues(index) = numel(unique(multiDimMatrix(:, index)));
end
[numberOfUniqueValues, largestDimention] = max(uniqueValues);
if isequal(numberOfUniqueValues, 1)
    [unneeded, largestDimention] = min(uniquenessTable);
    if isequal(unique(multiDimMatrix(:,largestDimention)), 0)
       for treatment = 1 : size(multiDimMatrix, 2)
            if ~isequal(unique(multiDimMatrix(:,treatment)), 0)
                largestDimention = treatment;
                break;
            end
       end
    end
end
end

