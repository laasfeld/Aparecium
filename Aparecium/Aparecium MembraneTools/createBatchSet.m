function [ output_args ] = createBatchSet(groundTruthImageFolder, originalImageFolder, numBatchPerImage, outputFolder, batchSize)
%Creates a batch set from 1 channel images for machine learning trainings
%   groundTruthImageNames is a cell array of complete or relative paths to
%   the ground truth images.
%   originalImageFolder is aa folder which contains the original images
%   which must have the same name as the corresponding ground truth images
%   numPatchPerImage is a number that defines how many patches are produced
%   from each image. It can have a value 'max' which means that as many as
%   possible are generated keeping the balance between true positives and
%   true negatives
%   outputFolder is just a folder where the batch images are saved as .png
%   files.
%   batchSize is an odd number that represents the side length of the
%   image. If number is not an odd integer it is rounded up to nearest odd
%   integer.

% Process images one-by-one

contents = dir(groundTruthImageFolder);
contents(1:2) = [];
groundTruthImageNames = cell(numel(contents), 1);
for i = 1 : numel(contents)
    groundTruthImageNames{i} = [groundTruthImageFolder, '\', contents(i).name];
end

for imageIndex = 1 : numel(groundTruthImageNames)
   disp(['Creating batches from', groundTruthImageNames{imageIndex}]);
   groundTruthImageOrig = imread(groundTruthImageNames{imageIndex});
   groundTruthImage = groundTruthImageOrig(:,:,1);
   [height, width] = size(groundTruthImage);
   [folder, name, extention] = fileparts(groundTruthImageNames{imageIndex});
   originalImage = imread([originalImageFolder, '\', name, extention]);
   groundTruthBinary = handmadeToBinary(groundTruthImageOrig);
   [cellularBinary, outsideCellHaloBinary] = handmadeToUnbiasedBackground(groundTruthImageOrig);
   originalImage = [fliplr(originalImage(:, 1 : (batchSize-1)/2)), originalImage, fliplr(originalImage(:, 1 + width - (batchSize-1)/2 : width))]; % enlarge image enough for mirroring in left right direction
   originalImage = [flipud(originalImage(1 : (batchSize-1)/2, :)); originalImage; flipud(originalImage(1 + height - (batchSize-1)/2 : height, :))];
   groundTruthDouble = double(groundTruthBinary);
   groundTruthDouble = [ones(height, (batchSize-1)/2)*-1, groundTruthDouble, ones(height, (batchSize-1)/2)*-1];
   groundTruthDouble = [ones((batchSize-1)/2, width + (batchSize-1))*-1; groundTruthDouble; ones((batchSize-1)/2, width + (batchSize-1))*-1];
   
   cellularDouble = double(cellularBinary);
   cellularDouble = [zeros(height, (batchSize-1)/2), cellularDouble, zeros(height, (batchSize-1)/2)*-1];
   cellularDouble = [zeros((batchSize-1)/2, width + (batchSize-1))*-1; cellularDouble; zeros((batchSize-1)/2, width + (batchSize-1))*-1];
   cellularBinary = logical(cellularDouble);
   
   haloDouble = double(outsideCellHaloBinary);
   haloDouble = [zeros(height, (batchSize-1)/2), haloDouble, zeros(height, (batchSize-1)/2)];
   haloDouble = [zeros((batchSize-1)/2, width + (batchSize-1))*-1; haloDouble; zeros((batchSize-1)/2, width + (batchSize-1))];
   outsideCellHaloBinary = logical(haloDouble);
   
   numberOfWhitePixels = sum(sum(groundTruthBinary));
   [whiteIndexRow, whiteIndexCol] = find(groundTruthDouble == 1);
   batchTruePositiveImages = cell(numBatchPerImage, 1);
   batchTrueNegativeImages = cell(numBatchPerImage, 1);
   for batchIndex = 1 : numberOfWhitePixels
       % check if we are out of range and need to mirror. Cases where image
       % dimension is smaller than the batch size are not considered and
       try
        batchTruePositiveImages{batchIndex} = originalImage(whiteIndexRow(batchIndex) - (batchSize-1)/2 : whiteIndexRow(batchIndex) + (batchSize-1)/2,  whiteIndexCol(batchIndex) - (batchSize-1)/2 : whiteIndexCol(batchIndex) + (batchSize-1)/2); 
       catch MException
          'siin' 
       end
   end
   %[blackIndexRow, blackIndexCol] = find(logical(groundTruthDouble) == 0);
   [blackIndexRow, blackIndexCol] = find( ((~logical(groundTruthDouble)) & (~cellularBinary) & (~outsideCellHaloBinary) == 1)); % regular background
   [blackIndexRowCellular, blackIndexColCellular] = find(cellularBinary == 1);
   [blackIndexRowHalo, blackIndexColHalo] = find(outsideCellHaloBinary == 1);
   randomsBG = randperm(numel(blackIndexRow));
   randomsBG = randomsBG(1 : 3 : numberOfWhitePixels);
   randomsCell = randperm(numel(blackIndexRowCellular));
   randomsCell = randomsCell(1 : 3 : numberOfWhitePixels);
   randomsHalo = randperm(numel(blackIndexRowHalo));
   randomsHalo = randomsHalo(1 : 3 : numberOfWhitePixels);
   blackIndexRow = [blackIndexRowCellular(randomsCell); blackIndexRowHalo(randomsHalo); blackIndexRow(randomsBG)];
   blackIndexCol = [blackIndexColCellular(randomsCell); blackIndexColHalo(randomsHalo); blackIndexCol(randomsBG)];
   for batchIndex = 1 : numberOfWhitePixels
       batchTrueNegativeImages{batchIndex} = originalImage(blackIndexRow(batchIndex) - (batchSize-1)/2 : blackIndexRow(batchIndex) + (batchSize-1)/2, blackIndexCol(batchIndex) - (batchSize-1)/2 : blackIndexCol(batchIndex) + (batchSize-1)/2);
   end
   
   [folder, name] = fileparts(groundTruthImageNames{imageIndex});
   mkdir([outputFolder, '\',name]);
   mkdir([outputFolder, '\',name, '\classWhite']);
   mkdir([outputFolder, '\',name, '\classBlack']);
   for batchIndex = 1 : numberOfWhitePixels
      imwrite(batchTruePositiveImages{batchIndex}, [outputFolder, '\',name, '\classWhite\', num2str(batchIndex),'.png'], 'png');
      imwrite(batchTrueNegativeImages{batchIndex}, [outputFolder, '\',name, '\classBlack\', num2str(batchIndex),'.png'], 'png');
   end
end


end

