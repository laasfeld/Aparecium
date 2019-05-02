classdef ICSEImageAnalyzer < ImageAnalyzer
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

    end
    
    methods
        function this = ICSEImageAnalyzer()
           this.ICSEOrMembrane = 'ICSE'; 
        end
    end
    
    methods (Static)      
        function resultStructure = analyseOneImageStatic(picName, filePath, imageProcessingParameters, timeParameters, functionHandle, parametersToCalculate)
            'ICSE'    
            tic
                try
                    image = Cytation5TIFFImage([filePath, picName]);
                    I_org1 = image.getImage();
                    imageTime = image.getImageTime();
                    imageWidthMicrons = image.getImageWidthMicrons();
                    imageHeightMicrons = image.getImageHeightMicrons();
                catch
                    I_org1 = imread([filePath, picName]); 
                    imageTime = 0;
                    'failed to get image time'
                end
                I_org = im2uint8(I_org1);
                imageProcessingMode = imageProcessingParameters.getMode();
                switch imageProcessingMode
                    case imageProcessingParameters.Full
                       I_orgTrue = I_org(:,:,1); 
                       bw2 = ImageAnalyzer.segmentImage(imageProcessingParameters, I_orgTrue);
                    case imageProcessingParameters.FastFull
                        for row = 1:3
                            for col = 1:4
                                I_orgTrue = I_org((row-1)*301+1:row*301, (col-1)*306+1:col*306,1);
                                try 
                                    bw2((row-1)*301+1:row*301, (col-1)*306+1:col*306,1) = ImageAnalyzer.segmentImage(imageProcessingParameters, I_orgTrue);
                                catch

                                end
                            end
                        end           
                    case imageProcessingParameters.Fast
                       I_orgTrue = I_org(300:600,460:760,1); 
                       bw2 = ImageAnalyzer.segmentImage(imageProcessingParameters, I_orgTrue);
                    case imageProcessingParameters.FromBinary
                        I_orgTrue = I_org(:,:,1); 
                        bw2 = getBinaryOfImage([filePath, picName]);
                end
                
                binaryImageCalculator = BinaryImageCalculator();
                parametersToCalculate = {'area', 'areaSTD', 'diameter', 'diameterSTD', 'objectCount', 'maxDiameter', 'image', 'confluency'};
                binaryImageCalculator.calculateImageParameters(bw2, parametersToCalculate, functionHandle);
                resultStructure = binaryImageCalculator.resultStructure
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
                clear image I_org1 I_org
                toc
        end
        
    end
    
end

