function [ MIDASTableController1, MIDASTableController2 ] = guaranteeAllWellsPresent(MIDASTableController1, MIDASTableController2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
wellIDOfFirstTable = MIDASTableController1.getWellID();
wellIDOfSecondTable = MIDASTableController2.getWellID();
allSortedWellIDs = union(wellIDOfFirstTable, wellIDOfSecondTable);
addMissingRows(MIDASTableController1, wellIDOfFirstTable, allSortedWellIDs);
addMissingRows(MIDASTableController2, wellIDOfSecondTable, allSortedWellIDs);
end

function MIDASTableController1 = addMissingRows(MIDASTableController1, wellIDOfFirstTable, allSortedWellIDs)
    eventDataOfFirstTable = MIDASTableController1.eventData;
    blockSize = numel(wellIDOfFirstTable);
    noOfBlocksInFirstTable = size(eventDataOfFirstTable, 1)/blockSize;
    newBlock = cell(noOfBlocksInFirstTable, 1);
    noOfCols = size(eventDataOfFirstTable, 2);
    for blockIndex = 1 : noOfBlocksInFirstTable
        originalBlock = eventDataOfFirstTable( (blockIndex - 1) * blockSize + 1 : blockIndex * blockSize, :);
        newBlock{blockIndex} = cell(blockSize, noOfCols);
        originalWellIDs = originalBlock(:, 2);
        %check fast kinetics

        for col = 1 : numel(MIDASTableController1.columnHeaders)
            if isequal(strfind(MIDASTableController1.columnHeaders{col},'DA:All'), 1)||isequal(strfind(MIDASTableController1.columnHeaders{col}, 'DA:ALL'), 1)
                timeCol = col;
                if isequal(numel(unique(cell2mat(originalBlock(:,col)))), 1)
                    timeValue = originalBlock(1,col);
                else
                    timeValue = NaN; 
                end
            end
        end

        for wellIndex = 1 : numel(allSortedWellIDs)
            wellID = allSortedWellIDs{wellIndex};
            originalIndex = find(ismember(originalWellIDs, wellID));
            if isempty(originalIndex)
               newBlock{blockIndex}(wellIndex, 1) = originalBlock(1, 1);
               newBlock{blockIndex}{wellIndex, 2} = wellID;
               newBlock{blockIndex}(wellIndex, 3 : end) = deal({NaN});
               try
                    newBlock{blockIndex}(wellIndex, timeCol) = timeValue;
               catch MException
                   if strcmp(MException.identifier, 'MATLAB:invalidConversion')
                       newBlock{blockIndex}(wellIndex, timeCol) = {timeValue};
                   else
                      error(MException); 
                   end
               end
            else
               newBlock{blockIndex}(wellIndex, :) = originalBlock(originalIndex, :);  
            end
        end
    end
    newEventData = cat(1, newBlock{:});
    MIDASTableController1.eventData = newEventData;
end
