function [ index ] = findStringFromCellArray(cellArray, string)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
for stringIndex = 1 : numel(cellArray)
   if strcmp(cellArray{stringIndex}, string)
      index = stringIndex;
      break; 
   end
end

end

