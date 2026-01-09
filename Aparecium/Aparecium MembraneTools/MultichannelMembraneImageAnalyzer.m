classdef MultichannelMembraneImageAnalyzer < MembraneImageAnalyzer
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods
        function obj = untitled(inputArg1,inputArg2)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
        
        function multichannelImage = createMultichannelImage(measurementParams)
            
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
                        elseif strcmp(measurementParams(1).imageProcessingParams.detectionFocusOrSlopes, 'Multichannel')
                            imagesForBinaryGeneration{counter} = MultichannelMembraneImageAnalyzer.createMultichannelImage(measurementParams(i));
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
    end
end




