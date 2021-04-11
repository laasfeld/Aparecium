classdef BinaryImageCalculator < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties      
        resultStructure = [];
        ccCalculated = 0;
        criteriaMatchingccCalculated = 0;
        boundariesCalculated = 0;
        eccCalculated = 0;
        areaCalculated = 0;
        areaSTDCalculated = 0;
        diameterCalculated = 0;
        diameterSTDCalculated = 0;
        objectCountCalculated = 0;
        maxDiameterCalculated = 0;
        confluencyCalculated = 0;
        circularityCalculated = 0;
        radiusCalculated = 0;
        radiusSTDCalculated = 0;
        
        cc
        criteriaMatchingcc
        boundaries
        criteriaMatchingBoundaries
        ecc
        criteriaMatchingEcc
        thresholdFunctionHandle
        objectCount
        
    end
    
    properties(Constant)
       implementedParameters = {'area', 'areaSTD', 'objectCount', 'maxDiameter', 'maxDiameterSTD', 'eccentricity', 'eccentricitySTD', 'confluency', 'radius', 'radiusSTD', 'diameter', 'diameterSTD', 'image', 'averageSecondaryImageIntensity', 'averageNonMembraneIntensity', 'firstNonMembraneQuadrileIntensity'}
       %averagingFunctionHandles = {@BinaryImageCalculator.averageArea, @BinaryImageCalculator.averageAreaSTD, @BinaryImageCalculator.averageObjectCount, @BinaryImageCalculator.averageMaxDiameter, @BinaryImageCalculator.averageMaxDiameterSTD, @BinaryImageCalculator.averageEccentricity, @BinaryImageCalculator.averageEccentricitySTD,...
       %    @BinaryImageCalculator.averageConfluency, @BinaryImageCalculator.averageRadius, @BinaryImageCalculator.averageRadiusSTD, @BinaryImageCalculator.averageDiameter, @BinaryImageCalculator.averageDiameterSTD, @BinaryImageCalculator.stitchImage};
    end   
    
    
    properties(SetAccess = private)
        binaryImage = [];
    end
    
    methods
        function this = BinaryImageCalculator()
            
        end
        
        function handles = getCalculationFunctionHandles(this)
           handles = {@this.calculateArea, @this.calculateAreaSTD, @this.calculateObjectCount, @this.calculateMaxDiameter, @this.calculateMaxDiameterSTD, @this.calculateEccentricity, @this.calculateEccentricitySTD,...
           @this.calculateConfluency, @this.calculateRadius, @this.calculateRadiusSTD, @this.calculateDiameter, @this.calculateDiameterSTD, @this.addImage}; 
        end
        
        function setImage(this, image)
            if isequal(this.binaryImage, image)
                this.binaryImage = image;
            else
                this.ccCalculated = 0;
                this.boundariesCalculated = 0;
                this.eccentritiesCalculated = 0;
                this.areaCalculated = 0;
                this.areaSTDCalculated = 0;
                this.diameterCalculated = 0;
                this.diameterSTDCalculated = 0;
                this.objectCountCalculated = 0;
                this.maxDiameterCalculated = 0;
                this.confluencyCalculated = 0;
                this.circularityCalculated = 0;
                this.radiusCalculated = 0;
                this.radiusSTDCalculated = 0;
                this.criteriaMatchingccCalculated = 0;
            end
            
        end
        
        function calculateImageParameters(this, binaryImage, parametersToCalculate, thresholdFunctionHandle)
           this.binaryImage = binaryImage;
           this.thresholdFunctionHandle = thresholdFunctionHandle;
           for i = 1 : numel(parametersToCalculate)
               this.calculateParameter(parametersToCalculate{i});
           end
        end
        
        function calculateParameter(this, parameterName)
%             another way to implement this functionality
%             functionHandles = this.getCalculationFunctionHandles;
%             functionHandleIndex = strcmp(this.implementedParameters, parameterName)==1; % find the matching function handle index
%             functionHandle = functionHandles{functionHandleIndex}; % find the function handle
%             functionHandle(); % call the function handle
            
            switch parameterName
                case 'area'
                    this.calculateArea();
                case 'areaSTD'
                    this.calculateAreaSTD();
                case 'objectCount'
                    this.calculateObjectCount();
                case 'maxDiameter'
                    this.calculateMaxDiameter();
                case 'maxDiameterSTD'
                    this.calculateMaxDiameterSTD();               
                case 'eccentricity'
                    this.calculateEccentricity();
                case 'eccentricitySTD'
                    this.calculateEccentricitySTD();                   
                case 'confluency'
                    this.calculateConfluency();
                case 'radius'
                    this.calculateRadius();
                case 'radiusSTD'
                    this.calculateRadiusSTD();
                case 'diameter'
                    this.calculateDiameter();
                case 'diameterSTD'
                    this.calculateDiameterSTD();
                case 'image'
                    this.addImage();
            end
        end
        
        
        function addImage(this)
            this.resultStructure.image = this.binaryImage;
        end
        
        function guaranteeCC(this)
            if isequal(this.ccCalculated, 0)
               this.cc = bwconncomp(this.binaryImage);
               this.calculateCriteriaMatchingCC();
               this.ccCalculated = 1;
            end
        end
        
        function calculateCriteriaMatchingCC(this)
             if isequal(this.criteriaMatchingccCalculated, 0)
                 guaranteeEcc(this);
                 this.criteriaMatchingcc = this.cc;                
                 for i = size(this.cc.PixelIdxList,2):-1:1
                     if(objectMatchesCriteria(this.cc.PixelIdxList{i}, this.ecc(i), this.thresholdFunctionHandle) || isequal(this.thresholdFunctionHandle, @None))

                     else
                        this.criteriaMatchingcc.PixelIdxList(i) = []; 
                     end
                 end
                 this.criteriaMatchingccCalculated = 1;
             end
        end
        
        function guaranteeBoundaries(this)
            if isequal(this.boundariesCalculated, 0)
               this.boundaries = bwboundaries(this.binaryImage, 'noholes');
               this.boundariesCalculated = 1;
               this.guaranteeCriteriaMatchingBoundaries();           
            end
        end
        
        function guaranteeCriteriaMatchingBoundaries(this)
            this.guaranteeBoundaries();
            this.guaranteeCC();
            
            this.criteriaMatchingBoundaries = this.boundaries;
            for i = size(this.cc.PixelIdxList,2):-1:1
                if(objectMatchesCriteria(this.cc.PixelIdxList{i}, this.ecc(i), this.thresholdFunctionHandle) || isequal(this.thresholdFunctionHandle, @None))

                else
                   this.criteriaMatchingBoundaries(i) = []; 
                end
            end
        end
        
        function guaranteeObjectCount(this)
            this.guaranteeCC();
            if isequal(this.objectCountCalculated, 0)
               this.objectCount = size(this.criteriaMatchingcc.PixelIdxList, 2);
               this.objectCountCalculated = 1;
            end
        end
        
        function guaranteeEcc(this)
            if isequal(this.eccCalculated, 0)
               EccStruct = regionprops(logical(this.binaryImage), 'Eccentricity');               
               this.ecc = [EccStruct.Eccentricity]; 
            end            
        end
        
        function guaranteeCriteriaMatchingEcc(this)
            this.guaranteeEcc();
            this.guaranteeCC();
            this.criteriaMatchingEcc = this.ecc;
            for i = size(this.cc.PixelIdxList,2):-1:1
                if(objectMatchesCriteria(this.cc.PixelIdxList{i}, this.ecc(i), this.thresholdFunctionHandle) || isequal(this.thresholdFunctionHandle, @None))

                else
                   this.criteriaMatchingEcc(i) = []; 
                end
            end            
        end
        
        function calculateArea(this)
            this.guaranteeCC();
            this.guaranteeObjectCount();
            areas = zeros(size(this.criteriaMatchingcc.PixelIdxList, 2), 1);
            for index = 1 : size(this.criteriaMatchingcc.PixelIdxList, 2)
                areas(index) = numel(this.criteriaMatchingcc.PixelIdxList{index});
            end
            this.resultStructure.area = mean(areas);
            this.areaCalculated = 1;
        end
        
        function objectCount = getObjectCount(this)
            if isequal(this.objectCountCalculated, 0)
                this.guaranteeCC();
                this.guaranteeObjectCount();
            end
            objectCount = this.objectCount;
        end
        
        function calculateAreaSTD(this)
            this.guaranteeCC();
            if isequal(this.areaSTDCalculated, 0)
                areas = zeros(size(this.criteriaMatchingcc.PixelIdxList, 2), 1);
                for index = 1 : size(this.criteriaMatchingcc.PixelIdxList, 2)
                    areas(index) = numel(this.criteriaMatchingcc.PixelIdxList{index});
                end
                this.resultStructure.areaSTD = std(areas);
                this.areaSTDCalculated = 1;
            end
        end
        

        function calculateDiameter(this)
            this.guaranteeCC();
            if isequal(this.diameterCalculated, 0)
                if isequal(this.radiusCalculated, 1)
                    this.resultStructure.diameter = this.resultStructure.radius*2;
                else
                    diameters = zeros(size(this.criteriaMatchingcc.PixelIdxList, 2), 1);
                    for index = 1 : size(this.criteriaMatchingcc.PixelIdxList, 2)
                        diameters(index) = 2*sqrt(numel(this.criteriaMatchingcc.PixelIdxList{index})/pi);
                    end
                    this.resultStructure.diameter = mean(diameters);
                end
                this.diameterCalculated = 1;
            end
        end

        function calculateDiameterSTD(this)
            this.guaranteeCC();
            if isequal(this.diameterSTDCalculated, 0)
                if isequal(this.radiusSTDCalculated, 1)
                    this.resultStructure.diameterSTD = this.resultStructure.radiusSTD*2;
                else
                    diameters = zeros(size(this.criteriaMatchingcc.PixelIdxList, 2), 1);
                    for index = 1 : size(this.criteriaMatchingcc.PixelIdxList, 2)
                        diameters(index) = 2*sqrt(numel(this.criteriaMatchingcc.PixelIdxList{index})/pi);
                    end
                    this.resultStructure.diameterSTD = std(diameters);
                end
                this.diameterCalculated = 1;
            end
        end

        function calculateObjectCount(this)
            this.guaranteeObjectCount();
            this.resultStructure.objects = this.getObjectCount();
        end
        
        function calculateMaxDiameter(this)
            this.guaranteeBoundaries();
            this.guaranteeObjectCount()
            maxDiameter = 0;
            for i = 1 : numel(this.criteriaMatchingBoundaries)
                if size(this.criteriaMatchingBoundaries{i}, 1) < 10000
                    maxDiameter = maxDiameter + maxObjectDiameter(this.criteriaMatchingBoundaries{i});
                end
            end
            this.resultStructure.maxDiameter = maxDiameter/this.objectCount;
        end
        
        function calculateMaxDiameterSTD(this)
            this.guaranteeBoundaries();
            maxDiameter = zeros(numel(this.criteriaMatchingBoundaries), 1);
            for i = 1 : numel(numel(this.criteriaMatchingBoundaries))
                maxDiameter = maxDiameter + maxObjectDiameter(this.criteriaMatchingBoundaries{i});
            end
            this.resultStructure.maxDiameterSTD = std(maxDiameter);
        end
        
        function calculateEccentricity(this)
            this.guaranteeCriteriaMatchingEcc();
            this.resultStructure.eccentricity = mean(this.criteriaMatchingEcc);
        end
        
        function calculateEccentricitySTD(this)
            this.guaranteeCriteriaMatchingEcc();
            this.resultStructure.eccentricitySTD = std(this.criteriaMatchingEcc);
        end
        
        function calculateConfluency(this)
            this.resultStructure.confluency = 100*sum(sum(this.binaryImage))/numel(this.binaryImage);
        end
        
        function calculateRadius(this)
            radii = zeros(size(this.criteriaMatchingcc.PixelIdxList, 2), 1);
            for index = 1 : size(this.criteriaMatchingcc.PixelIdxList, 2)
                radii(index) = sqrt(size(this.criteriaMatchingcc.PixelIdxList{index}, 1)/pi);
            end
            this.resultStructure.radius = mean(radii);
        end
        
        function calculateRadiusSTD(this)
            radii = zeros(size(this.criteriaMatchingcc.PixelIdxList, 2), 1);
            for index = 1 : size(this.criteriaMatchingcc.PixelIdxList, 2)
                radii(index) = sqrt(numel(this.criteriaMatchingcc.PixelIdxList{index})/pi);
            end
            this.resultStructure.radiusSTD = std(radii);
        end      
    end
    
    methods(Static)
        
        function unit = getUnitOfParameter(parameterName)
            switch parameterName
                case 'area'
                    unit = 'um2';
                case 'areaSTD'
                    unit = 'um2';
                case 'objectCount'
                    unit = 'objects';
                case 'maxDiameter'
                    unit = 'um';
                case 'maxDiameterSTD'
                    unit = 'um';              
                case 'eccentricity'
                    unit = '';
                case 'eccentricitySTD'
                    unit = '';                 
                case 'confluency'
                    unit = '%';
                case 'radius'
                    unit = 'um';
                case 'radiusSTD'
                    unit = 'um';
                case 'diameter'
                    unit = 'um';
                case 'diameterSTD'
                    unit = 'um';
                case 'image'
                    unit = '';
                case 'averageMembraneIntensity'
                    unit = 'RIU'; % relative intensity unit
                case 'time'
                    unit = 's';
                case 'averageSecondaryImageIntensity'
                    unit = 'RIU';
                case 'averageNonMembraneIntensity'
                    unit = 'RIU';
                case 'firstNonMembraneQuadrileIntensity'
                    unit = 'RIU';
                case 'averageUnmaskedNonMembraneIntensity'
                    unit = 'RIU';
                case 'averageUnmaskedMembraneIntensity'
                    unit = 'RIU';
                case 'firstUnmaskedNonMembraneQuadrileIntensity'
                    unit = 'RIU';
                case 'averageUnmaskedSecondaryImageIntensity'
                    unit = 'RIU';
                case 'pixelCount'
                    unit = '';
                case 'intensitySTD'
                    unit = 'RIU';
            end
        end
        
        function average = averageParameter(wellData, parameterName, cameraAndLensParameters)
%             another way of implementation
%             functionHandles = BinaryImageCalculator.averagingFunctionHandles;
%             functionHandleIndex = strcmp(this.implementedParameters, parameterName)==1; % find the matching function handle index
%             functionHandle = functionHandles{functionHandleIndex}; % find the function handle
%             functionHandle(wellData); % call the function handle
%           if the the option states that the parameters of image size should be read
%           from the image then set the proper ratio to magnification and
%           pixelSize. It is assumed that all images taken from one well
%           are taken with one camera and one objective lens. Otherwise the averaging
%           of images would not make too much sense.
            if isequal(cameraAndLensParameters.fromImage, 1) % in this case maginification and pixelSize values do not correspond to actual values, but the ratio does. In current implementation there should be no difference
                                                             % but it
                                                             % could be
                                                             % reviewed
                                                             % later
                magnification = 1;
                pixelSize = wellData{1}.imageWidthMicrons/wellData{1}.imageWidthPixels;
            else
                magnification = cameraAndLensParameters.magnification;
                pixelSize = cameraAndLensParameters.pixelSize;
            end
            switch parameterName
                case 'area'
                    average = BinaryImageCalculator.averageArea(wellData)*(pixelSize/magnification)^2;
                case 'areaSTD'
                    average = BinaryImageCalculator.averageAreaSTD(wellData)*(pixelSize/magnification)^2;
                case 'objectCount'
                    average = BinaryImageCalculator.averageObjectCount(wellData);
                case 'maxDiameter'
                    average = BinaryImageCalculator.averageMaxDiameter(wellData)*(pixelSize/magnification);
                case 'maxDiameterSTD'
                    average = BinaryImageCalculator.averageMaxDiameterSTD(wellData)*(pixelSize/magnification);               
                case 'eccentricity'
                    average = BinaryImageCalculator.averageEccentricity(wellData);
                case 'eccentricitySTD'
                    average = BinaryImageCalculator.averageEccentricitySTD(wellData);                   
                case 'confluency'
                    average = BinaryImageCalculator.averageConfluency(wellData);
                case 'radius'
                    average = BinaryImageCalculator.averageRadius(wellData)*(pixelSize/magnification);
                case 'radiusSTD'
                    average = BinaryImageCalculator.averageRadiusSTD(wellData)*(pixelSize/magnification);
                case 'diameter'
                    average = BinaryImageCalculator.averageDiameter(wellData)*(pixelSize/magnification);
                case 'diameterSTD'
                    average = BinaryImageCalculator.averageDiameterSTD(wellData)*(pixelSize/magnification);
                case 'image'
                    average = BinaryImageCalculator.stitchImage(wellData);
                case 'averageMembraneIntensity'
                    average = BinaryImageCalculator.averageMembraneIntensity(wellData);
                case 'time'
                    average = BinaryImageCalculator.averageImageTime(wellData);
                case 'averageSecondaryImageIntensity'
                    average = BinaryImageCalculator.averageSecondaryImageIntensity(wellData);
                case 'averageNonMembraneIntensity'
                    average = BinaryImageCalculator.averageNonMembraneIntensity(wellData);
                case 'firstNonMembraneQuadrileIntensity'
                    average = BinaryImageCalculator.firstNonMembraneQuadrileIntensity(wellData);
                case 'averageUnmaskedNonMembraneIntensity'
                    average = BinaryImageCalculator.averageUnmaskedNonMembraneIntensity(wellData);
                case 'averageUnmaskedMembraneIntensity'
                    average = BinaryImageCalculator.averageUnmaskedMembraneIntensity(wellData);
                case 'firstUnmaskedNonMembraneQuadrileIntensity'
                    average = BinaryImageCalculator.averageUnmaskedNonMembraneQuadrileIntensity(wellData);
                case 'averageUnmaskedSecondaryImageIntensity'
                    average = BinaryImageCalculator.averageUnmaskedSecondaryImageIntensity(wellData);
                case 'pixelCount'
                    average = BinaryImageCalculator.averagePixelCount(wellData);
                case 'intensitySTD'
                    average = BinaryImageCalculator.averageIntensitySTD(wellData);
            end
        end        
        
        function average = averageIntensitySTD(resultStructures)
            % pooled standard deviation will be found
            means = zeros(numel(resultStructures), 1);
            STDs = zeros(numel(resultStructures), 1);
            weights = zeros(numel(resultStructures), 1);
            for imageIndex = 1 : numel(resultStructures)
                means(imageIndex) = resultStructures{imageIndex}.averageMembraneIntensity;
                weights(imageIndex) = resultStructures{imageIndex}.membranePixelCount;
                STDs(imageIndex) = resultStructures{imageIndex}.membraneIntensityStandardDeviation;
            end
            
            average = pooledSTD(weights, means, STDs);
        end
        
        function average = averagePixelCount(resultStructures)
           pixelCount = 0;
           for imageIndex = 1 : numel(resultStructures)
              pixelCount = pixelCount + resultStructures{imageIndex}.membranePixelCount; 
           end
           average = pixelCount/numel(resultStructures);
        end
        
        function average = averageArea(resultStructures)
            area = 0;
            objects = BinaryImageCalculator.averageObjectCount(resultStructures)*numel(resultStructures);
            for imageIndex = 1 : numel(resultStructures)
                area = area + resultStructures{imageIndex}.area * resultStructures{imageIndex}.objects;
            end
            average = area/objects;
        end
        
        function average = averageAreaSTD(resultStructures)
            % pooled standard deviation will be found
            means = zeros(numel(resultStructures), 1);
            STDs = zeros(numel(resultStructures), 1);
            weights = zeros(numel(resultStructures), 1);
            for imageIndex = 1 : numel(resultStructures)
                means(imageIndex) = resultStructures{imageIndex}.area;
                weights(imageIndex) = resultStructures{imageIndex}.objects;
                STDs(imageIndex) = resultStructures{imageIndex}.areaSTD;
            end
            
            average = pooledSTD(weights, means, STDs);
        end
        
        function average = averageObjectCount(resultStructures)
            objects = 0;
            for imageIndex = 1 : numel(resultStructures)
                objects = objects + resultStructures{imageIndex}.objects;
            end
            average = objects/numel(resultStructures);
        end
        
        function average = averageMaxDiameter(resultStructures)
            maxDiameter = 0;
            objects = BinaryImageCalculator.averageObjectCount(resultStructures)*numel(resultStructures);
            for imageIndex = 1 : numel(resultStructures)
                maxDiameter = maxDiameter + resultStructures{imageIndex}.maxDiameter * resultStructures{imageIndex}.objects;
            end
            average = maxDiameter/objects;
        end
        
        function average = averageMaxDiameterSTD(resultStructures)
            means = zeros(numel(resultStructures), 1);
            STDs = zeros(numel(resultStructures), 1);
            weights = zeros(numel(resultStructures), 1);
            for imageIndex = 1 : numel(resultStructures)
                means(imageIndex) = resultStructures{imageIndex}.maxDiameter;
                weights(imageIndex) = resultStructures{imageIndex}.objects;
                STDs(imageIndex) = resultStructures{imageIndex}.maxDiameterSTD;
            end
            
            average = pooledSTD(weights, means, STDs);
        end
        
        function average = averageEccentricity(resultStructures)
            eccentricity = 0;
            objects = BinaryImageCalculator.averageObjectCount(resultStructures)*numel(resultStructures);
            for imageIndex = 1 : numel(resultStructures)
                eccentricity = eccentricity + resultStructures{imageIndex}.eccentricity * resultStructures{imageIndex}.objects;
            end
            average = eccentricity/objects;
        end
        
        function average = averageEccentricitySTD(resultStructures)
            means = zeros(numel(resultStructures), 1);
            STDs = zeros(numel(resultStructures), 1);
            weights = zeros(numel(resultStructures), 1);
            for imageIndex = 1 : numel(resultStructures)
                means(imageIndex) = resultStructures{imageIndex}.eccentricity;
                weights(imageIndex) = resultStructures{imageIndex}.objects;
                STDs(imageIndex) = resultStructures{imageIndex}.eccentricitySTD;
            end
            
            average = pooledSTD(weights, means, STDs);
        end
        
        function average = averageConfluency(resultStructures)
            confluency = 0;
            for imageIndex = 1 : numel(resultStructures)
                confluency = confluency + resultStructures{imageIndex}.confluency;
            end
            average = confluency/numel(resultStructures);
        end
        
        function average = averageRadius(resultStructures)
            radius = 0;
            objects = BinaryImageCalculator.averageObjectCount(resultStructures)*numel(resultStructures);
            for imageIndex = 1 : numel(resultStructures)
                radius = radius + resultStructures{imageIndex}.radius * resultStructures{imageIndex}.objects;
            end
            average = radius/objects;
        end
        
        function average = averageRadiusSTD(resultStructures)
            means = zeros(numel(resultStructures), 1);
            STDs = zeros(numel(resultStructures), 1);
            weights = zeros(numel(resultStructures), 1);
            for imageIndex = 1 : numel(resultStructures)
                means(imageIndex) = resultStructures{imageIndex}.radius;
                weights(imageIndex) = resultStructures{imageIndex}.objects;
                STDs(imageIndex) = resultStructures{imageIndex}.radiusSTD;
            end
            
            average = pooledSTD(weights, means, STDs);
        end
        
        function average = averageDiameter(resultStructures)
            diameter = 0;
            objects = BinaryImageCalculator.averageObjectCount(resultStructures)*numel(resultStructures);
            for imageIndex = 1 : numel(resultStructures)
                 diameter =  diameter + resultStructures{imageIndex}. diameter * resultStructures{imageIndex}.objects;
            end
            average =  diameter/objects;
        end
        
        function average = averageDiameterSTD(resultStructures)
            means = zeros(numel(resultStructures), 1);
            STDs = zeros(numel(resultStructures), 1);
            weights = zeros(numel(resultStructures), 1);
            for imageIndex = 1 : numel(resultStructures)
                means(imageIndex) = resultStructures{imageIndex}.diameter;
                weights(imageIndex) = resultStructures{imageIndex}.objects;
                STDs(imageIndex) = resultStructures{imageIndex}.diameterSTD;
            end
            
            average = pooledSTD(weights, means, STDs);
        end
        
        function image = stitchImage(resultStructures)
            image = resultStructures{1}.image;
            for imageIndex = 2 : numel(resultStructures)
                image = cat(2, image, resultStructures{imageIndex}.image);
            end         
        end
        
        function average = averageMembraneIntensity(resultStructures)
            intensity = 0;
            totalPixels = BinaryImageCalculator.averageConfluency(resultStructures)*numel(resultStructures);
            for imageIndex = 1 : numel(resultStructures)
                 intensity = intensity + resultStructures{imageIndex}.averageMembraneIntensity * resultStructures{imageIndex}.confluency;
            end
            average =  intensity/totalPixels;
        end
        
        function average = averageNonMembraneIntensity(resultStructures)
            intensity = 0;
            for imageIndex = 1 : numel(resultStructures)
                 intensity = intensity + resultStructures{imageIndex}.averageNonMembraneIntensity;
            end
            average =  intensity/numel(resultStructures);
        end
        
        function average = averageSecondaryImageIntensity(resultStructures)
            intensity = 0;
            %totalPixels = 904*1224;% defenetly bind this parameter to the actual image
            for imageIndex = 1 : numel(resultStructures)
                 intensity = intensity + resultStructures{imageIndex}.averageSecondaryImageIntensity;
            end
            average =  intensity/numel(resultStructures);
        end
        
        function average = averageImageTime(resultStructures)
            time = 0;
            counter = 0;
            for imageIndex = 1 : numel(resultStructures)
                 try
                     time = time + resultStructures{imageIndex}.imageTime;
                     counter = counter + 1; % the counter must be after the time since if it fails then counter must inremented
                 catch
                     
                 end
            end
            average = time/counter;
        end
        
        function average = firstNonMembraneQuadrileIntensity(resultStructures)
            intensity = 0;
            for imageIndex = 1 : numel(resultStructures)
                 intensity = intensity + resultStructures{imageIndex}.firstNonMembraneQuadrileIntensity;
            end
            average =  intensity/numel(resultStructures);
        end
        
        function average = averageUnmaskedNonMembraneIntensity(resultStructures)
            intensity = 0;
            for imageIndex = 1 : numel(resultStructures)
                intensity = intensity + resultStructures{imageIndex}.averageUnmaskedNonMembraneIntensity;
            end
            average = intensity/numel(resultStructures);
        end
        
        function average = averageUnmaskedMembraneIntensity(resultStructures)
            intensity = 0;
            for imageIndex = 1 : numel(resultStructures)
                intensity = intensity + resultStructures{imageIndex}.averageUnmaskedMembraneIntensity;
            end
            average = intensity/numel(resultStructures);
        end
        
        function average = averageUnmaskedNonMembraneQuadrileIntensity(resultStructures)
            intensity = 0;
            for imageIndex = 1 : numel(resultStructures)
                intensity = intensity + resultStructures{imageIndex}.firstUnmaskedNonMembraneQuadrileIntensity;
            end
            average = intensity/numel(resultStructures);
        end
        
        function average = averageUnmaskedSecondaryImageIntensity(resultStructures)
            intensity = 0;
            for imageIndex = 1 : numel(resultStructures)
                intensity = intensity + resultStructures{imageIndex}.averageUnmaskedSecondaryImageIntensity;
            end
            average = intensity/numel(resultStructures);
        end
            
    end
end