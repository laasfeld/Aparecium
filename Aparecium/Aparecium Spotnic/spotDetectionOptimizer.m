classdef spotDetectionOptimizer < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        specificFolders = [];
        NSFolders = [];
        mainFolder = [];
        lowerLimit = 0;
        upperLimit = 10000;
        
        %calculated parameters
        usedThresholds = [];
        foundRatios = [];
        foundSpecificSpots = [];
        foundNSSpots = [];
        specificSpotSTD = [];
        NSSpotSTD = [];
        ZPrime = [];
        foundSpecificSpotMatrix = [];
        foundSpecificSpotSTDMatrix = [];
        folderNameMatrix = [];
        imageSpotCounts = [];
    end
    
    methods
        
        function this = spotDetectionOptimizer(mainFolder, specificFolders, NSFolders)
           this.specificFolders = specificFolders;
           this.NSFolders = NSFolders;
           this.mainFolder = mainFolder;
        end
        
        function result = calculateRatio(this, threshold)
            disp(['threshold: ', num2str(threshold)]);
            [specificSpots, stdSpecific,spots,spotSTD, folderNames, imageSpots] = this.calculateAverageSpots(this.mainFolder, this.specificFolders, threshold);
            [NSSpots, stdNS] = this.calculateAverageSpots(this.mainFolder, this.NSFolders, threshold);
            result = -specificSpots/NSSpots; % negative because minimum is searched
            this.usedThresholds = [this.usedThresholds, threshold];
            this.foundSpecificSpots = [this.foundSpecificSpots, specificSpots];
            this.foundNSSpots = [this.foundNSSpots, NSSpots];
            this.foundRatios = [this.foundRatios, -result];
            this.NSSpotSTD = [this.NSSpotSTD, stdNS];
            this.specificSpotSTD = [this.specificSpotSTD, stdSpecific];
            this.ZPrime = [this.ZPrime, (1-3*(stdSpecific + stdNS)/(specificSpots - NSSpots))];
            this.foundSpecificSpotMatrix = [this.foundSpecificSpotMatrix; spots];
            this.foundSpecificSpotSTDMatrix = [this.foundSpecificSpotSTDMatrix; spotSTD];
            this.folderNameMatrix = [this.folderNameMatrix; folderNames];
            this.imageSpotCounts = imageSpots;
            
        end
        
        function [result, stdev, dirMean, dirSTD, folderNames, dirSpots] = calculateAverageSpots(this, mainFolderPath, subFolderNames, threshold)
            spots = zeros(0,0);
            folderNames = cell(0,0);
            dirMean = zeros(1,numel(subFolderNames));
            dirSTD = zeros(1,numel(subFolderNames));
            dirSpots = cell(1,numel(subFolderNames));
            for dirIndex = 1 : numel(subFolderNames)  
                result = spotDetection(threshold, [mainFolderPath,'/', subFolderNames{dirIndex}]);
                spots = [spots; cell2mat(result(:,2))];
                dirSpots{dirIndex} = cell2mat(result(:,2));
                dirMean(dirIndex) = mean(cell2mat(result(:,2)));
                dirSTD(dirIndex) = std(cell2mat(result(:,2)));
                folderNames = [folderNames, subFolderNames{dirIndex}];
            end
            result = mean(spots);
            stdev = std(spots);
        end
    end
    
end

