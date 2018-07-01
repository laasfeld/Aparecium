function [ finalResults ] = reformPlate(ID, wellID, results, width, height)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%get rid of useless spaces
for index = 1:size(ID,1)
    for index2 = 1:size(ID,2)
        ID(index,index2) = regexprep(ID(index,index2),' ',''); 
    end
end
ID = reshape(ID,width,height);
for col = 1:size(ID,1)
    for row = 1:size(ID,2)
        [rowIndex, colIndex] = find(strcmp(wellID,ID(col,row)));
        finalResults(col, row, :) = results(rowIndex, colIndex, :);
    end
end
end

