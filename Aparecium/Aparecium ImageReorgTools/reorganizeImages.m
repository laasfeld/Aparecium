function success = reorganizeImages(inputFolder, outputFolder, reorganizationLogic, nameSource, copyOrCut)
%Reorganizes images into folders based on image name (the well and time it
%was taken at) in user defined fashion
%   Detailed explanation goes here
if isequal(copyOrCut, 1) % cut
    moveFunction = @movefile;
elseif isequal(copyOrCut, 2) % copy
    moveFunction = @copyfile;
end

directory = dir(inputFolder);
directory(1:2) = [];
fileNames = cell(numel(directory), 1);
counter = 1;
for i = 1 : numel(directory)
    if ~isempty(strfind(directory(i).name, '.tif'))
        fileNames{counter} = directory(i).name;
        counter = counter + 1;
    end 
end
fileNames = fileNames(~cellfun(@isempty, fileNames));

for i = 1 : numel(fileNames)
   [readName, cycleName] = getReadAndCycle(nameSource, fileNames{i}, inputFolder); 
   if isequal(reorganizationLogic, 1) % by timepoint
       mkdir(outputFolder, cycleName);
       moveFunction([inputFolder, '\', fileNames{i}], [outputFolder, '\', cycleName, '\', fileNames{i}]); 
   elseif isequal(reorganizationLogic, 2) % by read
       mkdir(outputFolder, readName);
       moveFunction([inputFolder, '\', fileNames{i}], [outputFolder, '\', readName, '\', fileNames{i}]); 
   elseif isequal(reorganizationLogic, 3) % by read and subfolders by timepoint
       mkdir(outputFolder, readName);
       mkdir([outputFolder, '\', readName], cycleName);
       moveFunction([inputFolder, '\', fileNames{i}], [outputFolder, '\' ,readName, '\', cycleName, '\', fileNames{i}]); 
   end
end

success = 1;

end

function [readName, cycleName] = getReadAndCycle(nameSource, fileName, filePath)
    if isequal(nameSource, 1) % use image names, faster
        numbers = regexp(fileName,'(\d{1,10})', 'match');
        % the second one is always the read name and the last one is always
        % the cycle index
        readName = numbers{2};
        cycleName = numbers{end};
    elseif isequal(nameSource, 2) % use OME-TIFF metadata, useful when file names are corrupted note that the naming will be slightly different for read names
        image = Cytation5TIFFImage([filePath,'\',fileName]);
        readName = image.getReadStepSequance();
        if readName < 10
            readName = ['0', num2str(readName)];
        else
            readName = num2str(readName);
        end
        cycleName = image.getKineticSequence();
        if cycleName < 10
            cycleName = ['00', num2str(cycleName)];
        elseif cycleName < 100
            cycleName = ['0', num2str(cycleName)];
        else
            cycleName = num2str(cycleName);
        end
    end
end