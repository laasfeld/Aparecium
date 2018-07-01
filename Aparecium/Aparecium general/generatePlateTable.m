function [plateTable] = generatePlateTable(height, width)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
alphabet = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
plateTable = cell(height+1, width+1)
for row = 1 : height
   plateTable{row + 1, 1} = alphabet(row); 
end

for column = 1 : width
   plateTable{1, column + 1} = num2str(column); 
end



end

