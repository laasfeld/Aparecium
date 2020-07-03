%% Copyright (C) 2016 Tõnis Laasfeld
%   
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
% 02110-1301, USA.

% This class provides methods for analyzyng bright-field images and binary
% images for cell detection and measurement.

classdef ImageAnalyzer < handle

    
    % TODO - parallel computation of images is not as effective as it could
    % be. Parfor should be used on all images not just images from one
    % well.
    properties
        midasTableController % inner midasTableController
        imageProcessingParameters % ImageProscessingParameters object
        imageImporter % ImageImporter object that imports images
        experiment % ApareciumExperimentInput object
        results % cell array, each cell holds structure returned by StandardizeData function
        experimentDataStructure % experiment data structure type structure
        dataStructure % cell array holding experiment data structure type structures
        fullDataStructure % experiment data structure type structure that hold data for automatically saving complete MIDAS file
        analysisStartTime % holds the time value when analysis started
        feedbackHandle % handle for printing out information about how the analysis is going
        imagesLeftToAnalyse % hold the number of images that are still not analyzed
        imagesAnalysed % holds the number of images that are already analyzed
        totalTimeElapsed = 0; % hold the time in seconds that has elapsed since the start of analysis
        midasFileName = ''; % name of the MIDAS file name that will be automatically created
        handles; % holds the handles provided by ICSETools
        experimentStartTime = 0; % holds the time value when experiment started
        measurementTimeMode = 'Cycle average'; % holds the measurement Time Mode which shows how time values are handeled, standard is 'Cycle average'
        referenceTimeMode = 'First point'; % holds the mode of how the 0 time point is defined
        timeShift = 0; % hold the value of timeShift
        isAnalysisComplete = 0; % 0 is analysis is not yet completed, 1 if the analysis is completed
        figureHandles; % handles to the two figures present in ICSETools
        clearBinaryImages = 1; % 0 is binary images are cleared in the middle of image analysis, it helps to save time
        cameraAndLensParameters; % Holds information about magnification of the lens and pixel size of the CCD camera
        observationImageData; % Hold image data when analysis is performed in the observation mode
        useHandles = 1; % 1 if imageAnalyzer can use handles for graphical output, 0 if it can´t
        thresholdFunctionHandle = [];
        ICSEOrMembrane = 'Membrane';
        observationMode = 0;
        parametersToCalculate = [];
    end
    
    methods
        
        function this = ImageAnalyser(this)
            
        end
        
        function midasFileName = getMidasFileName(this)
            midasFileName = this.midasFileName;
        end
        
        function setMidasFileName(this, midasFileName)
            this.midasFileName = midasFileName; 
        end
        
        function setImageImporter(this, imageImporter)
            this.imageImporter = imageImporter;
        end
        
        function setCameraAndLensParameters(this, cameraAndLensParameters)
           this.cameraAndLensParameters = cameraAndLensParameters; 
        end
        
        function setAnalysisFeedbackHandle(this, textHandle)
            this.feedbackHandle = textHandle;
        end
        
        function setApareciumExperimentInput(this, experiment)
            this.experiment = experiment;
        end
        
        function setImageProcessingParameters(this, imageProcessingParameters)
            this.imageProcessingParameters = imageProcessingParameters;
        end
        
        function setParametersToCalculate(this, parametersToCalculate)
            this.parametersToCalculate = parametersToCalculate;
        end
        
        function parametersToCalculate = getParametersToCalculate(this)
            parametersToCalculate = this.parametersToCalculate;
        end
        
        function startObservationMode(this)
           this.observationMode = 1;
           this.results = [];
           this.analysisStartTime = tic; % starting the clock
           this.imagesLeftToAnalyse = 96; % Currently hardcoded value representing 4 images per well for 24 well plate. This should be changed in the future
           this.imagesAnalysed = 0; 
           switch this.imageProcessingParameters.useParallelComputing
               case 'on'
                    if exist('matlabpool')
                        if matlabpool('size') == 0 % means that matlabpool has not been started yet
                            matlabpool
                        end
                    else
                        if isempty(gcp('nocreate')) % means that matlabpool has not been started yet
                            parpool
                        end 
                    end
           end    
        end
        
        function stopObservationMode(this)
           
            folder = 1;          
            ID = this.fixWellID(this.imageImporter.getAllImportedWellID()); % since the images may come in random order in case of observation then the IDs need to be reorganized so that it would be same as if it had been already completed measurement
            inputArray.imageData = this.fixImageData(this.observationImageData, ID); % since the images may come in random order in case of observation then the image data needs to be reorganized so that it would be same as if it had been already completed measurement
            inputArray.ID = ID;
            
            this.results{folder} = ImageAnalyzer.standardizeData(inputArray, this.cameraAndLensParameters, this.ICSEOrMembrane, this.parametersToCalculate);
            this.dataStructure{folder} = this.generateSingleCycleExperimentDataStructure(folder); % generate a data structure for the folder. In observation mode only one folder can be analyzed so folder is a constant with the value of one in this context
            if strcmp(this.imageProcessingParameters.getAutoSaveMidas(), 'on') && strcmp(this.imageProcessingParameters.getMidasFileSaveFormat(), 'separate') % check if MIDAS file should be written
                this.saveSeparateMidasFile(folder);
            end
            %% close the matlabpool
            switch this.imageProcessingParameters.useParallelComputing
                case 'on'
                    if exist('matlabpool')
                        if matlabpool('size') > 0
                            matlabpool close
                        end
                    else
                        if parpool('size') > 0
                            delete(gcp('nocreate'))
                        end
                    end
            end
            %%
            %% clean up
            try
                if ~isempty(this.feedbackHandle)
                    set(this.feedbackHandle, 'String', 'Analysis completed');
                end

            catch
            end
            %%
            this.fullDataStructure = this.generateFullDataStructure(); % generate one MIDAS file with all the data
            if strcmp(this.imageProcessingParameters.getAutoSaveMidas(), 'on') && strcmp(this.imageProcessingParameters.getMidasFileSaveFormat(), 'complete') % check if MIDAS file should be written
                    this.saveCompleteMidasFile();
            end
            this.isAnalysisComplete = 1; % confirm that analysis is completed
            this.observationMode = 0;
        end
        
        function fixedImageData = fixImageData(this, originalImageData, wellID)
            imageNames = cell(0, 0);
            wellIndices = [];
            imageIndices = [];

            for wellIndex = 1 : numel(originalImageData)
               for imageIndex = 1 : numel(originalImageData{wellIndex})
                   if isfield(originalImageData{wellIndex}{imageIndex}, 'imageName') % check if the image actually was analyzed 
                       %% not time critical, warnings can be ignored for
                       %% now
                       imageNames{end+1} = originalImageData{wellIndex}{imageIndex}.imageName; % save image names in one array
                       wellIndices(end+1) = wellIndex; % save well indices where that image name was found to another array
                       imageIndices(end+1) = imageIndex; % save the image indices where that image name was found to another array
                   end
               end
            end
            isUnique = zeros(numel(imageNames), 1);

            uniqueImageNames = cell(0, 0);
            %% this for loop is basically a unique function that works on
            %% cell arrays, maybe it could be simplified somehow with the
            %% unique function
            for imageIndex = 1 : numel(imageNames) % check all images
                breakLoop = 0;
                for uniqueImageIndex = 1 : numel(uniqueImageNames)
                   if strcmp(uniqueImageNames{uniqueImageIndex}, imageNames{imageIndex})
                       breakLoop = 1; % This image is already present in uniqueImageNames, nothing more should be done with this image
                       break;
                   end
                end
                if isequal(breakLoop, 0) % This image is unique so far, add it to the list
                   uniqueImageNames{end+1} = imageNames{imageIndex}; % adding to the list
                   isUnique(imageIndex) = 1; % recording that this image was unique
                end
            end
            %% lets delete all images and their indices that were not
            %% unique, they are no loger needed. Start from array end to
            %% array start because in that case clearing one element of the
            %% array wont mess up indexing
            for imageIndex = numel(imageNames) : -1 : 1
               if isequal(isUnique(imageIndex), 0)
                    wellIndices(imageIndex) = [];
                    imageIndices(imageIndex) = [];
               end
            end
            
            for wellIndex = 1 : numel(wellID)
                containsImagesCell = strfind(uniqueImageNames, wellID{wellIndex}); % find the image names that contain the name of this well
                containsImages = [];
                for index = 1 : numel(containsImagesCell)
                    if ~isequal(containsImagesCell{index}, []) % if strfind did not return [] then it must contain an image 
                        containsImages(end+1) = index;  
                    end
                end
                %% rearrange the data based on the previous functions
                currentWellIndices = wellIndices(containsImages);
                currentImageIndices = imageIndices(containsImages);
                for imageIndex = 1 : numel(currentWellIndices)
                    fixedImageData{wellIndex}{imageIndex} = originalImageData{currentWellIndices(imageIndex)}{currentImageIndices(imageIndex)};
                end
                %%
            end
        end
        
        function finalFixedWellID = fixWellID(this, originalWellID)
            newList = cell(0, 0);
            fixedWellID = cell(0, 0);
            %% find all the nonempty elements
            for index = 1 : numel(originalWellID)
               if ~isempty(originalWellID{index})
                   newList = [newList, originalWellID(index)]; 
               end
            end
            %% make the array ready to be processed by unique function
            for index = 1 : numel(newList)
               fixedWellID = [fixedWellID; newList{index}]; 
            end
            %% find only the unique wells, unique will sort them too
            finalFixedWellID = unique(fixedWellID);
        end
        
        function observeNewImages(this)
            folder = 1; % only one folder can be analyzed using observation mode so this is constant here
            try
                if ~isempty(this.feedbackHandle)
                    set(this.feedbackHandle, 'String', 'Starting analysis'); 
                end
            catch
                % catch an error if this.feedbackHandle has not been
                % initialized, do nothing since this is not critical
                % TODO- consider making this call independent of try catch
                % block
            end
            
            directoryPath = this.imageImporter.getFilePathOfDirectoryWithIndex(folder); % get the path to images          
            imageData = this.analyzeOneTimepoint(directoryPath, folder); % analyze the images
            this.observationImageData = [this.observationImageData; imageData]; % concatenate data to previous runs of this function
            this.saveBinaryImages(folder, imageData); % save any binary images that were created
            if this.clearBinaryImages % check if binary images are not neede later
                % clear all the images
                for well = 1 : length(imageData)
                   for image = 1 : length(imageData{well})
                       this.observationImageData{well}{image}.image = [];                   
                   end
                end
            end
            ID = this.fixWellID(this.imageImporter.getAllImportedWellID());
            fixedImageData = this.fixImageData(this.observationImageData, ID);
            numberOfImagesAnalyzed = 0;
            for wellIndex = 1 : numel(fixedImageData)
                for imageIndex = 1 : numel(fixedImageData{wellIndex})
                    numberOfImagesAnalyzed = numberOfImagesAnalyzed + 1;
                end
            end
            clc
            this.imagesLeftToAnalyse = 96 - numberOfImagesAnalyzed;
        end
        
        function startAnalysis(this)
            this.results = []; 
            this.analysisStartTime = tic;
            
            wellID = this.imageImporter.getWellID();
            wellID = wellID{1};
            
            this.imagesLeftToAnalyse = this.imageImporter.getNumberOfUsedDirectories() * numel(wellID) * 4;
            this.imagesAnalysed = 0;
 %           try
                switch this.imageProcessingParameters.useParallelComputing
                    case 'on'
                        if(exist('matlabpool'))
                            if matlabpool('size') == 0
                                matlabpool
                            end
                        else
                            if isempty(gcp('nocreate'))
                                parpool
                            end
                        end
                end
                for folder = 1 : this.imageImporter.getNumberOfUsedDirectories()
                    try
                        if ~isempty(this.feedbackHandle)
                            set(this.feedbackHandle, 'String', 'Starting analysis');
                        end
                    catch
                        
                    end
                    directoryPath = this.imageImporter.getFilePathOfDirectoryWithIndex(folder);
                    imageData = this.analyzeOneTimepoint(directoryPath, folder);
                    this.saveBinaryImages(folder, imageData);
                    if this.clearBinaryImages
                        for well = 1 : length(imageData)
                           for image = 1 : length(imageData{well})
                               imageData{well}{image}.image = [];                   
                           end
                        end
                    end
                    inputArray.imageData = imageData;
                    ID = this.imageImporter.getWellID();
                    inputArray.ID = ID{folder};
                    this.results{folder} = ImageAnalyzer.standardizeData(inputArray, this.cameraAndLensParameters, this.ICSEOrMembrane, this.parametersToCalculate);
                end
               
                
                for folder = 1 : this.imageImporter.getNumberOfUsedDirectories()
                    this.dataStructure{folder} = this.generateSingleCycleExperimentDataStructure(folder);
                    if strcmp(this.imageProcessingParameters.getAutoSaveMidas(), 'on') && strcmp(this.imageProcessingParameters.getMidasFileSaveFormat(), 'separate')
                        this.saveSeparateMidasFile(folder);
                    end
                end
                switch this.imageProcessingParameters.useParallelComputing
                    case 'on'
                        if(exist('matlabpool'))
                            if matlabpool('size') > 0
                                matlabpool close
                            end
                        else
                            if ~isempty(gcp('nocreate'))
                                delete(gcp('nocreate'))
                            end
                        end
                end
            try
                if ~isempty(this.feedbackHandle)
                    set(this.feedbackHandle, 'String', 'Analysis completed');
                end
            catch
            end
            this.fullDataStructure = this.generateFullDataStructure();
            if strcmp(this.imageProcessingParameters.getAutoSaveMidas(), 'on') && strcmp(this.imageProcessingParameters.getMidasFileSaveFormat(), 'complete')
                    this.saveCompleteMidasFile();
            end
            this.isAnalysisComplete = 1;
        end
        
        function rawData = getRawImageData(this)
           rawData = this.rawImageData; 
        end
        
        function dataStructure = generateSingleCycleExperimentDataStructure(this, folder)
                originalDataStruct = this.imageImporter.getDataStructureOfFolder(folder);
                
                switch this.referenceTimeMode
                    case 'First point'
                        localExperimentStartTime = min(this.results{folder}.measurementTimeOfWell);
                    case 'Choose time'
                        localExperimentStartTime = this.experimentStartTime;
                end
                
                if strcmp(this.measurementTimeMode, 'Manual')
                    dataStructure.timeOfMeasurements = originalDataStruct.timeOfMeasurements(folder);

                elseif strcmp(this.measurementTimeMode, 'Cycle average')                    
                        dataStructure.timeOfMeasurements = this.results{folder}.measurementTimeOfCycle - localExperimentStartTime;
                    
                elseif strcmp(this.measurementTimeMode, 'Well average')                    
                        dataStructure.timeOfMeasurements(1, :) = this.results{folder}.measurementTimeOfWell - localExperimentStartTime;                    
                end
                dataStructure.timeOfMeasurements = dataStructure.timeOfMeasurements * 86400;
                switch this.referenceTimeMode
                    case 'First point'
                            dataStructure.timeOfMeasurements = dataStructure.timeOfMeasurements + this.timeShift;
                    case 'Choose time'
                end
                dataStructure.numberOfChannels = this.results{folder}.numberOfChannels;
                % if dataStructure.numberOfChannels == 1
                   % warndlg('false number of channels'); 
                % end
                dataStructure.channelNames = this.results{folder}.channelNames;
                dataStructure.wellID = originalDataStruct.wellID;
                for well = 1 : numel(dataStructure.wellID)
                    for channel = 1 : dataStructure.numberOfChannels
                        dataStructure.measurements{1, well}(channel, 1) = this.results{folder}.data{well}(channel);
                    end        
                end
        end
        
        function dataStructure = generateFullDataStructure(this)
            originalDataStruct = this.imageImporter.getDataStructure();
            switch this.referenceTimeMode
                case 'First point'
                        minimal = zeros(1, this.imageImporter.getNumberOfUsedDirectories());
                        for folder = 1 : this.imageImporter.getNumberOfUsedDirectories()
                            minimal(folder) = min(this.results{folder}.measurementTimeOfWell);
                        end
                        this.experimentStartTime = min(minimal);
                case 'Choose time'

            end

            if strcmp(this.measurementTimeMode, 'Manual')
                dataStructure.timeOfMeasurements = originalDataStruct.timeOfMeasurements;
            elseif strcmp(this.measurementTimeMode, 'Cycle average')
                for folder = 1 : this.imageImporter.getNumberOfUsedDirectories()
                    dataStructure.timeOfMeasurements(folder, 1) = this.results{folder}.measurementTimeOfCycle - this.experimentStartTime;
                end
            elseif strcmp(this.measurementTimeMode, 'Well average')
                for folder = 1 : this.imageImporter.getNumberOfUsedDirectories()
                    times = this.results{folder}.measurementTimeOfWell - this.experimentStartTime;
                    dataStructure.timeOfMeasurements(folder, 1 : numel(times)) = times;
                end
            end
            
            
            dataStructure.timeOfMeasurements = dataStructure.timeOfMeasurements * 86400;% Converts to seconds from days;
            
            switch this.referenceTimeMode
                case 'First point'
                        dataStructure.timeOfMeasurements = dataStructure.timeOfMeasurements + this.timeShift;
                case 'Choose time'
            end
            
            dataStructure.numberOfChannels = this.results{1}.numberOfChannels;
            dataStructure.channelNames = this.results{1}.channelNames;
            if this.observationMode
                wellID = this.imageImporter.getAllImportedWellID();
            else
                wellID = this.imageImporter.getWellID();
            end
            if(numel(wellID) > 1)
                dataStructure.wellID = wellID{1}';
                for index = 2 : numel(wellID)
                    dataStructure.wellID = union(dataStructure.wellID', wellID{index})';
                end
            else
                dataStructure.wellID = wellID{1}';
            end
            %dataStructure.wellID = originalDataStruct.wellID;
            
            for cycle = 1 : numel(this.results)
                for well = 1 : numel(dataStructure.wellID)
                    for channel = 1 : dataStructure.numberOfChannels
                        currentWellID = dataStructure.wellID{well};
                        originalIndex = find(ismember(wellID{cycle}, currentWellID));
                        if isempty(originalIndex)
                           dataStructure.measurements{1, well}(channel + (cycle - 1)*dataStructure.numberOfChannels, 1) = NaN;
                        else
                           dataStructure.measurements{1, well}(channel + (cycle - 1)*dataStructure.numberOfChannels, 1) = this.results{cycle}.data{originalIndex}(channel); 
                        end
                        
                    end        
                end
            end
        end
        
        function setMidasTableController(this, midasTableController)
           this.midasTableController = midasTableController; 
        end
        
        function midasTableController = getMidasTableController(this)
            midasTableController = this.midasTableController;
        end
        
        function saveCompleteMidasFile(this)
            this.handles = generateApareciumExperimentInput(this.handles, this.fullDataStructure);
            try
                this.handles = changeDimensionality(this.handles, num2str(this.handles.dimensionality));
            catch
                
            end
            this.handles.apareciumExperimentInput.updateTreatments(this.handles.treatments_TableData);
            rawData = sendDataToMidasTable(this.fullDataStructure, this.handles.dimensionality);
            updateMidasChannels(this.handles);
            this.handles.midasTableController.setData(rawData);
            this.handles = updateMidasHeaders(this.handles);
            if isfield(this.handles, 'plateSimulatorInterface')
                if this.handles.plateSimulatorInterface.isPlateSimulatorInitialized
                    treatmentStructure = this.handles.plateSimulatorInterface.getTreatmentStructure();
                    this.handles.midasTableController.updateTreatments(treatmentStructure);
                end
            else
                
            end
            
            inputStruct.data = this.handles.midasTableController.getMidasTable();
            inputStruct.fileName = ['MD-',this.midasFileName, '.csv'];
            inputStruct.filePath = [this.imageImporter.mainDirectory, '\'] ;
            inputStruct.automatically = 1;
            saveMidasFile(inputStruct);
        end
        
        function saveSeparateMidasFile(this, folder)

            this.handles = generateApareciumExperimentInput(this.handles, this.dataStructure{folder});
            this.handles = changeDimensionality(this.handles, num2str(this.handles.dimensionality));
            this.handles.apareciumExperimentInput.updateTreatments(this.handles.treatments_TableData);
            rawData = sendDataToMidasTable(this.dataStructure{folder}, this.handles.dimensionality);
            updateMidasChannels(this.handles);
            this.handles.midasTableController.setData(rawData);
            this.handles = updateMidasHeaders(this.handles);
            if this.handles.plateSimulatorInterface.isPlateSimulatorInitialized
                treatmentStructure = this.handles.plateSimulatorInterface.getTreatmentStructure();
                this.handles.midasTableController.updateTreatments(treatmentStructure);
            end
            
            inputStruct.data = this.handles.midasTableController.getMidasTable();
            usedDirectories = this.imageImporter.getUsedDirectories();
            inputStruct.fileName = ['MD-', usedDirectories{folder}, this.midasFileName];
            inputStruct.filePath = this.imageImporter.getFilePathOfDirectoryWithIndex(folder);
            inputStruct.automatically = 1;
            saveMidasFile(inputStruct);           
        end
        
        function wellMeasurementInfo = analyzeOneTimepoint(this, directoryPath, folder)
            %% get all .tif file names from the directory provided
            fileListArray = dir([directoryPath,'\*.tif']);
            wellID = this.imageImporter.getWellID();
            wellID = wellID{folder};
            %% reorganize the fileListArray to get all the file names
            nameArray = cell(length(fileListArray),1);
            for i = 1 : length(fileListArray)
                nameArray{i} = fileListArray(i).name;
            end
            wellMeasurementInfo = cell(numel(wellID), 1);
            switch this.imageProcessingParameters.useParallelComputing
                case 'on'
                    %try      
                        try
                            set(this.feedbackHandle, 'String', 'Check command window for estimation');
                            drawnow;
                        catch
                            
                        end
                        if(exist('matlabpool'))
                            this.imagesLeftToAnalyse = this.imagesLeftToAnalyse/matlabpool('size');
                        else
                            poolObject = gcp('nocreate');
                            poolSize = poolObject.NumWorkers;
                            this.imagesLeftToAnalyse = this.imagesLeftToAnalyse/poolSize;
                        end
                        
                                                      
                        if strcmp(this.ICSEOrMembrane, 'ICSE')
                            for well = 1 : numel(wellID)
                               if well == 1
                                   measurementParams = this.configureWellMeasurementParameters(well, nameArray, [], wellID, directoryPath, folder);
                               else
                                   measurementParams = [measurementParams, this.configureWellMeasurementParameters(well, nameArray, [], wellID, directoryPath, folder)];
                               end
                               %wellMeasurementInfo{well} = this.analyzeOneWell(well, nameArray, [], wellID, directoryPath, folder);
                            end
                        elseif strcmp(this.ICSEOrMembrane, 'Membrane')
                            nameArray = this.imageImporter.getNameArrayOfFolder(folder);
                            secondaryNameArray = this.imageImporter.getSecondaryNameArrayOfFolder(folder);
                            for well = 1 : numel(wellID)   
                                if well == 1
                                   measurementParams = this.configureWellMeasurementParameters(well, nameArray, secondaryNameArray, wellID, directoryPath, folder); 
                                else
                                   measurementParams = [measurementParams, this.configureWellMeasurementParameters(well, nameArray, secondaryNameArray, wellID, directoryPath, folder)];
                                end                                   
                                   %wellMeasurementInfo{well} = this.analyzeOneWell(well, nameArray, secondaryNameArray, wellID, directoryPath, folder);
                            end                      
                        end
                        
                        if strcmp(this.ICSEOrMembrane, 'ICSE')
                            for imageIndex = 1 : numel(measurementParams)
                                measurementParams(imageIndex).results = ''; % create a field so parfor does not crash
                            end
                            functionName = str2func([class(this), '.analyseOneImageStatic']); 
                            parfor imageIndex = 1 : numel(measurementParams)% parfor should be here                            
                                measurementParams(imageIndex).results = functionName(...
                                  measurementParams(imageIndex).wellName, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).imageProcessingParams,...
                                  measurementParams(imageIndex).timeParameters, measurementParams(imageIndex).thresholdFunctionHandle,...
                                  measurementParams(imageIndex).parametersToCalculate);
                            end

                            for imageIndex = 1 : numel(measurementParams)
                               wellMeasurementInfo{measurementParams(imageIndex).wellIndex}{measurementParams(imageIndex).picOfWell} = measurementParams(imageIndex).results;
                               wellMeasurementInfo{measurementParams(imageIndex).wellIndex}{measurementParams(imageIndex).picOfWell}.imageName = measurementParams(imageIndex).imageName;
                            end
                                                         
                        elseif strcmp(this.ICSEOrMembrane, 'Membrane')
                            for imageIndex = 1 : numel(measurementParams)
                                measurementParams(imageIndex).results = ''; % create a field so parfor does not crash
                            end
                            functionName = str2func([class(this), '.analyzeMembranesStatic']);
                            if strcmp(this.imageProcessingParameters.detectionModel, this.imageProcessingParameters.IlastikModel)
                                IlastikAnalysis = str2func([class(this), '.performIlastikAnalysis']);
                                measurementParams = IlastikAnalysis(measurementParams); 
                            else
                                for imageIndex = 1 : numel(measurementParams)% parfor should be here                            
                                    measurementParams(imageIndex).results = functionName(...
                                    measurementParams(imageIndex).wellName, measurementParams(imageIndex).secondaryPicOfWell, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).imageProcessingParams,...
                                    measurementParams(imageIndex).timeParameters, measurementParams(imageIndex).thresholdFunctionHandle, measurementParams(imageIndex).calculationMethod, measurementParams(imageIndex).qualityMask, ...
                                    measurementParams(imageIndex).parametersToCalculate, []);
                                end
                            end
                            for imageIndex = 1 : numel(measurementParams)
                               wellMeasurementInfo{measurementParams(imageIndex).wellIndex}{measurementParams(imageIndex).picOfWell} = measurementParams(imageIndex).results;
                               wellMeasurementInfo{measurementParams(imageIndex).wellIndex}{measurementParams(imageIndex).picOfWell}.imageName = measurementParams(imageIndex).imageName;
                            end
                        end
                        
                        
                        if(exist('matlabpool'))
                            this.imagesLeftToAnalyse = this.imagesLeftToAnalyse*matlabpool('size') - numel(wellID)*4;
                        else
                            poolObject = gcp('nocreate');
                            poolSize = poolObject.NumWorkers;
                            this.imagesLeftToAnalyse = this.imagesLeftToAnalyse*poolSize - numel(wellID)*4;
                        end
                        
                        java.lang.Runtime.getRuntime().gc;
                case 'off'
                    for well = 1 : numel(wellID)
                        if strcmp(this.ICSEOrMembrane, 'ICSE') 
                            for well = 1 : numel(wellID)
                               if well == 1
                                   measurementParams = this.configureWellMeasurementParameters(well, nameArray, [], wellID, directoryPath, folder);
                               else
                                   measurementParams = [measurementParams, this.configureWellMeasurementParameters(well, nameArray, [], wellID, directoryPath, folder)];
                               end
                               %wellMeasurementInfo{well} = this.analyzeOneWell(well, nameArray, [], wellID, directoryPath, folder);
                            end
                            
                            for imageIndex = 1 : numel(measurementParams)
                                measurementParams(imageIndex).results = ''; % create a field so parfor does not crash
                            end
                            functionName = str2func([class(this), '.analyseOneImageStatic']); 
                            for imageIndex = 1 : numel(measurementParams)% parfor should be here                            
                                measurementParams(imageIndex).results = functionName(...
                                  measurementParams(imageIndex).wellName, measurementParams(imageIndex).directoryPath, measurementParams(imageIndex).imageProcessingParams,...
                                  measurementParams(imageIndex).timeParameters, measurementParams(imageIndex).thresholdFunctionHandle,...
                                  measurementParams(imageIndex).parametersToCalculate);
                            end

                            for imageIndex = 1 : numel(measurementParams)
                               wellMeasurementInfo{measurementParams(imageIndex).wellIndex}{measurementParams(imageIndex).picOfWell} = measurementParams(imageIndex).results;
                               wellMeasurementInfo{measurementParams(imageIndex).wellIndex}{measurementParams(imageIndex).picOfWell}.imageName = measurementParams(imageIndex).imageName;
                            end                         
                        elseif strcmp(this.ICSEOrMembrane, 'Membrane')
                            nameArray = this.imageImporter.getNameArrayOfFolder(folder);
                            secondaryNameArray = this.imageImporter.getSecondaryNameArrayOfFolder(folder);
                            if strcmp(this.imageProcessingParameters.detectionModel, this.imageProcessingParameters.IlastikModel)
                                for well = 1 : numel(wellID)   
                                    if well == 1
                                       measurementParams = this.configureWellMeasurementParameters(well, nameArray, secondaryNameArray, wellID, directoryPath, folder); 
                                    else
                                       measurementParams = [measurementParams, this.configureWellMeasurementParameters(well, nameArray, secondaryNameArray, wellID, directoryPath, folder)];
                                    end                                   
                                       %wellMeasurementInfo{well} = this.analyzeOneWell(well, nameArray, secondaryNameArray, wellID, directoryPath, folder);
                                end
                                IlastikAnalysis = str2func([class(this), '.performIlastikAnalysis']);
                                measurementParams = IlastikAnalysis(measurementParams); 
                                for imageIndex = 1 : numel(measurementParams)
                                    wellMeasurementInfo{measurementParams(imageIndex).wellIndex}{measurementParams(imageIndex).picOfWell} = measurementParams(imageIndex).results;
                                    wellMeasurementInfo{measurementParams(imageIndex).wellIndex}{measurementParams(imageIndex).picOfWell}.imageName = measurementParams(imageIndex).imageName;
                                end                                 
                            else                                
                                wellMeasurementInfo{well} = this.analyzeOneWell(well, nameArray, secondaryNameArray, wellID, directoryPath, folder);
                            end
                        end
                    end
            end
            
        end
        
        function resultStructure = configureWellMeasurementParameters(this, well, nameArray, secondaryNameArray, wellID, directoryPath, folder)
            wellMeasurementInfo = cell(1,1);
            thresholdFunctionHandle = this.thresholdFunctionHandle;
            imagesOfWell = [];
            
            underscoreLocations = strfind(nameArray, '_');
            
            for pic = 1 : numel(nameArray)
                 if strcmp(ImageImporter.getWellIDOfStringArray(nameArray(pic), '[A-Z]'), wellID{well})
                     imagesOfWell(end + 1) = pic;
                 end
            end
            
            imageProcessingParams = this.imageProcessingParameters;
            timeParameters.totalTimeElapsed = this.totalTimeElapsed;
            timeParameters.analysisStartTime = this.analysisStartTime;           
            nameArrayOfWell = nameArray(imagesOfWell);
            ICSEOrMembrane = this.ICSEOrMembrane;
            qualityMasks = [];
            secondaryNameArrayOfWell = cell(numel(imagesOfWell), 1);
            if strcmp(ICSEOrMembrane, 'Membrane')
                secondaryNameArrayOfWell = secondaryNameArray(imagesOfWell);
                qualityMasks = this.imageImporter.masks{folder};
            else
               qualityMasks = []; % parfor wants the variable to be present, but won´t use it 
            end
            if strcmp(ICSEOrMembrane, 'Membrane') && ~isequal(imageProcessingParams.imageSegmentationMode, imageProcessingParams.FromBinary)
                imageProcessingParams.imageSegmentationMode = imageProcessingParams.Slopes;
            end
            
            for picOfWell = 1 : numel(imagesOfWell)
                 %resultStructure = this.analyseOneImage(nameArray{imagesOfWell(picOfWell)}, directoryPath);
                 if strcmp(ICSEOrMembrane, 'ICSE')
                     resultStructure(picOfWell).picOfWell = picOfWell;
                     resultStructure(picOfWell).wellIndex = well;
                     resultStructure(picOfWell).wellName = nameArrayOfWell{picOfWell};
                     resultStructure(picOfWell).directoryPath = directoryPath;
                     resultStructure(picOfWell).imageProcessingParams = imageProcessingParams;
                     resultStructure(picOfWell).timeParameters = timeParameters;
                     resultStructure(picOfWell).thresholdFunctionHandle = thresholdFunctionHandle;
                     resultStructure(picOfWell).imageName = nameArrayOfWell{picOfWell};
                     resultStructure(picOfWell).parametersToCalculate = this.parametersToCalculate;
                 elseif strcmp(ICSEOrMembrane, 'Membrane')
                     resultStructure(picOfWell).picOfWell = picOfWell;
                     resultStructure(picOfWell).secondaryPicOfWell = secondaryNameArrayOfWell{picOfWell};
                     resultStructure(picOfWell).wellIndex = well;
                     resultStructure(picOfWell).wellName = nameArrayOfWell{picOfWell};
                     resultStructure(picOfWell).directoryPath = directoryPath;
                     resultStructure(picOfWell).imageProcessingParams = imageProcessingParams;
                     resultStructure(picOfWell).timeParameters = timeParameters;
                     resultStructure(picOfWell).thresholdFunctionHandle = thresholdFunctionHandle;
                     resultStructure(picOfWell).imageName = nameArrayOfWell{picOfWell};
                     resultStructure(picOfWell).parametersToCalculate = this.parametersToCalculate;
                     resultStructure(picOfWell).calculationMethod = 'Binary';
                     try
                        resultStructure(picOfWell).qualityMask = qualityMasks{well}{picOfWell};
                     catch MException
                        '' 
                     end

                     %resultStructure = analyzeMembranesStatic(nameArrayOfWell{picOfWell}, secondaryNameArrayOfWell{picOfWell}, directoryPath, imageProcessingParams, timeParameters, thresholdFunctionHandle, 'Binary', qualityMasks{well});
                     %wellMeasurementInfo{picOfWell}.averageMembraneIntensity = resultStructure.averageMembraneIntensity;
                 end
                 
             end
             
        end
            
        function wellMeasurementInfo = analyzeOneWell(this, well, nameArray, secondaryNameArray, wellID, directoryPath, folder) 
            %picOfWell = 1;
            wellMeasurementInfo = cell(1,1);
            thresholdFunctionHandle = this.thresholdFunctionHandle;
            imagesOfWell = [];
  
            
            for pic = 1 : numel(nameArray)
                 if strfind(nameArray{pic}, wellID{well}) % this function needs more advanced regex to avoid finding A3 from AA30 and similar problems
                     imagesOfWell(end + 1) = pic;
                 end
            end
            imageProcessingParams = this.imageProcessingParameters;
            timeParameters.totalTimeElapsed = this.totalTimeElapsed;
            timeParameters.analysisStartTime = this.analysisStartTime;
            nameArrayOfWell = nameArray(imagesOfWell);
            ICSEOrMembrane = this.ICSEOrMembrane;
            qualityMasks = [];
            secondaryNameArrayOfWell = cell(numel(imagesOfWell), 1);
            if strcmp(ICSEOrMembrane, 'Membrane')
                secondaryNameArrayOfWell = secondaryNameArray(imagesOfWell);
                qualityMasks = this.imageImporter.masks{folder};
            else
               qualityMasks = []; % parfor wants the variable to be present, but won´t use it 
            end
            if strcmp(ICSEOrMembrane, 'Membrane') && ~isequal(imageProcessingParams.imageSegmentationMode, imageProcessingParams.FromBinary)
                imageProcessingParams.imageSegmentationMode = imageProcessingParams.Slopes;
            end
            % do one image outside of the loop to create the right kind of
            % structure
            % resultStructure = ImageAnalyzer.analyseOneImageStatic(nameArrayOfWell{1}, directoryPath, imageProcessingParams, timeParameters, figHandles, thresholdFunctionHandle);
            for picOfWell = 1 : numel(imagesOfWell)
                 if strcmp(ICSEOrMembrane, 'ICSE')
                     resultStructure = ImageAnalyzer.analyseOneImageStatic(nameArrayOfWell{picOfWell}, directoryPath, imageProcessingParams, timeParameters, thresholdFunctionHandle)
                 elseif strcmp(ICSEOrMembrane, 'Membrane')
                     %try
                        functionName = str2func([class(this), '.analyzeMembranesStatic']); 
                        resultStructure = functionName(nameArrayOfWell{picOfWell}, secondaryNameArrayOfWell{picOfWell}, directoryPath, directoryPath, imageProcessingParams, timeParameters, thresholdFunctionHandle, 'Binary', qualityMasks{well}{picOfWell}, this.parametersToCalculate, []);
                        wellMeasurementInfo{picOfWell}.averageMembraneIntensity = resultStructure.averageMembraneIntensity;
                        wellMeasurementInfo{picOfWell} = resultStructure;
                        wellMeasurementInfo{picOfWell}.imageName = nameArrayOfWell{picOfWell}; 
                     %catch MException
                     %   'stop' 
                     %end
                     end
                               
             end
             java.lang.Runtime.getRuntime().gc;
        end
        
        function setHandles(this, handles)
           this.handles = handles; 
        end
        
        function setExperimentStartTime(this, experimentStartTime)
            this.experimentStartTime = experimentStartTime;
        end
        
        function startTime = getExperimentStartTime(this)
            startTime = this.experimentStartTime;
        end
        
        function setMeasurementTimeMode(this, timeMode)
           this.measurementTimeMode = timeMode; 
        end
        
        function measurementTimeMode = getMeasurementTimeMode(this)
           measurementTimeMode = this.measurementTimeMode; 
        end
        
        function setReferenceTimeMode(this, referenceTimeMode)
           this.referenceTimeMode = referenceTimeMode; 
        end
        
        function referenceTimeMode = getReferenceTimeMode(this)
            referenceTimeMode = this.referenceTimeMode;
        end
        
        function setTimeShift(this, timeShift)
            this.timeShift = timeShift;
        end
        
        function setFigureHandles(this, figureHandles)
           this.figureHandles = figureHandles; 
        end
        
        function saveBinaryImages(this, folder, imageData)
            switch this.imageProcessingParameters.getAutoSaveBinaryFiles
                case 'on'
                    maindir = this.imageImporter.mainDirectory;
                    subdir = this.imageImporter.getUsedDirectoryWithIndex(folder);
                    mkdir([this.imageImporter.mainDirectory,'\','Binary', this.imageImporter.getUsedDirectoryWithIndex(folder),'\']);
                    for well = 1 : length(imageData)
                       for image = 1 : length(imageData{well})
                           imwrite(imageData{well}{image}.image,[this.imageImporter.mainDirectory,...
                               '\','Binary', this.imageImporter.getUsedDirectoryWithIndex(folder), '\', imageData{well}{image}.imageName])
                       end
                    end
                case 'off'
                for well = 1 : length(imageData)
                   for image = 1 : length(imageData{well})
                       imageData{well}{image}.image = [];                                   
                   end
                end   
            end
            
            switch this.imageProcessingParameters.getAutoSaveMasks()
                case 'on'
                    maindir = this.imageImporter.mainDirectory;
                    subdir = this.imageImporter.getUsedDirectoryWithIndex(folder);
                    mkdir([this.imageImporter.mainDirectory,'\','Mask', this.imageImporter.getUsedDirectoryWithIndex(folder), '\']);
                    for well = 1 : length(imageData)
                        for imageInWell = 1 : length(imageData{well})
                            imwrite(this.imageImporter.masks{folder}{well}{imageInWell}, [this.imageImporter.mainDirectory, '\', 'Mask', this.imageImporter.getUsedDirectoryWithIndex(folder), '\', imageData{well}{imageInWell}.imageName])
                        end
                    end
                case 'off'
                  
            end
                    

            
            for well = 1 : length(imageData)
               for image = 1 : length(imageData{well})
                   imageData{well}{image}.image = [];                   
               end
            end
        end
        
    end
    methods(Static)
        
%         function resultStructure = analyzeMembranesStatic(picName, secondaryPicName, filePath, imageProcessingParameters, timeParameters, functionHandle, calculationMethod, qualityMask)
%             resultStructure = ImageAnalyzer.analyseOneImageStatic(picName, filePath, imageProcessingParameters, timeParameters, functionHandle);
%             %I_Fluo = Cytation5TIFFImage([regexprep(filePath, 'Bright Field', 'RFP'), regexprep(regexprep(picName, 'Bright Field', 'RFP'), '03_2', '03_1')]);
%             %image = I_Fluo.getImage();
%             %%image = imread([filePath(1:end-1), 'RFP',filePath(end),
%             %%regexprep(picName, 'x_', 'x_RFP_')]);
% 
%             image = imread([filePath, secondaryPicName]);
%             contents = dir(filePath);
%             contents(1:2) = [];
%             cellContents = struct2cell(contents);
%             possibleNames = cellContents(1, :);
%             % prepare Zstack image names
%             ZIndex = strfind(secondaryPicName, '_1Z');
%             names = cell(1, numel(possibleNames));
%             index = 0;
%             while 1
%                 pathlessName = [secondaryPicName(1:ZIndex+2), num2str(index), '_RFP_', secondaryPicName(end-6:end)];
%                 if isequal(sum(strcmp(possibleNames, pathlessName)), 0)
%                    break; 
%                 end
%                 
%                 names{index + 1} = [filePath, secondaryPicName(1:ZIndex+2), num2str(index), '_RFP_', secondaryPicName(end-6:end)];
%                 index = index + 1;
%             end
%             
%             names = names(~cellfun(@isempty, names));
%             focusedImage = focusFromZStack(names);
%             %boundaries = bwboundaries(resultStructure.image);
%             %imageWithBoundaries = zeros(904, 1224);
%             %for boundarieIndex = 1 : numel(boundaries)
%             %    for pixelIndex = 1 : size(boundaries{boundarieIndex}, 1)
%             %        imageWithBoundaries(boundaries{boundarieIndex}(pixelIndex, 1), boundaries{boundarieIndex}(pixelIndex, 2)) = 1;
%             %    end
%             %end
%             %se = strel('disk',1);
%             %finalImage = imdilate(logical(imageWithBoundaries), se);
%             if strcmp(calculationMethod, 'Binary')
%                 
%                 binaryImageCalculator = BinaryImageCalculator();
%                 parametersToCalculate = {'confluency', 'image'};
%                 maskedImage = and(1-qualityMask, resultStructure.image);
%                 binaryImageCalculator.calculateImageParameters(maskedImage, parametersToCalculate, functionHandle);
%                 maskedResultStructure = binaryImageCalculator.resultStructure;
%                 indices = maskedResultStructure.image == 1;
%                 resultStructure.image = maskedResultStructure.image;
%                 resultStructure.confluency = maskedResultStructure.confluency;
%                 resultStructure.averageMembraneIntensity = mean(focusedImage(indices)); % image was instead of focusedImage
%                 
%             elseif strcmp(calculationMethod, 'Probability')
%                  resultStructure.averageMembraneIntensity = sum(sum(double(image).*resultStructure.probabilityImage))/(sum(sum(resultStructure.probabilityImage)));
%             end
%             %resultStructure.averageMembraneIntensity = mean(mean(image));
%         end
        
        function resultStructure = analyseOneImageStatic(picName, filePath, imageProcessingParameters, timeParameters, functionHandle, parametersToCalculate)
 %           try
                tic
                %timeMeasurer = Par(1);
                %Par.tic;
                try
                    image = Cytation5TIFFImage([filePath, picName]);
                    I_org1 = image.getImage();
                    resultStructure.imageTime = image.getImageTime();
                    resultStructure.imageWidthMicrons = image.getImageWidthMicrons();
                    resultStructure.imageHeightMicrons = image.getImageHeightMicrons();
                catch
                    I_org1 = imread([filePath, picName]); 
                    resultStructure.imageTime = 0;
                end
                %resultStructure.imageTime = 0;
                %I_org1 = imread([filePath,'\',picName]);%I_org = imread('Demo1.png');
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
                        
                            [bw2, probabilityImage] = ZStackBinary(in);
                            %resultStructure.probabilityImage = probabilityImage;
                           
                        
                            %bw2 = zeros(size(I_orgTrue, 1), size(I_orgTrue, 2));
                        
                end

                %run the code and visualize it
                
                cc = bwconncomp(bw2);
                boundaries = bwboundaries(bw2);
                EccStruct = regionprops(logical(bw2), 'Eccentricity');
                
                eccentricity = [EccStruct.Eccentricity];
                %viralPercent = 0 %ViralClassifier(cc,I_org1,10,300);
                a=0;
                sizeHistogram = [];
                area=0;
                radiusStack = [];
                maxDiameter = 0;
                radius = 0;
                
                for i = 1:size(cc.PixelIdxList,2)
                    %thresholdScore = size(cc.PixelIdxList{i},1) - 500 * eccentricity(i);
                    %if(size(cc.PixelIdxList{i},1)>35)&&(size(cc.PixelIdxList{i},1)<300)&&(eccentricity(i)<0.86)
                    
                    %if thresholdScore > -350 && size(cc.PixelIdxList{i},1) < 300
                    if(objectMatchesCriteria(cc.PixelIdxList{i}, eccentricity(i), functionHandle) || isequal(func2str(functionHandle), 'None'))
                        a = a+1;
                        radius = radius + sqrt(size(cc.PixelIdxList{i},1)/3.14);
                        maxDiameter = maxDiameter + maxObjectDiameter(boundaries{i});
                        radiusStack(end+1) = sqrt(size(cc.PixelIdxList{i},1)/3.14);
                        area = area+size(cc.PixelIdxList{i},1);
                        sizeHistogram(end+1) = size(cc.PixelIdxList{i},1);
                    end
                    %end
                end
                resultStructure.maxDiameter = maxDiameter/a;
                resultStructure.objects = a;
                resultStructure.radius = radius/a;
                resultStructure.area = area/a;
                resultStructure.RDev = std(radiusStack);
                resultStructure.SDev = std(sizeHistogram);
                resultStructure.image = bw2;
                histo(max(sizeHistogram))=0; 
                for p=1:length(sizeHistogram)
                    histo(sizeHistogram(p))=histo(sizeHistogram(p))+1;
                end
                resultStructure.histo = histo;
                binaryImageCalculator = BinaryImageCalculator();
                parametersToCalculate = {'area', 'areaSTD', 'diameter', 'diameterSTD', 'objectCount', 'maxDiameter', 'image', 'confluency'};
                binaryImageCalculator.calculateImageParameters(bw2, parametersToCalculate, functionHandle);
                alternativeResultStructure = binaryImageCalculator.resultStructure;
                alternativeResultStructure.imageTime = resultStructure.imageTime;
                alternativeResultStructure.imageWidthMicrons = resultStructure.imageWidthMicrons;
                alternativeResultStructure.imageHeightMicrons = resultStructure.imageHeightMicrons;
                resultStructure = alternativeResultStructure;
                switch imageProcessingParameters.useParallelComputing
                    case 'on'
%                         try
%                             timeMeasurer(1) = Par.toc;           
%                             stop(timeMeasurer);
%                             tocTimer = timeMeasurer(1);                    
%                             time = tocTimer.getToc();
%                             timePassed = timeParameters.totalTimeElapsed + time;
%                             timeParameters.totalTimeElapsed = timeParameters.totalTimeElapsed + time;
%                         catch
%                             warndlg('Error with time');
%                             timePassed = NaN;
%                         end
                    case 'off'
                        try
                            timePassed = toc(timeParameters.analysisStartTime);
                            %if ~isempty(figureHandles)
                                %imshow(I_orgTrue, 'Parent', figureHandles(1));
                                %imshow(bw2, 'Parent', figureHandles(2));
                            %end
                        catch
                            'no handles present';
                        end
                end

%                 estimatedTimeLeft = (timePassed/this.imagesAnalysed) * this.imagesLeftToAnalyse;
%                 switch this.imageProcessingParameters.useParallelComputing
%                     case 'on'                        
%                         disp(['Time elapsed: ', num2str(timePassed),'s', '. Estimated time left: ', num2str(estimatedTimeLeft),'s', '.Images left: ', num2str(this.imagesLeftToAnalyse)]);
%                     case 'off'
%                         set(this.feedbackHandle, 'String', ['Time elapsed: ', num2str(timePassed), '. Estimated time left: ', num2str(estimatedTimeLeft),'s']);
%                         drawnow;
%                 end
%            catch
             if isequal(size(cc.PixelIdxList,2), 0)
                disp('Image could not be analyzed, all parameters were set to 0'); 
                resultStructure.maxDiameter = 0;
                resultStructure.objects = 0;
                resultStructure.radius = 0;
                resultStructure.area = 0;
                resultStructure.RDev = 0;
                resultStructure.SDev = 0;
                resultStructure.histo = 0;
                resultStructure.image = zeros(size(I_orgTrue, 1), size(I_orgTrue, 2));
            end
           %clear references to java objects
           clear image I_org1 I_org
           toc
        end
        
        function bw2 = segmentImage(imageProcessingParameters, I_orgTrue)
            tileDim = imageProcessingParameters.getTileDim();
            lambda = imageProcessingParameters.getLambda();
            maxSizeMSER = imageProcessingParameters.getMaxSizeMSER();
            minSizeMSER = imageProcessingParameters.getMinSizeMSER();
            maxSizeSplit = imageProcessingParameters.getMaxSizeSplit();
            minSizeSplit = imageProcessingParameters.getMinSizeSplit();
            maxEcc = imageProcessingParameters.getMaxEcc();
            maxVariation = imageProcessingParameters.getMaxVariation();
            try
                bw2 = segmentImage(I_orgTrue,'visualize', false, 'doMerge', imageProcessingParameters.getNumericalMergeMode(),...
                    'tiledim', tileDim, 'lambda', lambda, 'maxSizeMSER', maxSizeMSER, 'minSizeMSER', minSizeMSER,...
                    'maxSizeSplit', maxSizeSplit, 'minSizeSplit', minSizeSplit, 'maxEcc', maxEcc, 'maxVariation', maxVariation);
            catch MException
               bw2 = im2bw(zeros(size(I_orgTrue, 1), size(I_orgTrue, 2)));
               'image could not be analyzed'
            end
        end
        
        function handles = standardizeData(handles, cameraAndLensParameters, ICSEorMembrane, parametersToCalculate)
            data = cell(1,length(handles.ID));
            if strcmp(ICSEorMembrane, 'Membrane')
                parametersToCalculate{end + 1} = 'averageMembraneIntensity';
                parametersToCalculate{end + 1} = 'averageSecondaryImageIntensity';
                parametersToCalculate{end + 1} = 'averageNonMembraneIntensity';
                parametersToCalculate{end + 1} = 'firstNonMembraneQuadrileIntensity';
                parametersToCalculate{end + 1} = 'averageUnmaskedMembraneIntensity';
                parametersToCalculate{end + 1} = 'averageUnmaskedNonMembraneIntensity';
                parametersToCalculate{end + 1} = 'firstUnmaskedNonMembraneQuadrileIntensity';
                parametersToCalculate{end + 1} = 'averageUnmaskedSecondaryImageIntensity';
                parametersToCalculate{end + 1} = 'pixelCount';
                parametersToCalculate{end + 1} = 'intensitySTD';
            end
            for well = 1 : length(handles.ID)
                % generate temporary variable wellData for holding data for that particular well
                wellData = [];
                

                for parameterIndex = 1 : numel(parametersToCalculate)
                    try
                        wellData(end + 1, 1) = BinaryImageCalculator.averageParameter(handles.imageData{well}, parametersToCalculate{parameterIndex}, cameraAndLensParameters);
                    catch MException
                        disp(['No numerical representation possible for ', parametersToCalculate{parameterIndex}, ' using NaN instead']);
                        wellData(end + 1, 1) = NaN;
                    end
                end            
                handles.measurementTimeOfWell(well) = BinaryImageCalculator.averageParameter(handles.imageData{well}, 'time', cameraAndLensParameters); 
                data{well} = wellData; 
            end
            handles.channelNames = cell(1, numel(parametersToCalculate));
            for parameterIndex = 1 : numel(parametersToCalculate)
                handles.channelNames{1, parameterIndex} = [parametersToCalculate{parameterIndex}, '_',BinaryImageCalculator.getUnitOfParameter(parametersToCalculate{parameterIndex})];
            end
            handles.data = data;
            handles.measurementTimeOfCycle = mean(handles.measurementTimeOfWell);
            handles.numberOfChannels = numel(parametersToCalculate);
        end
    end
end

