function importNewFilters(fileName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
newFilterStruct = xml_load(fileName);
definedFilterStruct = [];
load 'NeoFilters.mat'
resultingFilterStruct = [definedFilterStruct newFilterStruct];

% find only unique filter cubes and add them to cube library
finalStructure = resultingFilterStruct(1);
for firstIndex = 2 : numel(resultingFilterStruct) 
    repetitionFound = 0;
    for secondIndex = 1 : numel(finalStructure)
        if isequal(resultingFilterStruct(firstIndex), finalStructure(secondIndex))
            repetitionFound = 1;
            break;
        end
    end
    if repetitionFound
        
    else
        finalStructure(end + 1) = resultingFilterStruct(firstIndex);
    end
end
definedFilterStruct = finalStructure; 
filename = mfilename('fullpath');
thisPath = fileparts(filename);
save([thisPath, '\NeoFilters.mat'], 'definedFilterStruct');

end

