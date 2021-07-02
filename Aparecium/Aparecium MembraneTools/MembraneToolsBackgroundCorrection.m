classdef MembraneToolsBackgroundCorrection < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        detectionChannelBackgroundCorrectionFunctionName = 'polyfit';
        quantificationChannelBackgroundCorrectionFunctionName = 'polyfit';
        detectionChannelBackgroundCorrectionCustomFunctionHandle = [];
        quantificationChannelBackgroundCorrectionCustomFunctionHandle = [];
        imageNameToBackgroundPathMap = containers.Map;
        bgestFunctionHandle = @(image) uint16(bgest(double(image), 100));
        polybgFunctionHandle = @(image) uint16(polybg(double(image)));
    end
    
    methods
        function this = MembraneToolsBackgroundCorrection()
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here    
        end
        
        function setDetectionChannelBackgroundCorrectionCustomFunctionHandle(this, functionHandle)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            this.detectionChannelBackgroundCorrectionCustomFunctionHandle = functionHandle;
        end
        
        function setQuantificationChannelBackgroundCorrectionCustomFunctionHandle(this, functionHandle)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            this.quantificationChannelBackgroundCorrectionCustomFunctionHandle = functionHandle;
        end
        
        function background = calculateBackgroundForDetectionImage(this, imageImporter)
            mkdir([tempdir, '/Aparecium']) 
            if strcmp(this.detectionChannelBackgroundCorrectionFunctionName, 'None')
                
            elseif strcmp(this.detectionChannelBackgroundCorrectionFunctionName, 'bgest')
                this.createBgestBackground(imageImporter, 'detection');
            elseif strcmp(this.detectionChannelBackgroundCorrectionFunctionName, 'polyfit')
                this.createPolynomialBackground(imageImporter, 'detection');
            elseif strcmp(this.detectionChannelBackgroundCorrectionFunctionName, 'Custom')
                
            end
        end
        
        function background = calculateBackgroundForQuantificationImage(this, imageImporter)
            mkdir([tempdir, '/Aparecium']) 
            if strcmp(this.quantificationChannelBackgroundCorrectionFunctionName, 'None')
                
            elseif strcmp(this.quantificationChannelBackgroundCorrectionFunctionName, 'divisionByMedian')
                
            elseif strcmp(this.quantificationChannelBackgroundCorrectionFunctionName, 'bgest')
                this.createBgestBackground(imageImporter, 'quantification');
            elseif strcmp(this.quantificationChannelBackgroundCorrectionFunctionName, 'polyfit')
                this.createPolynomialBackground(imageImporter, 'quantification');
            elseif strcmp(this.quantificationChannelBackgroundCorrectionFunctionName, 'Custom')
                
            end
        end
        
        function createPolynomialBackground(this, imageImporter, channel)
            [imageNames, folderPath, subfolderPath] = this.getImageNames(imageImporter, channel);
            for imageName = imageNames
                fullPath = [folderPath,'\', subfolderPath,'\',imageName{1}];
                image = double(imread(fullPath));
                background = this.polybgFunctionHandle(image);
                bgImagePath = [tempdir, '/Aparecium/BG_', imageName{1}];
                imwrite(background, bgImagePath);
                this.imageNameToBackgroundPathMap(imageName{1}) = bgImagePath;
            end 
        end
        
        function createBgestBackground(this, imageImporter, channel)
            % needs testing if it also works in case of multiple
            % timepoints/folders should be analyzed
            [imageNames, folderPath, subfolderPath] = this.getImageNames(imageImporter, channel);
            for imageName = imageNames
                fullPath = [folderPath,'\', subfolderPath,'\',imageName{1}];
                image = double(imread(fullPath));
                background = this.bgestFunctionHandle(image);
                bgImagePath = [tempdir, '/Aparecium/BG_', imageName{1}];
                imwrite(background, bgImagePath);
                this.imageNameToBackgroundPathMap(imageName{1}) = bgImagePath;
            end           
        end
        
        function [imageNames, folderPath, subfolderPath] = getImageNames(this, imageImporter, channel)
            if strcmp(channel, 'quantification')
                folderPath = imageImporter.mainDirectory;
                subfolderPath = imageImporter.usedDirectories{1};
                imageNames = imageImporter.secondaryNameArray{1}';             
            elseif strcmp(channel, 'detection')
                folderPath = imageImporter.mainDirectory;
                subfolderPath = imageImporter.usedDirectories{1};
                imageNames = imageImporter.nameArray{1}';  
            end
        end
        
        function background = getBackgroundForImageName(this, imageName)
            background = double(imread(this.imageNameToBackgroundPathMap(imageName)));
        end
    end
end