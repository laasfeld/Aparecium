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
    
        function resultStructure = analyzeMembranesStatic(picName, secondaryPicName, filePath, imageProcessingParameters, timeParameters, figureHandles, functionHandle, calculationMethod, qualityMask, parametersToCalculate)
            disp('MembraneImageAnalyzer');
            resultStructure = ImageAnalyzer.analyseOneImageStatic(picName, filePath, imageProcessingParameters, timeParameters, figureHandles, functionHandle, parametersToCalculate);

            image = imread([filePath, secondaryPicName]);
            contents = dir(filePath);
            contents(1:2) = [];
            cellContents = struct2cell(contents);
            possibleNames = cellContents(1, :);
            % prepare Zstack image names
            ZIndex = strfind(secondaryPicName, '_1Z');
            names = cell(1, numel(possibleNames));
            index = 0;
            while 1
                pathlessName = [secondaryPicName(1:ZIndex+2), num2str(index), '_RFP_', secondaryPicName(end-6:end)];
                if isequal(sum(strcmp(possibleNames, pathlessName)), 0)
                   break; 
                end
                
                names{index + 1} = [filePath, secondaryPicName(1:ZIndex+2), num2str(index), '_RFP_', secondaryPicName(end-6:end)];
                index = index + 1;
            end
            
            names = names(~cellfun(@isempty, names));
            focusedImage = focusFromZstack(names);
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
                
            elseif strcmp(calculationMethod, 'Probability')
                 resultStructure.averageMembraneIntensity = sum(sum(double(image).*resultStructure.probabilityImage))/(sum(sum(resultStructure.probabilityImage)));
            end
        end
        
        function resultStructure = analyseOneImageStatic(picName, filePath, imageProcessingParameters, timeParameters, figureHandles, functionHandle)
                tic

                try
                    image = Cytation5TIFFImage([filePath, picName]);
                    I_org1 = image.getImage();
                    imageTime = image.getImageTime();
                catch MException
                    I_org1 = imread([filePath, picName]); 
                    imageTime = 0;
                end
                I_org = im2uint8(I_org1);
                imageProcessingMode = imageProcessingParameters.getMode();
                switch imageProcessingMode
                    case imageProcessingParameters.Slopes
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
                end

              
                binaryImageCalculator = BinaryImageCalculator();
                parametersToCalculate = {'area', 'areaSTD', 'diameter', 'diameterSTD', 'objectCount', 'maxDiameter', 'image', 'confluency'};
                binaryImageCalculator.calculateImageParameters(bw2, parametersToCalculate, functionHandle);
                resultStructure = binaryImageCalculator.resultStructure;
                resultStructure.imageTime = imageTime;
                switch imageProcessingParameters.useParallelComputing
                    case 'on'

                    case 'off'
                        try
                            timePassed = toc(timeParameters.analysisStartTime);
                            if ~isempty(figureHandles)
                                imshow(I_orgTrue, 'Parent', figureHandles(1));
                                imshow(bw2, 'Parent', figureHandles(2));
                            end
                        catch
                            'no handles present';
                        end
                end

           %clear references to java objects
           clear image I_org1 I_org
           toc
        end
        
    end
    
end

