classdef ImageProcessingParameters < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        imageSegmentationMode = 'Full image';
        
        
        mergeMode = 'on';
        
        %ICSE parameters
        tileDim = 30;
        lambda = 5;
        minSizeMSER = 30;
        maxSizeMSER = 4000;
        maxVariation = 1;
        maxEcc = 0.7;
        minSizeSplit = 30;
        maxSizeSplit = 1000;
        
        %Membrane analysis parameters
        upperThreshold = 0.635549388680719;
        lowerThreshold = 0.481008216611135;
        preDilateCutoff = 1;
        postDilateCutoff = 1;
        extraEdgeThreshold = 0.0486227079926121;
        
        
        useParallelComputing = 'on';
        characteristicsInUse = {'area', 'areaSTD', 'diameter', 'diameterSTD', 'cellCount'};
        
        Full = 'Full image';
        FastFull = 'Segmented full image';
        Fast = 'Image center';
        FromBinary = 'From binary image';
        Slopes = 'Slopes';
        
        FromBinaryAndMask = 'From binary and mask image';
        
        % Enums for choosing the segmentation type
        IlastikModel = 'IlastikModel';
        SobelModel = 'SobelModel';
        KerasModel = 'KerasModel';
        
        detectionModel = 'SobelModel';
        membraneLabelIndex = 3;
        ilastikModelPath = [];
        kerasModelPath = [];
        
        automaticallySaveMidasFile = 'on';
        midasFileSaveFormat = 'complete';
        
        autoSaveBinaryFiles = 'on';
        autoSaveMasks = 'off';
        
        useMorphologicalOperations = true;
        focusOrMaxProjection = 'max projection' % alternative 'focus'
        
        pixelShiftHorizontal = 0;
        pixelShiftVertical = 0;
        
        % Parameters related to image name filtering
        detectionChannelRegex = 'Bright Field';
        quantificationChannelRegex = 'RFP';
        expectZstack = true;
        
        % For MembraneTools - 'Slopes' detects from linear regression
        % slopes while 'Focus' detects from focus image only.
        detectionFocusOrSlopes = 'Slopes';
        
        membraneToolsBackgroundCorrection = [];
        
        subtractBackground = true;
        
        % Keras model preprocessing and post processing parameters.
        binarisationThreshold = 0.5;
        normalizationMin = 0;
        normalizationMax = 1;
    end
    
    methods
        
        function this = ImageProcessingParameters()
            
        end
        
        function setPixelShiftHorizontal(this, pixelShift)
            this.pixelShiftHorizontal = pixelShift;
        end
        
        function setPixelShiftVertical(this, pixelShift)
            this.pixelShiftVertical = pixelShift;
        end
        
        function pixelShift = getPixelShiftHorizontal(this)
            pixelShift = this.pixelShiftHorizontal;
        end
        
        function pixelShift = getPixelShiftVertical(this)
            pixelShift = this.pixelShiftVertical;
        end
        
        function setParallelComputing(this, onOrOff)
            this.useParallelComputing = onOrOff;
        end
        
        function setMergeMode(this, mode)
           this.mergeMode = mode; 
        end
        
        function setTileDim(this, tileDim)
            this.tileDim = tileDim;
        end
        
        function tileDim = getTileDim(this)
            tileDim = this.tileDim;
        end
        
        function setLambda(this, lambda)
            this.lambda = lambda;
        end
        
        function lambda = getLambda(this)
           lambda = this.lambda; 
        end
        
        function setMinSizeMSER(this, minSizeMSER)
            this.minSizeMSER = minSizeMSER;
        end
        
        function minSizeMSER = getMinSizeMSER(this)
            minSizeMSER = this.minSizeMSER;
        end
        
        function setMaxSizeMSER(this, maxSizeMSER)
            this.maxSizeMSER = maxSizeMSER;
        end
        
        function maxSizeMSER = getMaxSizeMSER(this)
           maxSizeMSER = this.maxSizeMSER; 
        end
        
        function setMinSizeSplit(this, minSizeSplit)
            this.minSizeSplit = minSizeSplit;
        end
        
        function minSizeSplit = getMinSizeSplit(this)
           minSizeSplit = this.minSizeSplit; 
        end
        
        function setMaxSizeSplit(this, maxSizeSplit)
            this.maxSizeSplit = maxSizeSplit;
        end
        
        function maxSizeSplit = getMaxSizeSplit(this)
           maxSizeSplit = this.maxSizeSplit; 
        end
        
        function setMaxEcc(this, maxEcc)
            this.maxEcc = maxEcc;
        end
        
        function maxEcc = getMaxEcc(this)
           maxEcc = this.maxEcc; 
        end
        
        function setMaxVariation(this, maxVariation)
           this.maxVariation = maxVariation; 
        end
        
        function maxVariation = getMaxVariation(this)
           maxVariation = this.maxVariation; 
        end
        
        function mode = getNumericalMergeMode(this)
            switch this.mergeMode
                case 'on'
                    mode = 1;
                case 'off'
                    mode = 0;
                otherwise
                    mode = 1;
            end                   
        end
        
        function setFullImageMode(this)
            this.imageSegmentationMode = this.Full;
        end
        
        function setSegmentedFullImageMode(this)
            this.imageSegmentationMode = this.FastFull;
        end
        
        function setImageCenterMode(this)
            this.imageSegmentationMode = this.Fast;
        end
        
        function setFromBinaryMode(this)
           this.imageSegmentationMode = this.FromBinary; 
        end
        
        function answer = isInFullImageMode(this)
           answer = strcmp(this.imageSegmentationMode, 'Full image');  
        end
        
        function answer = isInSegmentedFullImageMode(this)
           answer = strcmp(this.imageSegmentationMode, 'Segmented full image');  
        end
        
        function answer = isInImageCenterMode(this)
           answer = strcmp(this.imageSegmentationMode, 'Image center');  
        end
        
        function mode = getMode(this)
           mode = this.imageSegmentationMode;
        end
        
        function setAutoSaveMidas(this, onOrOff)
           this.automaticallySaveMidasFile = onOrOff; 
        end
        
        function autoSave = getAutoSaveMidas(this)
            autoSave = this.automaticallySaveMidasFile;
        end
        
        function setMidasFileSaveFormat(this, saveFormat)
           this.midasFileSaveFormat = saveFormat; 
        end
        
        function saveFormat = getMidasFileSaveFormat(this)
           saveFormat = this.midasFileSaveFormat;
        end
        
        function setAutoSaveBinaryFiles(this, onOrOff)
           this.autoSaveBinaryFiles = onOrOff;
        end
        
        function autoSave = getAutoSaveBinaryFiles(this)
            autoSave = this.autoSaveBinaryFiles;
        end
        
        function setUpperThreshold(this, upperThreshold)
           this.upperThreshold = upperThreshold;
        end
        
        function upperThreshold = getUpperThreshold(this)
           upperThreshold = this.upperThreshold; 
        end
        
        function setLowerThreshold(this, lowerThreshold)
           this.lowerThreshold = lowerThreshold; 
        end
        
        function lowerThreshold = getLowerThreshold(this)
           lowerThreshold = this.lowerThreshold; 
        end
        
        function setPreDilateCutoff(this, preDilateCutoff)
           this.preDilateCutoff = preDilateCutoff; 
        end
        
        function preDilateCutoff = getPreDilateCutoff(this)
           preDilateCutoff = this.preDilateCutoff; 
        end
        
        function setPostDilateCutoff(this, postDilateCutoff)
           this.postDilateCutoff = postDilateCutoff; 
        end
        
        function postDilateCutoff = getPostDilateCutoff(this)
           postDilateCutoff = this.postDilateCutoff; 
        end
        
        function setExtraEdgeThreshold(this, threshold)
           this.extraEdgeThreshold = threshold; 
        end
        
        function threshold = getExtraEdgeThreshold(this)
           threshold = this.extraEdgeThreshold; 
        end
        
        function setAutoSaveMasks(this, autoSave)
           this.autoSaveMasks = autoSave;
        end
        
        function autoSaveMasks = getAutoSaveMasks(this)
           autoSaveMasks = this.autoSaveMasks; 
        end
        
        function setUseMorphologicalOperations(this, useOperations)
            this.useMorphologicalOperations = useOperations; % true or false
        end
        
        function useMorphologicalOperations = getUseMorphologicalOperations(this)
            useMorphologicalOperations = this.useMorphologicalOperations;
        end
        
        function setFocusOrMaxProjection(this, focusOrMaxProjection)
            this.focusOrMaxProjection = focusOrMaxProjection;
        end
        
        function focusOrMaxProjection = getFocusOrMaxProjection(this)
            focusOrMaxProjection = this.focusOrMaxProjection;
        end
        
        function setDetectionChannelRegex(this, detectionChannelRegex)
            this.detectionChannelRegex = detectionChannelRegex;
        end
        
        function detectionChannelRegex = getDetectionChannelRegex(this)
            detectionChannelRegex = this.detectionChannelRegex;
        end
        
        function setQuantificationChannelRegex(this, quantificationChannelRegex)
            this.quantificationChannelRegex = quantificationChannelRegex;
        end
        
        function quantificationChannelRegex = getQuantificationChannelRegex(this)
            quantificationChannelRegex = this.quantificationChannelRegex;
        end
        
        function setExpectZstack(this, expectZstack)
            this.expectZstack = expectZstack;
        end
        
        function expectZstack = getExpectZstack(this)
            expectZstack = this.expectZstack;
        end
        
        function setDetectionFocusOrSlopes(this, detectionFocusOrSlopes)
            this.detectionFocusOrSlopes = detectionFocusOrSlopes;
        end
        
        function detectionFocusOrSlopes = getDetectionFocusOrSlopes(this)
            detectionFocusOrSlopes = this.detectionFocusOrSlopes;
        end
        
        function setMembraneToolsBackgroundCorrection(this, BGHandle)
            this.membraneToolsBackgroundCorrection = BGHandle; 
        end
        
        function setSubtractBackground(this, subtractBackground)
            this.subtractBackground = subtractBackground;
        end
        
        function subtractBackground = getSubtractBackground(this)
            subtractBackground = this.subtractBackground;
        end
        
        function setBinarisationThreshold(this, binarisationThreshold)
            this.binarisationThreshold = binarisationThreshold;
        end
        
        function binarisationThreshold = getBinarisationThreshold(this)
            binarisationThreshold = this.binarisationThreshold;
        end
        
        function setNormalizationMin(this, normalizationMin)
            this.normalizationMin = normalizationMin;
        end
        
        function normalizationMin = getNormalizationMin(this)
            normalizationMin = this.normalizationMin;
        end
        
        function setNormalizationMax(this, normalizationMax)
            this.normalizationMax = normalizationMax;
        end
        
        function normalizationMax = getNormalizationMax(this)
            normalizationMax = this.normalizationMax;
        end

    end   
end