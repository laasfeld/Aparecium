function [ result ] = ICSE_cell_size_optimal(pixelIdxList, eccentricity)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
thresholdScore = size(pixelIdxList,1) - 500 * eccentricity;
if (thresholdScore > -350 && size(pixelIdxList,1) < 300)
    result = 1;
else
   result = 0; 
end

