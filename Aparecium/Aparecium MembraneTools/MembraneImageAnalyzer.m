classdef MembraneImageAnalyzer < ImageAnalyzer
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        miniBatchSize = 16
    end
    
    methods
        function this = MembraneImageAnalyzer()
           this.ICSEOrMembrane = 'Membrane';
        end 
    end
    
    methods (Static)
    
        function measurementParams = performKerasAnalysis(measurementParams)
            
            fromBinary = strcmp(measurementParams(1).imageProcessingParams.imageSegmentationMode, measurementParams(1).imageProcessingParams.FromBinary);
            packedBinaryImages = cell(numel(measurementParams), 1);
            imageSizes = cell(numel(measurementParams), 1);
            if fromBinary
                for imageIndex = 1 : numel(measurementParams)
                    %%% NB! generalize this (Binary_unmasked is not regular binary folder name)!!!
                    bw = getBinaryOfImage(fullfile(measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).wellName), 'Binary');
                    
                    measurementParams(imageIndex).results = MembraneImageAnalyzer.analyzeMembranesStatic(...
            measurementParams(imageIndex).wellName, measurementParams(imageIndex).secondaryPicOfWell, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).imageProcessingParams,...
            measurementParams(imageIndex).timeParameters, measurementParams(imageIndex).thresholdFunctionHandle, measurementParams(imageIndex).calculationMethod, measurementParams(imageIndex).qualityMask, ...
            measurementParams(imageIndex).parametersToCalculate, bw, measurementParams(imageIndex).mainDirectory, measurementParams(imageIndex).usedDirectory);
                end
            else
                
                sectionSize = 10;
                nrOfSections = ceil(numel(measurementParams)/sectionSize);
                
                for startIndex = 1 : sectionSize : nrOfSections * sectionSize
                    imagesForBinaryGeneration = [];
                    endIndex = startIndex + sectionSize - 1;
                    if endIndex > numel(measurementParams)
                        endIndex = numel(measurementParams);
                    end

                    counter = 1;

                    for imageIndex = startIndex : endIndex % parfor should be here
                        disp(['Image index = ', num2str(imageIndex)]);
                        if strcmp(measurementParams(1).imageProcessingParams.detectionFocusOrSlopes, 'Slopes')
                            imagesForBinaryGeneration{counter} = MembraneImageAnalyzer.createSlopeImage(measurementParams(imageIndex));
                        elseif strcmp(measurementParams(1).imageProcessingParams.detectionFocusOrSlopes, 'Focus')
                            imagesForBinaryGeneration{counter} = MembraneImageAnalyzer.createFocusImageNoNorm(measurementParams(imageIndex));
                        end
                        counter = counter + 1;
                    end

                    % introduce the pixel shifts to images
                    counter = 1;
                    for imageIndex = startIndex : endIndex
                        pixelShiftVertical = measurementParams(imageIndex).imageProcessingParams.getPixelShiftVertical();
                        pixelShiftHorizontal = measurementParams(imageIndex).imageProcessingParams.getPixelShiftHorizontal();
                        imagesForBinaryGeneration{counter} = imagesForBinaryGeneration{counter}(pixelShiftVertical+1:end, pixelShiftHorizontal+1:end);
                        imageSizes{imageIndex} = size(imagesForBinaryGeneration{counter});
                        counter = counter + 1;
                    end
                    try
                        if strcmp(measurementParams(1).imageProcessingParams.autoSaveProbabilityMap, 'off')
                            binaryImages = MembraneImageAnalyzer.createBinaryImagesWithKeras(imagesForBinaryGeneration, measurementParams(startIndex : endIndex));
                        elseif strcmp(measurementParams(1).imageProcessingParams.autoSaveProbabilityMap, 'on')
                            [binaryImages, probabilityMaps] = MembraneImageAnalyzer.createBinaryImagesWithKeras(imagesForBinaryGeneration, measurementParams(startIndex : endIndex));                            
                        end
                    catch MException
                        rethrow(MException)
                    end
                    
                    counter = 1;
                    for imageIndex = endIndex : -1 : startIndex
                        if strcmp(measurementParams(1).imageProcessingParams.autoSaveProbabilityMap, 'on')
                            measurementParams(imageIndex).results = MembraneImageAnalyzer.analyzeMembranesStatic(...
                            measurementParams(imageIndex).wellName, measurementParams(imageIndex).secondaryPicOfWell, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).imageProcessingParams,...
                            measurementParams(imageIndex).timeParameters, measurementParams(imageIndex).thresholdFunctionHandle, measurementParams(imageIndex).calculationMethod, measurementParams(imageIndex).qualityMask, ...
                            measurementParams(imageIndex).parametersToCalculate, binaryImages{numel(imagesForBinaryGeneration) - counter + 1}, measurementParams(imageIndex).mainDirectory, measurementParams(imageIndex).usedDirectory, probabilityMaps{numel(imagesForBinaryGeneration) - counter + 1});
                        elseif strcmp(measurementParams(1).imageProcessingParams.autoSaveProbabilityMap, 'off')
                            measurementParams(imageIndex).results = MembraneImageAnalyzer.analyzeMembranesStatic(...
                            measurementParams(imageIndex).wellName, measurementParams(imageIndex).secondaryPicOfWell, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).imageProcessingParams,...
                            measurementParams(imageIndex).timeParameters, measurementParams(imageIndex).thresholdFunctionHandle, measurementParams(imageIndex).calculationMethod, measurementParams(imageIndex).qualityMask, ...
                            measurementParams(imageIndex).parametersToCalculate, binaryImages{numel(imagesForBinaryGeneration) - counter + 1}, measurementParams(imageIndex).mainDirectory, measurementParams(imageIndex).usedDirectory);
                        end
                        
                        binaryImages(numel(imagesForBinaryGeneration) - counter + 1) = [];
                        
                        if strcmp(measurementParams(1).imageProcessingParams.autoSaveProbabilityMap, 'on')
                            probabilityMaps(numel(imagesForBinaryGeneration) - counter + 1) = [];
                        end
                        counter = counter + 1;
                    end
%                 for i = 1 : numel(measurementParams) % parfor should be here
%                     if strcmp(measurementParams(1).imageProcessingParams.detectionFocusOrSlopes, 'Slopes')
%                         imagesForBinaryGeneration{i} = MembraneImageAnalyzer.createSlopeImage(measurementParams(i));
%                     elseif strcmp(measurementParams(1).imageProcessingParams.detectionFocusOrSlopes, 'Focus')
%                         imagesForBinaryGeneration{i} = MembraneImageAnalyzer.createFocusImageNoNorm(measurementParams(i));
%                     end
%                 end
% 
%                 % intoduce the pixel shifts to images
%                 for i = 1 : numel(measurementParams)
%                     pixelShiftVertical = measurementParams(i).imageProcessingParams.getPixelShiftVertical();
%                     pixelShiftHorizontal = measurementParams(i).imageProcessingParams.getPixelShiftHorizontal();
%                     imagesForBinaryGeneration{i} = imagesForBinaryGeneration{i}(pixelShiftVertical+1:end, pixelShiftHorizontal+1:end);
%                 end
%                 
%                 if strcmp(measurementParams(1).imageProcessingParams.autoSaveProbabilityMap, 'off')
%                     [binaryImages, probabilityMaps] = MembraneImageAnalyzer.createBinaryImagesWithKeras(imagesForBinaryGeneration, measurementParams);
%                     for imageIndex = 1 : numel(measurementParams)
%                         measurementParams(imageIndex).results = MembraneImageAnalyzer.analyzeMembranesStatic(...
%                     measurementParams(imageIndex).wellName, measurementParams(imageIndex).secondaryPicOfWell, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).imageProcessingParams,...
%                     measurementParams(imageIndex).timeParameters, measurementParams(imageIndex).thresholdFunctionHandle, measurementParams(imageIndex).calculationMethod, measurementParams(imageIndex).qualityMask, ...
%                     measurementParams(imageIndex).parametersToCalculate, binaryImages{imageIndex}, measurementParams(imageIndex).mainDirectory, measurementParams(imageIndex).usedDirectory);
%                     end
%                 elseif strcmp(measurementParams(1).imageProcessingParams.autoSaveProbabilityMap, 'on')


                end
            end
        end
            
            
        function measurementParams = performIlastikAnalysis(measurementParams)
            
            fileChooser = FileChooser();
            ilastikPath = fileChooser.getIlastikExecutablePath();
            % divide into sections of 100 images for memory reasons
            sectionSize = 100;
            nrOfSections = ceil(numel(measurementParams)/sectionSize);
            
            fromBinary = strcmp(measurementParams(1).imageProcessingParams.imageSegmentationMode, measurementParams(1).imageProcessingParams.FromBinary);
            packedBinaryImages = cell(numel(measurementParams), 1);
            imageSizes = cell(numel(measurementParams), 1);
            if fromBinary
                for imageIndex = 1 : numel(measurementParams)
                    %%% NB! generalize this (Binary_unmasked is not regular binary folder name)!!!
                    bw = getBinaryOfImage(fullfile(measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).wellName), 'Binary');
                    
                    measurementParams(imageIndex).results = MembraneImageAnalyzer.analyzeMembranesStatic(...
            measurementParams(imageIndex).wellName, measurementParams(imageIndex).secondaryPicOfWell, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).imageProcessingParams,...
            measurementParams(imageIndex).timeParameters, measurementParams(imageIndex).thresholdFunctionHandle, measurementParams(imageIndex).calculationMethod, measurementParams(imageIndex).qualityMask, ...
            measurementParams(imageIndex).parametersToCalculate, bw, measurementParams(imageIndex).mainDirectory, measurementParams(imageIndex).usedDirectory);
                end
            else           
                for startIndex = 1 : sectionSize : nrOfSections * sectionSize
                    imagesForBinaryGeneration = [];
                    endIndex = startIndex + sectionSize - 1;
                    if endIndex > numel(measurementParams)
                        endIndex = numel(measurementParams);
                    end

                    counter = 1;

                    for i = startIndex : endIndex % parfor should be here
                        disp(['i=', num2str(i)]);
                        if strcmp(measurementParams(1).imageProcessingParams.detectionFocusOrSlopes, 'Slopes')
                            imagesForBinaryGeneration{counter} = MembraneImageAnalyzer.createSlopeImage(measurementParams(i));
                        elseif strcmp(measurementParams(1).imageProcessingParams.detectionFocusOrSlopes, 'Focus')
                            imagesForBinaryGeneration{counter} = MembraneImageAnalyzer.createFocusImage(measurementParams(i));
                        end
                        counter = counter + 1;
                    end

                    % intoduce the pixel shifts to images
                    counter = 1;
                    for i = startIndex : endIndex
                        pixelShiftVertical = measurementParams(i).imageProcessingParams.getPixelShiftVertical();
                        pixelShiftHorizontal = measurementParams(i).imageProcessingParams.getPixelShiftHorizontal();
                        imagesForBinaryGeneration{counter} = imagesForBinaryGeneration{counter}(pixelShiftVertical+1:end, pixelShiftHorizontal+1:end);
                        imageSizes{i} = size(imagesForBinaryGeneration{counter});
                        counter = counter + 1;
                    end
                    try
                        packedBinaryImagesLocal = MembraneImageAnalyzer.createBinaryImages(imagesForBinaryGeneration, measurementParams(startIndex : endIndex), ilastikPath);
                    catch MException
                        rethrow(MException)
                    end
                    
                    counter = 1;
                    for imageIndex = endIndex :-1: startIndex
                        measurementParams(imageIndex).results = MembraneImageAnalyzer.analyzeMembranesStatic(...
            measurementParams(imageIndex).wellName, measurementParams(imageIndex).secondaryPicOfWell, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).imageProcessingParams,...
            measurementParams(imageIndex).timeParameters, measurementParams(imageIndex).thresholdFunctionHandle, measurementParams(imageIndex).calculationMethod, measurementParams(imageIndex).qualityMask, ...
            measurementParams(imageIndex).parametersToCalculate, bwunpack(packedBinaryImagesLocal{numel(imagesForBinaryGeneration) - counter + 1}, imageSizes{imageIndex}(1)), measurementParams(imageIndex).mainDirectory, measurementParams(imageIndex).usedDirectory);
            packedBinaryImagesLocal(numel(imagesForBinaryGeneration) - counter + 1) = [];
                        counter = counter + 1;
                    end
                    
                end
            end
            %for imageIndex =  numel(measurementParams) : -1 : 1
            %    measurementParams(imageIndex).results = MembraneImageAnalyzer.analyzeMembranesStatic(...
            %measurementParams(imageIndex).wellName, measurementParams(imageIndex).secondaryPicOfWell, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).imageProcessingParams,...
            %measurementParams(imageIndex).timeParameters, measurementParams(imageIndex).thresholdFunctionHandle, measurementParams(imageIndex).calculationMethod, measurementParams(imageIndex).qualityMask, ...
            %measurementParams(imageIndex).parametersToCalculate, bwunpack(packedBinaryImages{imageIndex}, imageSizes{imageIndex}(1)), measurementParams(imageIndex).mainDirectory, measurementParams(imageIndex).usedDirectory);
            %packedBinaryImages(imageIndex) = [];
            %end
            %(...
            %measurementParams(imageIndex).wellName, measurementParams(imageIndex).secondaryPicOfWell, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).imageProcessingParams,...
            %measurementParams(imageIndex).timeParameters, measurementParams(imageIndex).thresholdFunctionHandle, measurementParams(imageIndex).calculationMethod, measurementParams(imageIndex).qualityMask, ...
            %measurementParams(imageIndex).parametersToCalculate)
            %!ilastik.exe --headless --project=C:\Users\Kasutaja\IlastikMembraneDetector.ilp D:\Original_slope_and_stdev_images\*.tif
        end

        function [binaryImages, probabilityMaps] = createBinaryImagesWithKeras(slopeImages, measurementParams, KerasModelPath)
            
            binaryImages = cell(size(slopeImages));
            if strcmp(measurementParams(1).imageProcessingParams.autoSaveProbabilityMap, 'on')
                probabilityMaps = cell(size(slopeImages));
            end
      
            kerasModelPath = measurementParams(1).imageProcessingParams.kerasModelPath;
            net = importKerasNetwork(kerasModelPath);
            for imageIndex = 1 : numel(slopeImages)
                if strcmp(measurementParams(1).imageProcessingParams.autoSaveProbabilityMap, 'off')
                    binaryImages{imageIndex} = MembraneImageAnalyzer.predictSingleImage(net, slopeImages{imageIndex},...
                        measurementParams(imageIndex).imageProcessingParams.tileOrResizePreprocessing, measurementParams(imageIndex).imageProcessingParams.binarisationThreshold);
                elseif strcmp(measurementParams(1).imageProcessingParams.autoSaveProbabilityMap, 'on')
                    [binaryImages{imageIndex}, probabilityMaps{imageIndex}] = MembraneImageAnalyzer.predictSingleImage(net, slopeImages{imageIndex},...
                        measurementParams(imageIndex).imageProcessingParams.tileOrResizePreprocessing, measurementParams(imageIndex).imageProcessingParams.binarisationThreshold);                    
                end
                
                if measurementParams(1).imageProcessingParams.useMorphologicalOperations
                    binaryImages{imageIndex} = MembraneImageAnalyzer.morphologicalOperations(binaryImages{imageIndex});
                end

            end
        end
        
        function [prediction, prediction_raw] = predictSingleImage(kerasModel, inputImage, varargin)
            
            binarisationThreshold = 0.5;
            analysisMode = 'Tile';
                
            if numel(varargin) > 0               
                if strcmp(varargin{1}, 'Tile')
                    analysisMode = 'Tile';
                elseif strcmp(varargin{1}, 'Resize')
                    analysisMode = 'Resize';
                end  
            end
            
            if numel(varargin) > 1
                binarisationThreshold = varargin{2};
            end
                
                
            modelInputSize = kerasModel.Layers(1).InputSize(1:2);
            
            if strcmp(analysisMode, 'Tile')

                overlapPixels = ceil(modelInputSize(1)*0.305); % 
                prePad = MembraneImageAnalyzer.calculatePrePad(overlapPixels, modelInputSize(1));


                postPadY = MembraneImageAnalyzer.calculatePostPad(overlapPixels, modelInputSize(1), size(inputImage, 1));
                postPadX = MembraneImageAnalyzer.calculatePostPad(overlapPixels, modelInputSize(2), size(inputImage, 2));

                yPad = ceil(size(inputImage, 1)/modelInputSize(1)) * modelInputSize(1) - size(inputImage, 1);
                xPad = ceil(size(inputImage, 2)/modelInputSize(2)) * modelInputSize(2) - size(inputImage, 2);
                paddedImage = padarray(inputImage, [prePad, prePad], 'symmetric', 'pre');
                paddedImage = padarray(paddedImage, [postPadY, postPadX], 'symmetric', 'post');
                resultImage = zeros(size(paddedImage));
                predictionCounter = zeros(size(paddedImage));
                colSequence = 1 : modelInputSize(1) - overlapPixels : size(resultImage, 1) - (modelInputSize(1) - overlapPixels);
                rowSequence = 1 : modelInputSize(2) - overlapPixels : size(resultImage, 2) - (modelInputSize(2) - overlapPixels);

                try
                    imagesToPredict = zeros(modelInputSize(1), modelInputSize(2), 1, numel(colSequence) * numel(rowSequence));
                    counter = 1;
                    for col = colSequence 
                        for row = rowSequence
                            imagesToPredict(:, :, 1, counter) = paddedImage(col : col + (modelInputSize(1) - 1), row : row + (modelInputSize(2) - 1));
                            counter = counter + 1;
                        end
                    end

                    predictions = predict(kerasModel, imagesToPredict, 'ExecutionEnvironment', 'gpu', 'MiniBatchSize', 4);

                    counter = 1;
                    for col = colSequence 
                        for row = rowSequence
                            predictionCounter(col : col + modelInputSize(1) - 1, row : row + modelInputSize(2) - 1) = predictionCounter(col : col + modelInputSize(1) - 1, row : row + modelInputSize(2) - 1) + 1;
                            resultImage(col : col + modelInputSize(1) - 1, row : row + modelInputSize(2) - 1) = resultImage(col : col + modelInputSize(1) - 1, row : row + modelInputSize(2) - 1).*(predictionCounter(col : col + modelInputSize(1) - 1, row : row + modelInputSize(2) - 1) - 1) + predictions(:, :, 1, counter);
                            resultImage(col : col + modelInputSize(1) - 1, row : row + modelInputSize(2) - 1) = resultImage(col : col + modelInputSize(1) - 1, row : row + modelInputSize(2) - 1)./predictionCounter(col : col + modelInputSize(1) - 1, row : row + modelInputSize(2) - 1);
                            counter = counter + 1;
                        end
                    end
                catch
                    % in case when gpu is not available, matlab is out of
                    % memory or gpu is out of memory
                    disp('no gpu found or out of memory');
                    for col = colSequence 
                        for row = rowSequence
                            predictionCounter(col : col + modelInputSize(1) - 1, row : row + modelInputSize(2) - 1) = predictionCounter(col : col + modelInputSize(1) - 1, row : row + modelInputSize(2) - 1) + 1;
                            resultImage(col : col + modelInputSize(1) - 1, row : row + modelInputSize(2) - 1) = resultImage(col : col + modelInputSize(1) - 1, row : row + modelInputSize(2) - 1).*(predictionCounter(col : col + modelInputSize(1) - 1, row : row + modelInputSize(2) - 1) - 1) + predict(kerasModel, paddedImage(col : col + modelInputSize(1) - 1, row : row + modelInputSize(2) - 1));
                            resultImage(col : col + modelInputSize(1) - 1, row : row + modelInputSize(2) - 1) = resultImage(col : col + modelInputSize(1) - 1, row : row + modelInputSize(2) - 1)./predictionCounter(col : col + modelInputSize(1) - 1, row : row + modelInputSize(2) - 1);
                        end
                    end
                end
                prediction_raw = resultImage(prePad : prePad +  size(inputImage, 1) - 1, prePad : prePad + size(inputImage, 2) - 1);
            elseif strcmp(analysisMode, 'Resize')
                resizedImage = imresize(inputImage, modelInputSize, 'bilinear');
                prediction_raw = imresize(predict(kerasModel, resizedImage, 'ExecutionEnvironment', 'gpu', 'MiniBatchSize', 1), size(inputImage), 'bilinear');                
            end            
            prediction = prediction_raw > binarisationThreshold;          
        end
        
        function prePad = calculatePrePad(overlap, tileLength)
            if overlap > 0
                prePad = tileLength - overlap;
            else
            	prePad = 0;
            end
        end
        
        function postPad = calculatePostPad(overlap, tileLength, totalLength)
            padDelta = tileLength - overlap;
            postPad = tileLength + floor(totalLength / padDelta) * padDelta - totalLength;
        end
        
        function binaryImage = morphologicalOperations(binaryImage)
            % post operation
            % clean, spur, bridge, thin and thicken
            %figure
            %imshow(binaryImages{imageIndex})
            %clean
            %figure
            cleaned = bwareaopen(binaryImage, 20, 4);
            %imshow(cleaned)
            %figure
            filled = ~bwareaopen(~cleaned, 30, 4);
            %imshow(filled)
            %figure
            bridged = bwmorph(filled, 'bridge');
            %imshow(bridged)
            %figure
            filled_again = ~bwareaopen(~bridged, 30, 4); % morph 1 skips this
            %imshow(filled_again)
            %figure
            thinned = bwmorph(filled_again, 'thin', inf);
            %imshow(thinned)
            %figure
            diagonalized = thinned;
            %imshow(diagonalized)
            %figure
            thickened = imdilate(diagonalized, strel('disk', 1));
            %imshow(thickened)
            binaryImage = thickened;
        end
        
        function binaryImages = createBinaryImages(slopeImages, measurementParams, ilastikPath)
            
            s = alphabet();
            %find number of random characters to choose from
            numRands = length(s); 
            %specify length of random string to generate
            sLength = 5;
            %generate random string
            randString = s( ceil(rand(1,sLength)*numRands) );
            filePath = mfilename('fullpath');
            tempPath = [filePath(1), ':\tempdir\', 'Aparecium\MembraneToolsTempDir\'];
            if ~exist(tempPath, 'dir')
               mkdir(tempPath);
            end
            
            IlastikCallStringArray = cell(0,1);
            IlastikCallString = ['start /min ilastik.exe --headless --project=', measurementParams(1).imageProcessingParams.ilastikModelPath, ' '];
            IlastikExpectedFileCount = 0;
            for imageIndex = 1 : numel(slopeImages)
                if numel([IlastikCallString, tempPath,'\', num2str(imageIndex), randString,'.tif ']) < 8180 % windows command line max length taking end commands into account
                    IlastikCallString = [IlastikCallString, tempPath,'\', num2str(imageIndex), randString,'.tif '];
                    IlastikExpectedFileCount(end) = IlastikExpectedFileCount(end) + 1;
                else
                    IlastikCallStringArray{end + 1} = [IlastikCallString, ' && exit &'];
                    IlastikCallString = ['!ilastik.exe --headless --project=', measurementParams(1).imageProcessingParams.ilastikModelPath, ' '];
                    IlastikCallString = [IlastikCallString, tempPath,'\', num2str(imageIndex), randString,'.tif '];
                    IlastikExpectedFileCount(end + 1) = 1;               
                end
                %imwrite(uint8(slopeImages{imageIndex}*255), [tempPath, num2str(imageIndex), randString,'.tif'], 'tif');
                if max(max(slopeImages{imageIndex}))==1
                    imwrite(uint8(slopeImages{imageIndex}*255), [tempPath, num2str(imageIndex), randString,'.tif'], 'tif'); 
                else
                    imwrite(uint16(slopeImages{imageIndex}), [tempPath, num2str(imageIndex), randString,'.tif'], 'tif');
                end
            end
            IlastikCallStringArray{end + 1} = [IlastikCallString, ' && exit &'];
            oldPath = pwd;
            cd(ilastikPath);
            timeoutForSingleImage = 600;
            
            for ilastikCall = 1 : numel(IlastikCallStringArray)
                dirBefore = dir(tempPath);
                dirPrevious = dirBefore;
                if ~exist('ilastik.exe') && exist('ilastik.lnk')
                    IlastikCallStringArray{ilastikCall} = regexprep(IlastikCallStringArray{ilastikCall}, 'ilastik.exe', 'ilastik.lnk');
                end
                system(IlastikCallStringArray{ilastikCall});
                %eval(IlastikCallStringArray{ilastkCall});
                tic
                while true
                    pause(10);
                    dirAfter = dir(tempPath);
                    timePassed = toc;
                    if isequal(dirPrevious, dirAfter) && timePassed > timeoutForSingleImage
                        
                        % find the ilastik process and kill it
                        [~, tasks] = system('tasklist');
                        index = strfind(tasks, 'ilastik.exe');
                        processID = regexp(tasks(index:end), '[0-9]{1,6}', 'once', 'match');
                        
                        system(['taskkill /pid ', processID]);
                        pause(5)
                        system(IlastikCallStringArray{ilastikCall});
                        tic
                    elseif ~isequal(dirPrevious, dirAfter) || isequal(numel(dirAfter) - numel(dirBefore), IlastikExpectedFileCount(ilastikCall))
                        numel(dirAfter) - numel(dirBefore);
                        IlastikExpectedFileCount(ilastikCall);
                        if isequal(numel(dirAfter) - numel(dirBefore), IlastikExpectedFileCount(ilastikCall))                            
                            pause(15) % give some time to finish writing the file
                            break; 
                        end
                        dirPrevious = dir(tempPath);
                        tic
                    end
                end
            end
            
            cd(oldPath);
            binaryImages = cell(size(slopeImages));
            for imageIndex = 1: numel(slopeImages)             
                h5 = hdf5read([tempPath, num2str(imageIndex), randString,'_Probabilities.h5'], '/exported_data');
                delete([tempPath, num2str(imageIndex), randString,'_Probabilities.h5']);
                delete([tempPath, num2str(imageIndex), randString,'.tif']);
                [unneeded, maxProbImg] = max(h5, [], 1);
                binaryImages{imageIndex} = squeeze(maxProbImg == measurementParams(1).imageProcessingParams.membraneLabelIndex)';%measurementParams(1).imageProcessingParams.membraneLabelIndex);
                %binaryImages{imageIndex} = (squeeze(h5(3,:,:)) > 127)';
                if measurementParams(1).imageProcessingParams.useMorphologicalOperations
                    % post operation
                    % clean, spur, bridge, thin and thicken
                    %figure
                    %imshow(binaryImages{imageIndex})
                    %clean
                    %figure
                    cleaned = bwareaopen(binaryImages{imageIndex}, 20, 4);
                    %imshow(cleaned)
                    %figure
                    filled = ~bwareaopen(~cleaned, 30, 4);
                    %imshow(filled)
                    %figure
                    bridged = bwmorph(filled, 'bridge');
                    %imshow(bridged)
                    %figure
                    filled_again = ~bwareaopen(~bridged, 30, 4); % morph 1 skips this
                    %imshow(filled_again)
                    %figure
                    thinned = bwmorph(filled_again, 'thin', inf);
                    %imshow(thinned)
                    %figure
                    diagonalized = thinned;
                    %imshow(diagonalized)
                    %figure
                    thickened = imdilate(diagonalized, strel('disk', 1));
                    %imshow(thickened)
                    binaryImages{imageIndex} = thickened;
                end
            end
            % pack the images for memory efficiency
            for imageIndex = 1: numel(slopeImages)
                binaryImages{imageIndex} = bwpack(binaryImages{imageIndex});
            end
        end
        
        function image = createFocusImage(measurementParams)
            path = measurementParams.directoryPath;
            firstImageName = measurementParams.wellName;
            image = imread(fullfile(path,firstImageName));
            %slopes = stackLinearReg(path, firstImageName, 'stdev');
            %if strcmp(class(image), 'uint8')
            %   image = double(image)/256; 
            %end
            %if strcmp(class(image), 'uint16')
            %   image = double(image)/2^16; 
            %end
            %slopes = imgaussfilt(slopes);% experimental extra step
            %image = (image-min(min(image)))/max(max(image-min(min(image))));
        end
        
        function image = createFocusImageNoNorm(measurementParams)
            path = measurementParams.directoryPath;
            firstImageName = measurementParams.wellName;
            image = imread(fullfile(path,firstImageName));
            %slopes = stackLinearReg(path, firstImageName, 'stdev');
            if strcmp(class(image), 'uint8')
               image = double(image)/256; 
            end
            if strcmp(class(image), 'uint16')
               image = double(image)/2^16; 
            end
        end
        
        function slopeImage = createSlopeImage(measurementParams)
            path = measurementParams.directoryPath;
            firstImageName = measurementParams.wellName;
            ZIndex = strfind(firstImageName, 'Z');
            ZIndex = ZIndex(end); % for avoiding situations where the image name contains several Z-s, for example in the well name
            focusIndex = str2num(firstImageName(ZIndex+1))+1;
            try
                slopes = stackLinearRegPartial(path, firstImageName, 'stdev',[focusIndex - 2 : focusIndex + 5]);
            catch
                try
                    slopes = stackLinearRegPartial(path, firstImageName, 'stdev',[focusIndex - 2 : focusIndex + 4]);
                catch
                    slopes = stackLinearRegPartial(path, firstImageName, 'stdev',[focusIndex - 1 : focusIndex + 3]);
                end
            end
            %slopes = stackLinearReg(path, firstImageName, 'stdev');
            if strcmp(class(slopes), 'uint8')
               slopes = double(slopes)/256; 
            end
            %slopes = imgaussfilt(slopes);% experimental extra step
            slopeImage = (slopes-min(min(slopes)))/max(max(slopes-min(min(slopes))));
        end
        
        function resultStructure = analyzeMembranesStatic(picName, secondaryPicName, filePath, secondaryFilePath, imageProcessingParameters,...
                timeParameters, functionHandle, calculationMethod, qualityMask, parametersToCalculate, providedBinary, mainDir, usedDir, varargin)
            disp('MembraneImageAnalyzer');
            subtractBackground = imageProcessingParameters.getSubtractBackground();
            resultStructure = MembraneImageAnalyzer.analyseOneImageStatic(picName, filePath, imageProcessingParameters, timeParameters, functionHandle, parametersToCalculate, providedBinary);

            pixelShiftVertical = imageProcessingParameters.getPixelShiftVertical();
            pixelShiftHorizontal = imageProcessingParameters.getPixelShiftHorizontal();
           
            qualityMask = qualityMask(pixelShiftVertical + 1 : end, pixelShiftHorizontal + 1 : end);
            contents = dir(filePath);
            contents(1:2) = [];
            cellContents = struct2cell(contents);
            possibleNames = cellContents(1, :);
            
            % Check if Z-stack at all is present
            imagePlaneIndex = str2double(regexp(regexp(regexp(secondaryPicName,'(_\d{1,2}Z\d{1,2})', 'match', 'once'), '(Z\d{1,3})', 'match', 'once'), '(\d{1,3})', 'match', 'once'));
            
            if strcmp(imageProcessingParameters.focusOrMaxProjection, 'max projection') && ~isnan(imagePlaneIndex)
                % prepare Zstack image names
                ZIndex = regexp(secondaryPicName, '_\d{1,2}Z\d{1,2}');
                substr = regexp(secondaryPicName, '_\d{1,2}Z\d{1,2}', 'match', 'once');
                ZIndex = ZIndex + regexp(substr, 'Z') - 1;
                names = cell(1, numel(possibleNames));
                index = 0;
                while 1
                    pathlessName = [secondaryPicName(1:ZIndex), num2str(index), '_',imageProcessingParameters.quantificationChannelRegex,'_', secondaryPicName(end-6:end)];
                    if isequal(sum(strcmp(possibleNames, pathlessName)), 0)
                       break; 
                    end

                    names{index + 1} = fullfile(filePath, [secondaryPicName(1:ZIndex), num2str(index),'_',imageProcessingParameters.quantificationChannelRegex,'_', secondaryPicName(end-6:end)]);
                    index = index + 1;
                end

                names = names(~cellfun(@isempty, names));
                focusedImage = focusFromZstack(names);
            elseif strcmp(imageProcessingParameters.focusOrMaxProjection, 'focus') || isnan(imagePlaneIndex)
                focusedImage = double(focusFromZstack({fullfile(secondaryFilePath, secondaryPicName)}));
                if strcmp(imageProcessingParameters.membraneToolsBackgroundCorrection.quantificationChannelBackgroundCorrectionFunctionName, 'polyfit')            
                    imageBackground = polybg(focusedImage);
                    if subtractBackground
                        focusedImage = (focusedImage./imageBackground)*mean(mean(imageBackground))-mean(mean(imageBackground));
                    else
                        focusedImage = (focusedImage./imageBackground)*mean(mean(imageBackground));
                    end
                end                
                focusedImage = focusedImage(1 : end - pixelShiftVertical, 1 : end - pixelShiftHorizontal);
                secondaryPicName
            end
            originalBinaryImage = resultStructure.image;
            if strcmp(calculationMethod, 'Binary')
                
                binaryImageCalculator = BinaryImageCalculator();
                parametersToCalculate = {'confluency', 'image'};
                maskedImage = and(1-qualityMask, resultStructure.image);
                binaryImageCalculator.calculateImageParameters(maskedImage, parametersToCalculate, functionHandle);
                maskedResultStructure = binaryImageCalculator.resultStructure;
                indices = maskedResultStructure.image == 1;
                resultStructure.image = maskedResultStructure.image;
                resultStructure.confluency = maskedResultStructure.confluency;
                resultStructure.averageMembraneIntensity = mean(focusedImage(indices)); % image was instead of focusedImage
                nonMaskIndices = qualityMask == 0;
                resultStructure.averageSecondaryImageIntensity = mean(mean(focusedImage(nonMaskIndices)));
                
                resultStructure.membranePixelCount = numel(find(indices==1));
                resultStructure.membraneIntensityStandardDeviation = std(double(focusedImage(indices)));
                
                reverseMaskedImage = and(1-qualityMask, 1-resultStructure.image);
                binaryImageCalculator = BinaryImageCalculator();
                binaryImageCalculator.calculateImageParameters(reverseMaskedImage, parametersToCalculate, functionHandle);
                maskedResultStructure = binaryImageCalculator.resultStructure;
                indices = maskedResultStructure.image == 1;
                resultStructure.averageNonMembraneIntensity = mean(focusedImage(indices));
                sortedPixels = sort(focusedImage(indices));
                try
                    resultStructure.firstNonMembraneQuadrileIntensity = mean(sortedPixels(1:ceil(numel(sortedPixels)/4)));
                catch
                    resultStructure.firstNonMembraneQuadrileIntensity = mean(sortedPixels(1:floor(numel(sortedPixels)/4)));
                end
                               
                binaryImageCalculator = BinaryImageCalculator();
                parametersToCalculate = {'confluency', 'image'};
                binaryImageCalculator.calculateImageParameters(originalBinaryImage, parametersToCalculate, functionHandle);
                unmaskedResultStructure = binaryImageCalculator.resultStructure;
                indices = unmaskedResultStructure.image == 1;
                resultStructure.averageUnmaskedMembraneIntensity = mean(focusedImage(indices));
                resultStructure.averageUnmaskedSecondaryImageIntensity = mean(mean(focusedImage));
                reverseImage = 1-resultStructure.image;
                binaryImageCalculator = BinaryImageCalculator();
                binaryImageCalculator.calculateImageParameters(reverseImage, parametersToCalculate, functionHandle);
                unmaskedResultStructure = binaryImageCalculator.resultStructure;
                indices = unmaskedResultStructure.image == 1;
                
                resultStructure.averageUnmaskedNonMembraneIntensity = mean(focusedImage(indices));
                sortedPixels = sort(focusedImage(indices));
                try
                    resultStructure.firstUnmaskedNonMembraneQuadrileIntensity = mean(sortedPixels(1:ceil(numel(sortedPixels)/4)));
                catch
                    resultStructure.firstUnmaskedNonMembraneQuadrileIntensity = mean(sortedPixels(1:floor(numel(sortedPixels)/4)));
                end
                resultStructure.secondaryImageName = secondaryPicName;
                
            elseif strcmp(calculationMethod, 'Probability')
                 resultStructure.averageMembraneIntensity = sum(sum(double(focusedImage).*resultStructure.probabilityImage))/(sum(sum(resultStructure.probabilityImage)));
            end
            
            % save binary image on hard drive if saving is activated
            % instead of keeping it in memory
            if strcmp(imageProcessingParameters.autoSaveBinaryFiles, 'on')
                imagePath = ImageAnalyzer.saveBinaryImage(resultStructure.image, picName, mainDir, usedDir);
                resultStructure.image = imagePath;
            end
            
            if numel(varargin) > 0 && strcmp(imageProcessingParameters.autoSaveProbabilityMap, 'on')
                imagePath = ImageAnalyzer.saveProbabilityMap(varargin{1}, picName, mainDir, usedDir);
                resultStructure.probabilityMap = imagePath;
            end
        end
        
        function resultStructure = analyseOneImageStatic(picName, filePath, imageProcessingParameters, timeParameters, functionHandle, parametersToCalculate, providedBinary)
                tic

                try
                    image = Cytation5TIFFImage(fullfile(filePath, picName));
                    I_org1 = image.getImage();
                    imageTime = image.getImageTime();
                    imageWidthMicrons = image.getImageWidthMicrons();
                    imageHeightMicrons = image.getImageHeightMicrons();
                catch MException
                    I_org1 = imread([filePath, picName]); 
                    imageTime = 0;
                end
                I_org = im2uint8(I_org1);
                imageProcessingMode = imageProcessingParameters.getMode();
                switch imageProcessingMode
                    case imageProcessingParameters.Slopes
                        switch imageProcessingParameters.detectionModel
                            case imageProcessingParameters.SobelModel
                                I_orgTrue = I_org(:,:,1); 
                                in.upper = imageProcessingParameters.upperThreshold;
                                in.lower = imageProcessingParameters.lowerThreshold;
                                in.threshold = imageProcessingParameters.postDilateCutoff;
                                in.method = 'sobel';
                                in.edgeThreshold = imageProcessingParameters.extraEdgeThreshold;
                                in.smallSizeCutoff = imageProcessingParameters.preDilateCutoff;
                                in.path = filePath;
                                in.firstImageName = picName;
                                try
                                    [bw2, probabilityImage] = ZStackBinary(in);
                                    resultStructure.probabilityImage = probabilityImage;

                                catch
                                    bw2 = zeros(size(I_orgTrue, 1), size(I_orgTrue, 2));
                                end
                            case imageProcessingParameters.IlastikModel
                                bw2 = providedBinary;
                            case imageProcessingParameters.KerasModel
                                bw2 = providedBinary;
                                
                        end
                    case imageProcessingParameters.FromBinary
                        I_orgTrue = I_org(:,:,1); 
                        bw2 = providedBinary; % already swapped before
                end

              
                binaryImageCalculator = BinaryImageCalculator();
                parametersToCalculate = {'area', 'areaSTD', 'diameter', 'diameterSTD', 'objectCount', 'maxDiameter', 'image', 'confluency'};
                binaryImageCalculator.calculateImageParameters(bw2, parametersToCalculate, functionHandle);
                resultStructure = binaryImageCalculator.resultStructure;
                resultStructure.imageTime = imageTime;
                try
                    resultStructure.imageWidthMicrons = imageWidthMicrons;
                    resultStructure.imageHeightMicrons = imageHeightMicrons;
                catch
                    resultStructure.imageWidthMicrons = nan;
                    resultStructure.imageHeightMicrons = nan;
                end
                resultStructure.imageWidthPixels = size(I_org, 2);
                resultStructure.imageHeightPixels = size(I_org, 1);
                switch imageProcessingParameters.useParallelComputing
                    case 'on'

                    case 'off'
                      timePassed = toc(timeParameters.analysisStartTime);
                end

           %clear references to java objects
           clear image I_org1 I_org
           toc
        end
        
    end
    
end