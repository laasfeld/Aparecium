classdef MembraneImageAnalyzer < ImageAnalyzer
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function this = MembraneImageAnalyzer()
           this.ICSEOrMembrane = 'Membrane'; 
        end 
    end
    
    methods (Static)
    
        function measurementParams = performIlastikAnalysis(measurementParams)
            
            fileChooser = FileChooser();
            ilastikPath = fileChooser.getIlastikExecutablePath();
            
            parfor i = 1 : numel(measurementParams) % parfor should be here
                if strcmp(measurementParams(1).imageProcessingParams.detectionFocusOrSlopes, 'Slopes')
                    imagesForBinaryGeneration{i} = MembraneImageAnalyzer.createSlopeImage(measurementParams(i));
                elseif strcmp(measurementParams(1).imageProcessingParams.detectionFocusOrSlopes, 'Focus')
                    imagesForBinaryGeneration{i} = MembraneImageAnalyzer.createFocusImage(measurementParams(i));
                end
            end
            
            % intoduce the pixel shifts to images
            for i = 1 : numel(measurementParams)
                pixelShiftVertical = measurementParams(i).imageProcessingParams.getPixelShiftVertical();
                pixelShiftHorizontal = measurementParams(i).imageProcessingParams.getPixelShiftHorizontal();
                imagesForBinaryGeneration{i} = imagesForBinaryGeneration{i}(pixelShiftVertical+1:end, pixelShiftHorizontal+1:end);
            end
            
            binaryImages = MembraneImageAnalyzer.createBinaryImages(imagesForBinaryGeneration, measurementParams, ilastikPath);
            for imageIndex = 1 : numel(measurementParams)
                measurementParams(imageIndex).results = MembraneImageAnalyzer.analyzeMembranesStatic(...
            measurementParams(imageIndex).wellName, measurementParams(imageIndex).secondaryPicOfWell, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).imageProcessingParams,...
            measurementParams(imageIndex).timeParameters, measurementParams(imageIndex).thresholdFunctionHandle, measurementParams(imageIndex).calculationMethod, measurementParams(imageIndex).qualityMask, ...
            measurementParams(imageIndex).parametersToCalculate, binaryImages{imageIndex});
            end
            %(...
            %measurementParams(imageIndex).wellName, measurementParams(imageIndex).secondaryPicOfWell, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).imageProcessingParams,...
            %measurementParams(imageIndex).timeParameters, measurementParams(imageIndex).thresholdFunctionHandle, measurementParams(imageIndex).calculationMethod, measurementParams(imageIndex).qualityMask, ...
            %measurementParams(imageIndex).parametersToCalculate)
            %!ilastik.exe --headless --project=C:\Users\Kasutaja\IlastikMembraneDetector.ilp D:\Original_slope_and_stdev_images\*.tif
        end
        
        function binaryImages = createBinaryImages(slopeImages, measurementParams, ilastikPath)
            
            s = alphabet();
            %find number of random characters to choose from
            numRands = length(s); 
            %specify length of random string to generate
            sLength = 5;
            %generate random string
            randString = s( ceil(rand(1,sLength)*numRands) );
            tempPath = [tempdir,'Aparecium\MembraneToolsTempDir\'];
            if ~exist(tempPath, 'dir')
               mkdir(tempPath);
            end
            
            IlastikCallStringArray = cell(0,1);
            IlastikCallString = ['!ilastik.exe --headless --project=', measurementParams(1).imageProcessingParams.ilastikModelPath, ' '];
            for imageIndex = 1 : numel(slopeImages)
                if numel([IlastikCallString, tempPath,'\', num2str(imageIndex), randString,'.tif ']) < 8190 % windows command line max length
                    IlastikCallString = [IlastikCallString, tempPath,'\', num2str(imageIndex), randString,'.tif '];
                else
                    IlastikCallStringArray{end + 1} = IlastikCallString;
                    IlastikCallString = ['!ilastik.exe --headless --project=', measurementParams(1).imageProcessingParams.ilastikModelPath, ' '];
                    IlastikCallString = [IlastikCallString, tempPath,'\', num2str(imageIndex), randString,'.tif '];                  
                end
                imwrite(uint8(slopeImages{imageIndex}*255), [tempPath, num2str(imageIndex), randString,'.tif'], 'tif');
            end
            IlastikCallStringArray{end + 1} = IlastikCallString;
            oldPath = pwd;
            cd(ilastikPath);
            for ilastkCall = 1 : numel(IlastikCallStringArray)
                eval(IlastikCallStringArray{ilastkCall});
            end
            cd(oldPath);
            binaryImages = cell(size(slopeImages));
            for imageIndex = 1: numel(slopeImages)             
                h5 = hdf5read([tempPath, num2str(imageIndex), randString,'_Probabilities.h5'], '/exported_data');
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
        end
        
        function image = createFocusImage(measurementParams)
            path = measurementParams.directoryPath;
            firstImageName = measurementParams.wellName;
            image = imread([path,'/',firstImageName]);
            %slopes = stackLinearReg(path, firstImageName, 'stdev');
            if strcmp(class(image), 'uint8')
               image = double(image)/256; 
            end
            if strcmp(class(image), 'uint16')
               image = double(image)/2^16; 
            end
            %slopes = imgaussfilt(slopes);% experimental extra step
            image = (image-min(min(image)))/max(max(image-min(min(image))));
        end
        
        function slopeImage = createSlopeImage(measurementParams)
            path = measurementParams.directoryPath;
            firstImageName = measurementParams.wellName;
            ZIndex = strfind(firstImageName, 'Z');
            ZIndex = ZIndex(end); % for avoiding situations where the image name contains several Z-s, for example in the well name
            focusIndex = str2num(firstImageName(ZIndex+1))+1;
            slopes = stackLinearRegPartial(path, firstImageName, 'stdev',[focusIndex - 2:focusIndex+5]);
            %slopes = stackLinearReg(path, firstImageName, 'stdev');
            if strcmp(class(slopes), 'uint8')
               slopes = double(slopes)/256; 
            end
            %slopes = imgaussfilt(slopes);% experimental extra step
            slopeImage = (slopes-min(min(slopes)))/max(max(slopes-min(min(slopes))));
        end
        
        function resultStructure = analyzeMembranesStatic(picName, secondaryPicName, filePath, secondaryFilePath, imageProcessingParameters, timeParameters, functionHandle, calculationMethod, qualityMask, parametersToCalculate, providedBinary)
            disp('MembraneImageAnalyzer');
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

                    names{index + 1} = [filePath, secondaryPicName(1:ZIndex), num2str(index),'_',imageProcessingParameters.quantificationChannelRegex,'_', secondaryPicName(end-6:end)];
                    index = index + 1;
                end

                names = names(~cellfun(@isempty, names));
                focusedImage = focusFromZstack(names);
            elseif strcmp(imageProcessingParameters.focusOrMaxProjection, 'focus') || isnan(imagePlaneIndex)
                focusedImage = focusFromZstack({[secondaryFilePath, secondaryPicName]});
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
        end
        
        function resultStructure = analyseOneImageStatic(picName, filePath, imageProcessingParameters, timeParameters, functionHandle, parametersToCalculate, providedBinary)
                tic

                try
                    image = Cytation5TIFFImage([filePath, picName]);
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
                        end
                    case imageProcessingParameters.FromBinary
                        I_orgTrue = I_org(:,:,1); 
                        bw2 = getBinaryOfImage([filePath, picName]);
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

