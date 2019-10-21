function [ blankedValues ] = linearTimeModelBlankCorrection(valuesToBeBlanked, measurementTimes, blankValues, blankMeasurementTimes)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
reshapedBlankValues = reshape(blankValues, 1, numel(blankValues));
reshapedBlanktimes = reshape(blankMeasurementTimes, 1, numel(blankValues));
[notNeeded,m,b] = regression(reshapedBlanktimes, reshapedBlankValues);
% p = k*m+b
blankedValues = zeros(size(valuesToBeBlanked));
for blankIndex = 1 : numel(valuesToBeBlanked)
   blankedValues(blankIndex) = valuesToBeBlanked(blankIndex) - measurementTimes(blankIndex)*m - b; 
end
end