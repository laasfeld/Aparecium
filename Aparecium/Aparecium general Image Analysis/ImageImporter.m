classdef ImageImporter < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        time
        wellID
        allImportedWellID = cell(1,1)
        numberOfChannels  
        usedDirectories 
        mainDirectory
        experimentDataStructure
        primaryFocusAndQualityAnalyzerHandleArray = [];
        secondaryFocusAndQualityAnalyzerHandleArray = [];
        firstLaunch = true;
        analyzedImages = {''};
        analyzeQuality = 0;
        nameArray = [];
        secondaryNameArray = []
        imageNameStructure = []
        masks = [];
        maskNameArray = [];
        detectionChannelRegex = 'Bright Field';
        quantificationChannelRegex = 'RFP';
        quantificationChannelPrefixes = [];
        lowerBound = 0; % 2 would be the default value for Quantitative analysis of fluorescent ligand binding to dopamine D3 receptors using live cell microscopy. 0 means no restriction
        higherBound = 0; % 5 would be the default value for Quantitative analysis of fluorescent ligand binding to dopamine D3 receptors using live cell microscopy. 0 means no restriction
    end
    
    methods
        function this = ImageImporter()
            
        end
       
        
        function initializeImageImporter(this, mainFolder, masksPath, detectionFocalMatFile, quantificationFocalMatFile)
            
            this.mainDirectory = mainFolder;
            folderNames = dir([mainFolder,'\*']);
            folderNames(1 : 2) = [];
            subFoldersCell = struct2cell(folderNames);
            chosenDirectories = cell(1, 0);
            for itemIndex = 1 : numel(folderNames)
                if(folderNames(itemIndex).isdir && exist(fullfile(this.mainDirectory, folderNames(itemIndex).name),'dir') && ~contains(folderNames(itemIndex).name, 'Binary') && ~contains(folderNames(itemIndex).name, 'Mask'))
                    if exist(fullfile(masksPath, folderNames(itemIndex).name), 'dir') || exist(masksPath, 'dir')
                        chosenDirectories{end + 1} = folderNames(itemIndex).name;
                    end
                end
            end          
            
            if isempty(chosenDirectories) % no subfolders
                    [mainDir, finalDir, unneeded] = fileparts(mainFolder);
                    this.mainDirectory = mainDir;
                    chosenDirectories = {finalDir};
            end
            
            this.usedDirectories = chosenDirectories;
            this.nameArray = cell(length(chosenDirectories), 1);
            this.experimentDataStructure = cell(length(chosenDirectories), 1);
            this.masks = cell(length(chosenDirectories), 1);
            
            % check if masks exist
            
            
            for folderIndex = 1 : length(chosenDirectories)
                Bfnames = load(detectionFocalMatFile);
                try
                    Bfnames.('Bfnames') = Bfnames.('fileNames');
                catch
                    
                end
                if length(chosenDirectories) > 1
                    [this.masks{folderIndex}, wellID, focusNames] = ImageImporter.loadMasks(Bfnames.Bfnames{1}, [masksPath, this.usedDirectories{folderIndex}], 'Bright Field');
                else
                    try
                        if strcmp(class(Bfnames.bfNames{1}), 'char')
                            [this.masks{folderIndex}, wellID, focusNames] = ImageImporter.loadMasks(Bfnames.bfNames, masksPath, 'Bright Field');
                        else
                            [this.masks{folderIndex}, wellID, focusNames] = ImageImporter.loadMasks(Bfnames.Bfnames{1}, masksPath, 'Bright Field');
                        end
                        
                        if strcmp(class(Bfnames.fileNames{1}), 'char')
                            [this.masks{folderIndex}, wellID, focusNames] = ImageImporter.loadMasks(Bfnames.fileNames, masksPath, 'Bright Field');
                        else
                            [this.masks{folderIndex}, wellID, focusNames] = ImageImporter.loadMasks(Bfnames.fileNames{1}, masksPath, 'Bright Field');
                        end
                    catch
                        try
                            if strcmp(class(Bfnames.bfNames{1}), 'char')
                                [this.masks{folderIndex}, wellID, focusNames] = ImageImporter.loadMasks(Bfnames.bfNames, masksPath, 'Bright Field');
                            else
                                [this.masks{folderIndex}, wellID, focusNames] = ImageImporter.loadMasks(Bfnames.bfNames{1}, masksPath, 'Bright Field');                                
                            end
                        catch
                            try
                                if strcmp(class(Bfnames.fileNames{1}), 'char')
                                    [this.masks{folderIndex}, wellID, focusNames] = ImageImporter.loadMasks(Bfnames.fileNames, masksPath, 'Bright Field');
                                else
                                    [this.masks{folderIndex}, wellID, focusNames] = ImageImporter.loadMasks(Bfnames.fileNames{1}, masksPath, 'Bright Field');                                
                                end
                            
                            catch
                                if strcmp(class(Bfnames.Bfnames{1}), 'char')
                                    [this.masks{folderIndex}, wellID, focusNames] = ImageImporter.loadMasks(Bfnames.Bfnames, masksPath, 'Bright Field');
                                else
                                    [this.masks{folderIndex}, wellID, focusNames] = ImageImporter.loadMasks(Bfnames.Bfnames{1}, masksPath, 'Bright Field');

                                end                        
                            end
                        end
                    end
                end
                
                % clean up - remove empty values
                
                for wellIndex = 1 : numel(focusNames)
                    for imageIndex = numel(focusNames{wellIndex}) : - 1 : 1
                        if isempty(focusNames{wellIndex}{imageIndex})
                           focusNames{wellIndex}(imageIndex) = [];
                           this.masks{folderIndex}{wellIndex}(imageIndex) = [];
                        end
                    end
                end
                
                this.maskNameArray{folderIndex} = focusNames';
                RFPnames = load(quantificationFocalMatFile);
                try
                    RFPnames.('RFPnames') = RFPnames.('fileNames');
                catch
                    
                end
                if isfield(RFPnames, 'RFPnames')
                    if strcmp(class(RFPnames.RFPnames{1}), 'char')
                        secondaryNameArray = ImageImporter.organizeImageNameArrayByWells(RFPnames.RFPnames, 'RFP');               
                    else
                        secondaryNameArray = ImageImporter.organizeImageNameArrayByWells(RFPnames.RFPnames{folderIndex}, 'RFP');
                    end
                else
                        secondaryNameArray = ImageImporter.organizeImageNameArrayByWells(RFPnames.names, 'RFP');                    
                end
                nameArray = this.removeIncompatibleImages(focusNames', secondaryNameArray', folderIndex);
                
                this.wellID{folderIndex} = cell(0,0);
                this.wellID{folderIndex} = ImageImporter.getWellIDOfStringArray(nameArray, '.tif');
                this.time{folderIndex, 1} = 0;
                this.numberOfChannels{folderIndex} = 6;%% a standard parameter for now
                this.generateExperimentDataStructure(folderIndex);
            end                 
        end
        
        function userChooseImageFolders(this, varargin)
            
            if isequal(nargin, 1)
                mainDir = uigetdir('Choose the folder which contains folders with all the image files for all the timepoints');

            elseif isequal(nargin, 2)
                mainDir = varargin{1};
            end
            


            this.mainDirectory = mainDir;
            %% get all folders from the path
            folderNames = dir([mainDir,'\*']);
            folderNames(1:2) = [];
            %% let the user select the folder names to be analyzed
            listString = cell(0,0);
            for folder = 1 : length(folderNames)
                if isequal(folderNames(folder).isdir,1) 
                   listString{end+1} = folderNames(folder).name;    
                end
            end
            if isempty(listString) % no subfolders
                answer = questdlg('This folder contains no subfolders, did you mean to analyze the selected folder?', 'question', 'Yes', 'No', 'Yes');
                switch(answer)
                    case 'Yes'
                        [mainDir, finalDir, unneeded] = fileparts(mainDir);
                        this.mainDirectory = mainDir;
                        chosenDirectories = {finalDir};
                    case 'No'
                end
            else    
                [Selection, ok] = listdlg('ListString' ,listString,'ListSize',[600 300],'SelectionMode','multiple','Name','Select folders to be analyzed');
                chosenDirectories = listString(Selection);
                this.mainDirectory = mainDir;
            end
            %% Save the directory names that were selected

            
            this.usedDirectories = chosenDirectories;
            
            %% Ask if focuses have been preselected
            prechooseFocusAnswer = questdlg('Would you like to select focus preselection file for this dataset?', 'Yes', 'Yes', 'No', 'No');
                
            if strcmp(prechooseFocusAnswer, 'Yes')
                [detectionChannelFile, detectionChannelPath] = uigetfile('*.mat','Choose the detection channel focal planes .mat file.');
                [quantificationChannelFile, quantificationChannelPath] = uigetfile('*.mat','Choose the quantification channel focal planes .mat file.');


                detectionChannelNames = load(fullfile(detectionChannelPath, detectionChannelFile));
                quantificationChannelNames = load(fullfile(quantificationChannelPath, quantificationChannelFile));


            elseif strcmp(prechooseFocusAnswer, 'No')

            end
            
            
            %% store all the filenames needed for the calculations
            % loop through all the folders

            % get well ID-s
            load plate96WellLayout
            ID = reshape(plate96WellLayout,1,96);
            
            this.imageNameStructure = cell(length(this.usedDirectories), 1);
            this.nameArray = cell(length(this.usedDirectories), 1);
            this.experimentDataStructure = cell(length(this.usedDirectories), 1);
            this.masks = cell(length(this.usedDirectories), 1);
            this.primaryFocusAndQualityAnalyzerHandleArray = cell(length(this.usedDirectories), 1);
            this.secondaryFocusAndQualityAnalyzerHandleArray = cell(length(this.usedDirectories), 1);
            
            for folder = 1 : length(this.usedDirectories)                
                if this.analyzeQuality
                    a = ExtendedRowLabels();
                    plate96WellLayout = cell(48, numel(a));
                    for i = 1 : numel(a)
                        for j = 1 : 48
                            if j < 10
                                plate96WellLayout{j, i} = [a{i},'0', num2str(j)];
                            else
                                plate96WellLayout{j, i} = [a{i}, num2str(j)];
                            end
                        end
                    end
                    %if ~isempty(primaryFocusAndQualityAnalyzerHandle.handle)
                    %    answer = questdlg('This folder contains no subfolders, did you mean to analyze the selected folder?', 'question', 'Yes', 'No', 'Yes')
                    %end
                    this.primaryFocusAndQualityAnalyzerHandleArray{folder} = FocusAndQualityAnalyzerHandle();
                    if strcmp(prechooseFocusAnswer, 'Yes')
                        this.primaryFocusAndQualityAnalyzerHandleArray{folder}.setFocusImageNamePreference(detectionChannelNames.fileNames{folder});
                    end
                    [BFnameArray, standardFocus, this.masks{folder}] = focusAndQualityAnalyzer(fullfile(mainDir,this.usedDirectories{folder}), this.detectionChannelRegex, [this.lowerBound this.higherBound], [], this.primaryFocusAndQualityAnalyzerHandleArray(folder));
                    

                    
                    
                    this.maskNameArray{folder} = BFnameArray;
                    %create a more sophisticated pattern
                    
                    secondaryChannelNames = strsplit(this.quantificationChannelRegex, ';');
                    secondaryChannelCounter = 1;
                    imageProcessingParameters = ImageProcessingParameters();
                    imageProcessingParameters.setQuantificationChannelRegex(this.quantificationChannelRegex);
                    this.quantificationChannelPrefixes = imageProcessingParameters.getQuantificationChannelPrefixes();
                    
                    this = updateImageNameStructure(this, BFnameArray, BFnameArray, [], folder, this.masks{folder});

                    for secondaryChannelName = secondaryChannelNames 
                        secondaryChannelName = secondaryChannelName{1}; % extract from cell array
                           
                        [patMatrix, pat] = ImageImporter.generatePatternMatrix(BFnameArray, secondaryChannelName);
              
                        % remove last | character to correct the pattern
                        %pat(end) = [];
                        %pat = [pat,')(\w*)', this.quantificationChannelRegex];

                        %try
                        this.secondaryFocusAndQualityAnalyzerHandleArray{folder}{secondaryChannelCounter} = FocusAndQualityAnalyzerHandle();
                        [secondaryNameArray, ~, secondaryMasks] = focusAndQualityAnalyzer(fullfile(mainDir, chosenDirectories{folder}), patMatrix, [0 0], standardFocus, this.secondaryFocusAndQualityAnalyzerHandleArray{folder}(secondaryChannelCounter));

                            %catch MException
    %                        save('imageImporterMaskAutosave.mat', 'this', 'BFnameArray', 'standardFocus', 'pat')
                        %end
                        
                        %% new logic

                        this = updateImageNameStructure(this, BFnameArray, secondaryNameArray, this.quantificationChannelPrefixes{secondaryChannelCounter}, folder, secondaryMasks);
                        matchEquivalents = fields(this.imageNameStructure{folder});
                        BFnameArray = cell(1, numel(matchEquivalents));
                        for fieldIndex = 1 : numel(matchEquivalents)
                            BFnameArray{fieldIndex} = this.imageNameStructure{folder}.(matchEquivalents{fieldIndex}).detectionChannelName;
                        end
                        secondaryChannelCounter = secondaryChannelCounter + 1;
                        %%
                        
%                         if numel(secondaryChannelNames) > 1
%                             nameArray = this.removeIncompatibleImages(BFnameArray, secondaryNameArray, folder, 'add', secondaryChannelCounter);
%                         elseif numel(secondaryChannelNames) == 1
%                             nameArray = this.removeIncompatibleImages(BFnameArray, secondaryNameArray, folder);
%                         end
                        
                        %% old
%                         BFnameArray = ImageImporter.removeImagesFromDetectionNameArray(BFnameArray, nameArray);
% 
%                         this.mergeMasks(BFnameArray, secondaryNameArray, folder, secondaryMasks);
%                         for indexToFix = 1 : secondaryChannelCounter
%                             secondaryNameArrayToFix = cell(0,1);
%                             for imageIndex = 1 : numel(this.secondaryNameArray{folder})
%                                 try
%                                     secondaryNameArrayToFix{end + 1} = this.secondaryNameArray{folder}{imageIndex}{indexToFix};
%                                 catch
%                                     % if some are missing, it is ok
%                                 end
%                             end
%                             this.removeIncompatibleImages(BFnameArray, secondaryNameArrayToFix, folder, 'update', indexToFix);
%                         end
%                         secondaryChannelCounter = secondaryChannelCounter + 1;
                        
                        %%
                    end
                else
                    fileListArray = dir([mainDir,'\',this.usedDirectories{folder},'\*.tif']);
                    nameArray = cell(length(fileListArray),1);
                    for i = 1 : length(fileListArray)
                        nameArray{i} = fileListArray(i).name;
                    end
                    BFnameArray = nameArray;
                end
                
                %% reorganize the fileListArray to get all the file names

                this.wellID{folder} = cell(0,0);
                this.wellID{folder} = ImageImporter.getWellIDOfStringArray(BFnameArray, '.tif');
                this.time{folder, 1} = 0;
                this.numberOfChannels{folder} = 6;%% a standard parameter for now
                this.generateExperimentDataStructure(folder);
                
            end
            try
                this = standardizeImageNameStructure(this);
                this = wrapImageImporterToWellWiseOrganization(this);
            catch
                
            end
                
        end
        

        
        function editImport(this)
            
            for folder = 1 : length(this.usedDirectories)                
                if this.analyzeQuality
                    if isempty(this.primaryFocusAndQualityAnalyzerHandleArray{folder}) || isempty(this.primaryFocusAndQualityAnalyzerHandleArray{folder}.handle)
                        load plate96WellLayout
                        ID = reshape(plate96WellLayout,1,96);
            
                
                        a = ExtendedRowLabels();
                        plate96WellLayout = cell(48, numel(a));
                        for i = 1 : numel(a)
                            for j = 1 : 48
                                if j < 10
                                    plate96WellLayout{j, i} = [a{i},'0', num2str(j)];
                                else
                                    plate96WellLayout{j, i} = [a{i}, num2str(j)];
                                end
                            end
                        end
                        %if ~isempty(primaryFocusAndQualityAnalyzerHandle.handle)
                        %    answer = questdlg('This folder contains no subfolders, did you mean to analyze the selected folder?', 'question', 'Yes', 'No', 'Yes')
                        %end
                        this.primaryFocusAndQualityAnalyzerHandleArray{folder} = FocusAndQualityAnalyzerHandle();
                        [BFnameArray, standardFocus, this.masks{folder}] = focusAndQualityAnalyzer(fullfile(this.mainDirectory, this.usedDirectories{folder}), this.detectionChannelRegex, [this.lowerBound this.higherBound], [], this.primaryFocusAndQualityAnalyzerHandleArray(folder));
                    else
                        [BFnameArray, standardFocus, this.masks{folder}] = focusAndQualityAnalyzer(this.primaryFocusAndQualityAnalyzerHandleArray(folder));
                    end
                                        this.maskNameArray{folder} = BFnameArray;
                    %create a more sophisticated pattern
                    
                    
                    
                    secondaryChannelNames = strsplit(this.quantificationChannelRegex, ';');
                    secondaryChannelCounter = 1;
                    imageProcessingParameters = ImageProcessingParameters();
                    imageProcessingParameters.setQuantificationChannelRegex(this.quantificationChannelRegex);
                    this.quantificationChannelPrefixes = imageProcessingParameters.getQuantificationChannelPrefixes();                    
                    this = updateImageNameStructure(this, BFnameArray, BFnameArray, [], folder, this.masks{folder});
                    
                    
                    for secondaryChannelName = secondaryChannelNames 
                        secondaryChannelName = secondaryChannelName{1}; % extract from cell array
                        [patMatrix, pat] = ImageImporter.generatePatternMatrix(BFnameArray, secondaryChannelName);
                  
                        %try
                        if isempty(this.secondaryFocusAndQualityAnalyzerHandleArray{folder}{secondaryChannelCounter}) || isempty(this.secondaryFocusAndQualityAnalyzerHandleArray{folder}{secondaryChannelCounter}.handle)
                            this.secondaryFocusAndQualityAnalyzerHandleArray{folder}{secondaryChannelCounter} = FocusAndQualityAnalyzerHandle();
                            [secondaryNameArray, ~, secondaryMasks] = focusAndQualityAnalyzer(fullfile(this.mainDirectory, this.usedDirectories{folder}), patMatrix, [0 0], standardFocus, this.secondaryFocusAndQualityAnalyzerHandleArray{folder}(secondaryChannelCounter));
                        else
                            this.secondaryFocusAndQualityAnalyzerHandleArray{folder}{secondaryChannelCounter}.setNewPattern(pat)
                            [secondaryNameArray, ~, secondaryMasks] = focusAndQualityAnalyzer(this.secondaryFocusAndQualityAnalyzerHandleArray{folder}(secondaryChannelCounter));
                        end
                        %catch MException
    %                        save('imageImporterMaskAutosave.mat', 'this', 'BFnameArray', 'standardFocus', 'pat')
                        %end
                        
                        %% new logic
                        this = updateImageNameStructure(this, BFnameArray, secondaryNameArray, this.quantificationChannelPrefixes{secondaryChannelCounter}, folder, secondaryMasks);
                        matchEquivalents = fields(this.imageNameStructure{folder});
                        BFnameArray = cell(1, numel(matchEquivalents));
                        for fieldIndex = 1 : numel(matchEquivalents)
                            BFnameArray{fieldIndex} = this.imageNameStructure{folder}.(matchEquivalents{fieldIndex}).detectionChannelName;
                        end
                        secondaryChannelCounter = secondaryChannelCounter + 1;
                        %%
                        
%                         if numel(secondaryChannelNames) > 1
%                             nameArray = this.removeIncompatibleImages(BFnameArray, secondaryNameArray, folder, 'add', secondaryChannelCounter);
%                         elseif numel(secondaryChannelNames) == 1
%                             nameArray = this.removeIncompatibleImages(BFnameArray, secondaryNameArray, folder);
%                         end
%                         this.mergeMasks(BFnameArray, secondaryNameArray, folder, secondaryMasks);
%                         
%                         BFnameArray = ImageImporter.removeImagesFromDetectionNameArray(BFnameArray, nameArray);
%                         for indexToFix = 1 : secondaryChannelCounter
%                             this.removeIncompatibleImages(this, BFnameArray, secondaryNameArray, folder, varargin);
%                         end

                    end
                else
                    fileListArray = dir(fullfile(mainDir, this.usedDirectories{folder}, '*.tif'));
                    nameArray = cell(length(fileListArray),1);
                    for i = 1 : length(fileListArray)
                        nameArray{i} = fileListArray(i).name;
                    end
                    BFnameArray = nameArray;
                end
                
                %% reorganize the fileListArray to get all the file names

                this.wellID{folder} = cell(0,0);
                this.wellID{folder} = ImageImporter.getWellIDOfStringArray(BFnameArray, '.tif');
                this.time{folder, 1} = 0;
                this.numberOfChannels{folder} = 6;%% a standard parameter for now
                this.generateExperimentDataStructure(folder);
            end
            
            try
                this = standardizeImageNameStructure(this);
                this = wrapImageImporterToWellWiseOrganization(this);
            catch
                
            end
            
        end
        
        
        
        
        
        function unwrapImageImporterToFlatOrganization(this)
            
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
        
        function setLowerBound(this, lowerBound)
            this.lowerBound = lowerBound;
        end
        
        function setHigherBound(this, higherBound)
            this.higherBound = higherBound;
        end
        
        function mergeMasks(this, BFnameArray, secondaryNameArray, folder, secondaryMasks)
            newMaskArray = cell(1, 0);
            nameToMaskMap = containers.Map;
            
            [flatStyleCheck, nestedStyleCheck] = ImageImporter.flatAndNestedCheck(BFnameArray);
            
            if flatStyleCheck
                for imageIndex = 1 : numel(secondaryMasks)
                    nameArrayMathcEquivalent = this.generateNameArrayMatchEquivalent(secondaryNameArray(imageIndex));
                    if ~isempty(nameArrayMathcEquivalent)
                        nameToMaskMap(nameArrayMathcEquivalent{1}) = secondaryMasks{imageIndex};
                    end 
                end
                
                for imageIndex = 1 : numel(BFnameArray)
                    nameArrayMatchEquivalent = this.generateNameArrayMatchEquivalent(BFnameArray(imageIndex));
                    if ~isempty(nameArrayMatchEquivalent)
                        newMaskArray{end + 1} = or(this.masks{folder}{imageIndex}, nameToMaskMap(nameArrayMatchEquivalent{1}));
                    end
                end
            
            elseif nestedStyleCheck
            
                for wellIndex = 1 : numel(secondaryNameArray)
                    nameArrayMathcEquivalent = this.generateNameArrayMatchEquivalent({secondaryNameArray{wellIndex}});
                    for imageInWellIndex = 1 : numel(secondaryMasks{wellIndex})
                        if ~isempty(nameArrayMathcEquivalent{imageInWellIndex})
                            nameToMaskMap(nameArrayMathcEquivalent{imageInWellIndex}) = secondaryMasks{wellIndex}{imageInWellIndex};
                        end                  
                    end
                end

                for wellIndex = 1 : numel(BFnameArray)
                    goodImageCounter = 1;
                    for imageInWellIndex = 1 : numel(BFnameArray{wellIndex})
                        if ~isempty(BFnameArray{wellIndex}{imageInWellIndex})
                            try
                                nameArrayMatchEquivalent = this.generateNameArrayMatchEquivalent({{BFnameArray{wellIndex}{imageInWellIndex}}});
                                newMaskArray{wellIndex}{end + 1} = or(this.masks{folder}{wellIndex}{imageInWellIndex}, nameToMaskMap(nameArrayMatchEquivalent{1}));
                            catch
                                ''
                            end
                            goodImageCounter = goodImageCounter + 1;
                        end
                    end
                end
            end
            this.masks{folder} = newMaskArray;
        end
        
        function unwrappedNameArray = assureUnwrappedNameArray(this, nameArray)
            [flatStyleCheck, nestedStyleCheck] = ImageImporter.flatAndNestedCheck(nameArray);
            if nestedStyleCheck
                try
                    unwrappedNameArray = vertcat(nameArray{:});
                catch
                    unwrappedNameArray = horzcat(nameArray{:});
                end
            elseif flatStyleCheck
                unwrappedNameArray = nameArray;
            end
        end
        
        function nameArray = removeIncompatibleImages(this, nameArray, secondaryNameArray, folder, varargin)

            unwrappedNameArray = this.assureUnwrappedNameArray(nameArray);          
            unwrappedSecondaryNameArray = this.assureUnwrappedNameArray(secondaryNameArray);

            unwrappedNameArray = reshape(unwrappedNameArray, numel(unwrappedNameArray), 1);
            unwrappedSecondaryNameArray = reshape(unwrappedSecondaryNameArray, numel(unwrappedSecondaryNameArray), 1);
            
            nameArrayMatchEquivalent = ImageImporter.generateNameArrayMatchEquivalent(nameArray);
            secondaryNameArrayMatchEquivalent = ImageImporter.generateNameArrayMatchEquivalent(secondaryNameArray);
            
            nameArrayMatchEquivalent(cellfun(@isempty, nameArrayMatchEquivalent)) = {'first_channel_placeholder'};
            secondaryNameArrayMatchEquivalent(cellfun(@isempty, secondaryNameArrayMatchEquivalent)) = {'second_channel_placeholder'};
            
            [~, nameArrayIndices, secondaryNameArrayIndices] = intersect(nameArrayMatchEquivalent, secondaryNameArrayMatchEquivalent);
%             
%             tempNameArray = cell(0,0);
%             tempSecondaryNameArray = cell(0,0);
%             for nameIndex = 1 : numel(nameArray)
%                for secondaryNameIndex = 1 : numel(secondaryNameArray)
%                    if(strcmp(nameArray{nameIndex}(1:6), secondaryNameArray{secondaryNameIndex}(1:6)))
%                       tempNameArray{end + 1} = nameArray{nameIndex};
%                       tempSecondaryNameArray{end + 1} = secondaryNameArray{secondaryNameIndex};
%                    end
%                end
%             end
            unwrappedNameArray = unwrappedNameArray(nameArrayIndices);
            unwrappedSecondaryNameArray = unwrappedSecondaryNameArray(secondaryNameArrayIndices);
            this.nameArray{folder} = this.sortImageNames(unwrappedNameArray);

            % sort according to names
            if numel(varargin) > 1 && strcmp(varargin{1}, 'add')
                index = varargin{2};
                %% if isempty(this.secondaryNameArray) || isempty(this.secondaryNameArray{folder})
                %% new
                sortedNames = this.sortImageNames(unwrappedSecondaryNameArray);
                for imageIndex = 1 : numel(sortedNames)
                    this.secondaryNameArray{folder}{imageIndex}{index} = sortedNames{imageIndex};
                end
                
                % Find the index of the last non-empty element
                lastNonEmptyIdx = find(~cellfun('isempty', this.secondaryNameArray{folder}), 1, 'last');

                % Truncate the cell array to remove trailing empty elements
                this.secondaryNameArray{folder} = this.secondaryNameArray{folder}(1:lastNonEmptyIdx);
                %% 
                    
                    %% old
%                     sorted = this.sortImageNames(unwrappedSecondaryNameArray(secondaryNameArrayIndices));
%                     for imageIndex = 1 : numel(sorted)
%                         this.secondaryNameArray{folder}{imageIndex}{index} = sorted{imageIndex};
%                     end
                    

%                 else
%                     
%                     sorted = this.sortImageNames(unwrappedSecondaryNameArray(secondaryNameArrayIndices));
%                     for imageIndex = 1 : numel(this.secondaryNameArray{folder})
%                         this.secondaryNameArray{folder}{imageIndex}{index} = sorted{imageIndex};
%                     end
%                 end
                %% 
                
            elseif numel(varargin) > 1 && strcmp(varargin{1}, 'update')
                index = varargin{2};
                if isempty(this.secondaryNameArray{folder})
                    this.secondaryNameArray{folder} = this.sortImageNames(unwrappedSecondaryNameArray);
                else
                    sortedNames = this.sortImageNames(unwrappedSecondaryNameArray);
                    for imageIndex = numel(this.secondaryNameArray{folder}) : -1 : 1
                        try
                            this.secondaryNameArray{folder}{imageIndex}(index) = [];
                        catch MExeption
                            ''
                        end
                    end

                    
                    for imageIndex = 1 : numel(sortedNames)
                        try
                            this.secondaryNameArray{folder}{imageIndex}{index} = sortedNames{imageIndex};
                        catch MExeption
                            throw(MException);
                        end
                    end
                    % Find the index of the last non-empty element
                    lastNonEmptyIdx = find(~cellfun('isempty', this.secondaryNameArray{folder}), 1, 'last');

                    % Truncate the cell array to remove trailing empty elements
                    this.secondaryNameArray{folder} = this.secondaryNameArray{folder}(1:lastNonEmptyIdx);

                end

            elseif numel(varargin) > 0 
                this.secondaryNameArray{folder} = this.sortImageNames(unwrappedSecondaryNameArray);
                
            else              
                this.secondaryNameArray{folder} = this.sortImageNames(unwrappedSecondaryNameArray);
                
            end
            nameArray = this.sortImageNames(unwrappedNameArray);
        end
        
        function nameArray = getNameArrayOfFolder(this, folder)
            nameArray = this.nameArray{folder};
        end
        
        function nameArray = getSecondaryNameArrayOfFolder(this, folder)
            nameArray = this.secondaryNameArray{folder}; 
        end
        
        function generateExperimentDataStructure(this, folder)
            this.experimentDataStructure{folder}.wellID = this.wellID{folder}';
            this.experimentDataStructure{folder}.channelNames = {''};
            this.experimentDataStructure{folder}.numberOfChannels = 1;
            this.experimentDataStructure{folder}.cycleTime = 0;
            this.experimentDataStructure{folder}.readingDirection = -1;
            this.experimentDataStructure{folder}.timeOfMeasurements = zeros(length(this.usedDirectories), 1);
            this.experimentDataStructure{folder}.temperature = 0;
            this.experimentDataStructure{folder}.measurements = {0};
            
        end
        
        function generateExperimentDataStructureForObservation(this, folder)
            wellID = this.fixWellID(this.allImportedWellID);
            this.experimentDataStructure{folder}.wellID = wellID{1}';
            this.experimentDataStructure{folder}.channelNames = {''};
            this.experimentDataStructure{folder}.numberOfChannels = 1;
            this.experimentDataStructure{folder}.cycleTime = 0;
            this.experimentDataStructure{folder}.readingDirection = -1;
            this.experimentDataStructure{folder}.timeOfMeasurements = zeros(length(this.usedDirectories), 1);
            this.experimentDataStructure{folder}.temperature = 0;
            this.experimentDataStructure{folder}.measurements = {0};
            
        end
        
        function finalFixedWellID = fixWellID(this, originalWellID)
            newList = cell(0, 0);
            fixedWellID = cell(0, 0);
            for index = 1 : numel(originalWellID)
               if ~isempty(originalWellID{index})
                   newList = [newList, originalWellID(index)]; 
               end
            end
            for index = 1 : numel(newList)
               fixedWellID = [fixedWellID; newList{index}]; 
            end
            finalFixedWellID = {unique(fixedWellID)};
        end
        
        function dataStructure = getDataStructure(this)
            dataStructure = this.experimentDataStructure{1};
        end
        
        function dataStructure = getDataStructureOfFolder(this, folder)
            dataStructure = this.experimentDataStructure{folder}; 
        end
        
        function numberOfUsedDirectories = getNumberOfUsedDirectories(this)
            numberOfUsedDirectories = numel(this.usedDirectories);
        end
        
        function usedDirectories = getUsedDirectories(this)
            usedDirectories = this.usedDirectories;
        end
        
        function directoryName = getUsedDirectoryWithIndex(this, index)
            directoryName = this.usedDirectories{index};
        end
        
        function filePath = getFilePathOfDirectoryWithIndex(this, folderIndex)
            %filePath = [this.mainDirectory,'\',this.usedDirectories{folderIndex},'\'];
            filePath = [this.mainDirectory,'\',this.usedDirectories{folderIndex}];
        end
        
        function wellID = getWellID(this)
           wellID = this.wellID; 
        end
        
        function getNewObservationSet(this)
            load plate96WellLayout
            ID = reshape(plate96WellLayout, 1, 96);
            fileListArray = dir([this.mainDirectory, '\', this.usedDirectories{1}, '\*.tif']);
            
            nameArray = cell(length(fileListArray),1);
            for i = 1 : length(fileListArray)
                nameArray{i} = fileListArray(i).name;
            end
            for analyzedImage = 1 : numel(this.analyzedImages)
                if ~isempty(find(strcmp(nameArray, this.analyzedImages{analyzedImage})==1, 1))
                    nameArray(find(strcmp(nameArray, this.analyzedImages{analyzedImage})==1, 1)) = [];
                end
            end
            this.analyzedImages = [this.analyzedImages,  nameArray'];
            this.wellID{1} = cell(0,0);
            for well = 1 : length(ID)
                 for pic = 1 : numel(nameArray)
                     if isequal(numel(ID{well}), 3)
                         secondType = [ID{well}(1), ID{well}(3)];
                     else
                         secondType = ID{well};
                     end
                     if ~isequal(strfind(nameArray{pic}, ID{well}), []) || ~isequal(strfind(nameArray{pic}, secondType), [])
                         if ~isequal(strfind(nameArray{pic}, secondType), [])
                             index = strfind(nameArray{pic}, secondType);
                             if  numel(nameArray{pic}) >= index+2 && ~isempty(str2num(nameArray{pic}(index+2))) % to avoid matches like A1 in something like A10_ we check that a number is not follwing
                                break;
                             end
                         end
                         if isequal(sum(cell2mat(strfind(this.wellID{1}, ID{well}))), 0)
                            this.wellID{1}{end + 1,1} = ID{well};
                         end
                         
                     end
                 end
            end
            this.time{1, 1} = 0;
            this.numberOfChannels{1} = 6;%% a standard parameter for now
            this.generateExperimentDataStructure(1);
            this.allImportedWellID{1} = unique([this.allImportedWellID{1}; this.wellID{1}]);
            this.generateExperimentDataStructureForObservation(1);
            
        end
        
        
        function wellID = getAllImportedWellID(this)
            wellID = this.allImportedWellID;
        end
        
    end
    
    methods(Static)
        
        
        function [flatStyleCheck, nestedStyleCheck] = flatAndNestedCheck(nameArray)
            flatStyleCheck = true;
            nestedStyleCheck = true;
            for nameIndex = 1 : numel(nameArray)
                if ~ischar(nameArray{nameIndex})
                    flatStyleCheck = false;
                end
                if ~iscell(nameArray{nameIndex})
                    nestedStyleCheck = false;
                end                 
            end
        end
        
        function detectionNameArray = removeImagesFromDetectionNameArray(detectionNameArray, suitableNameArray)
            
            [flatStyleCheck, nestedStyleCheck] = ImageImporter.flatAndNestedCheck(detectionNameArray);
            
            if flatStyleCheck
                
                suitableMatchEquivalent = ImageImporter.generateNameArrayMatchEquivalent(suitableNameArray);
                suitableDetectionNameArray = cell(1, 0);
                counter = 1;
                for nameIndex = 1 : numel(detectionNameArray)
                    matchEquivalentCell = ImageImporter.generateNameArrayMatchEquivalent({detectionNameArray{nameIndex}});
                    if ~isempty(intersect(suitableMatchEquivalent, matchEquivalentCell))
                        suitableDetectionNameArray{1, counter} = detectionNameArray{nameIndex};
                        counter = counter + 1;
                    end
                end
                detectionNameArray = suitableDetectionNameArray;
            elseif nestedStyleCheck
                for nameIndex = 1 : numel(detectionNameArray)
                    for imageInWellIndices = 1 : numel(detectionNameArray{nameIndex})
                        safe = false;
                        for name = suitableNameArray
                            if isequal(detectionNameArray{nameIndex}{imageInWellIndices}, name{1})
                               safe = true;
                            end
                        end
                        if ~safe
                            detectionNameArray{nameIndex}{imageInWellIndices} = [];
                        end
                    end
                end
            end
        end
        
        
        function [patternMatrix, pattern] = generatePatternMatrix(nameArray, secondaryChannelName)
            pattern = '^(';
            patternMatrix = cell(0, 3);
            
            flatStyleCheck = true;
            nestedStyleCheck = true;
            for nameIndex = 1 : numel(nameArray)
                if ~ischar(nameArray{nameIndex})
                    flatStyleCheck = false;
                end
                if ~iscell(nameArray{nameIndex})
                    nestedStyleCheck = false;
                end                 
            end
            if flatStyleCheck
                nameArray = {nameArray};
                nestedStyleCheck = true
            end
            if nestedStyleCheck
                for nameIndex = 1 : numel(nameArray)
                    for imageInWellIndices = 1 : numel(nameArray{nameIndex})
                        if ~isempty(nameArray{nameIndex}{imageInWellIndices})
                            wellID = ImageImporter.findWellIDOfString(nameArray{nameIndex}{imageInWellIndices});
                            imageInWellIndex = num2str(ImageImporter.getImageInWellIndexOfString(nameArray{nameIndex}{imageInWellIndices}));
                            %pat = [pat, wellID, '_\d{1,2}_\d{1}_', imageInWellIndex, '(Z|_)|'];
                            pattern = [pattern, wellID, '_\d{1,2}_\d{1}_', imageInWellIndex, '|'];
                            patternMatrix{end+1, 1} = wellID;
                            patternMatrix{end, 2} = imageInWellIndex;
                            patternMatrix{end, 3} = secondaryChannelName;
                        end                           
                    end
                end

                pattern(end) = [];
                pattern = [pattern,')(\w*)', secondaryChannelName];
            end
        end
        
        function nameArrayMatchEquivalent = generateNameArrayMatchEquivalent(nameArray)
            
            flatStyleCheck = true;
            nestedStyleCheck = true;
            for nameIndex = 1 : numel(nameArray)
                if ~ischar(nameArray{nameIndex})
                    flatStyleCheck = false;
                end
                if ~iscell(nameArray{nameIndex})
                    nestedStyleCheck = false;
                end                 
            end
            if nestedStyleCheck
                try
                    unwrappedNameArray = vertcat(nameArray{:});
                catch
                    unwrappedNameArray = horzcat(nameArray{:});
                end
            elseif flatStyleCheck
                unwrappedNameArray = nameArray;
            end
            unwrappedNameArray = reshape(unwrappedNameArray, numel(unwrappedNameArray), 1);
            nameArrayMatchEquivalent = cell(numel(unwrappedNameArray), 1);         
            for nameIndex = 1 : numel(unwrappedNameArray)
                if isempty(unwrappedNameArray{nameIndex})
                    nameArrayMatchEquivalent{nameIndex} = [];
                else
                    nameArrayMatchEquivalent{nameIndex} = [ImageImporter.findWellIDOfString(unwrappedNameArray{nameIndex}), '_', num2str(ImageImporter.getImageInWellIndexOfString(unwrappedNameArray{nameIndex}))];
                end
            end
        end
        
        function wellID = getWellIDOfStringArray(nameArray, pattern)
            wellID = cell(0,0);
            for pic = numel(nameArray) : -1 : 1
                 pic
                 if ~isempty(regexp(nameArray{pic}, pattern, 'once'))

                 else
                     nameArray(pic) = [];
                 end
            end
            for pic = 1 : numel(nameArray)
                wellID{end+1} = regexp(nameArray{pic},'([A-Z]{1,2}\d{1,2})', 'match', 'once');
            end
            wellID = ImageImporter.sortWellID(wellID)';        
        end
        
        function wellID = findWellIDOfString(name)
            wellID = regexp(name,'[A-Z]*\d{1,3}', 'match', 'once');
        end
        
        function imageInWellIndex = getImageInWellIndexOfString(name)
            underscoreIndices = strfind(name,'_');
            imageInWellIndex = str2double(regexp(name(underscoreIndices(3) + 1:end),'(\d{1,3})', 'match', 'once'));
            %imageInWellIndex = str2double(regexp(regexp(name,'(_\d{1,2}Z)', 'match', 'once'), '(\d{1,3})', 'match', 'once'));
        end
        
        function imagePlaneIndex = getImagePlaneIndexOfString(name)
           imagePlaneIndex = str2double(regexp(regexp(regexp(name,'(_\d{1,2}Z\d{1,2})', 'match', 'once'), '(Z\d{1,3})', 'match', 'once'), '(\d{1,3})', 'match', 'once'));
           if isnan(imagePlaneIndex) % in case plane is not present, treat it as if it was Z0
               imagePlaneIndex = 0; 
           end
        end
        
        function imageChannel = getImageChannelNameOfString(name)
            imageChannel = regexp(regexp(name,'[a-zA-Z0-9, \s]*_\d{0,3}.tif', 'match', 'once'), '[a-zA-Z0-9, \s]*', 'match', 'once');
        end
        
        function wellID = sortWellID(wellID)% sorts the cell array according to cell naming logic instead of standard string and number logic. 
            oneLetterArray = cell(0,0);
            twoLetterArray = cell(0,0);
            swapBackWells = cell(0,0);
            swapBackOriginals = cell(0,0);
            for i = 1 : numel(wellID)
                if isequal(numel(regexp(wellID{i},'([A-Z]{1,2})', 'match', 'once')), 1) && isequal(numel(regexp(wellID{i},'([0-9]{1,2})', 'match', 'once')), 2)
                    oneLetterArray{end + 1} = wellID{i};
                elseif isequal(numel(regexp(wellID{i},'([A-Z]{1,2})', 'match', 'once')), 2) && isequal(numel(regexp(wellID{i},'([0-9]{1,2})', 'match', 'once')), 2)
                    twoLetterArray{end + 1} = wellID{i};
                elseif isequal(numel(regexp(wellID{i},'([A-Z]{1,2})', 'match', 'once')), 1) && isequal(numel(regexp(wellID{i},'([0-9]{1,2})', 'match', 'once')), 1)
                    oneLetterArray{end + 1} = [wellID{i}(1), '0',wellID{i}(2)];
                    swapBackWells{end + 1} = [wellID{i}(1), '0',wellID{i}(2)];
                    swapBackOriginals{end + 1} = wellID{i}; 
                elseif isequal(numel(regexp(wellID{i},'([A-Z]{1,2})', 'match', 'once')), 2) && isequal(numel(regexp(wellID{i},'([0-9]{1,2})', 'match', 'once')), 1)
                    twoLetterArray{end + 1} = [wellID{i}(1:2), '0',wellID{i}(3)];
                    swapBackWells{end + 1} = [wellID{i}(1:2), '0',wellID{i}(3)];
                    swapBackOriginals{end + 1} = wellID{i}; 
                end
            end
            swapBackWells = unique(swapBackWells, 'stable');
            swapBackOriginals = unique(swapBackOriginals, 'stable');
            oneLetterArray = natsort(unique(oneLetterArray));
            twoLetterArray = natsort(unique(twoLetterArray));
            
            %oneLetterArray = unique(oneLetterArray);
            %twoLetterArray = unique(twoLetterArray);
            wellID = [oneLetterArray, twoLetterArray];
            for index = 1 : numel(swapBackWells)
                swapIndex = strcmp(wellID, swapBackWells(index));
                wellID{swapIndex} = swapBackOriginals{index};
            end
        end

        function imageNames = sortImageNames(imageNames)% sorts the cell array according to cell naming logic instead of standard string and number logic. 
            oneLetterArray = cell(0,0);
            twoLetterArray = cell(0,0);
            swapBackWells = cell(0,0);
            swapBackOriginals = cell(0,0);
            for i = 1 : numel(imageNames)
                if isequal(numel(regexp(imageNames{i},'([A-Z]{1,2})', 'match', 'once')), 1) && isequal(numel(regexp(imageNames{i},'([0-9]{1,2})', 'match', 'once')), 2)
                    oneLetterArray{end + 1} = imageNames{i};
                elseif isequal(numel(regexp(imageNames{i},'([A-Z]{1,2})', 'match', 'once')), 2) && isequal(numel(regexp(imageNames{i},'([0-9]{1,2})', 'match', 'once')), 2)
                    twoLetterArray{end + 1} = imageNames{i};
                elseif isequal(numel(regexp(imageNames{i},'([A-Z]{1,2})', 'match', 'once')), 1) && isequal(numel(regexp(imageNames{i},'([0-9]{1,2})', 'match', 'once')), 1)
                    oneLetterArray{end + 1} = [imageNames{i}(1), '0',imageNames{i}(2:end)];
                    swapBackWells{end + 1} = [imageNames{i}(1), '0',imageNames{i}(2:end)];
                    swapBackOriginals{end + 1} = imageNames{i}; 
                elseif isequal(numel(regexp(imageNames{i},'([A-Z]{1,2})', 'match', 'once')), 2) && isequal(numel(regexp(imageNames{i},'([0-9]{1,2})', 'match', 'once')), 1)
                    twoLetterArray{end + 1} = [imageNames{i}(1:2), '0',imageNames{i}(3:end)];
                    swapBackWells{end + 1} = [imageNames{i}(1:2), '0',imageNames{i}(3:end)];
                    swapBackOriginals{end + 1} = imageNames{i}; 
                end
            end
            oneLetterArray = natsort(oneLetterArray);
            twoLetterArray = natsort(twoLetterArray);
            
            %oneLetterArray = unique(oneLetterArray);
            %twoLetterArray = unique(twoLetterArray);
            imageNames = [oneLetterArray, twoLetterArray];
            for index = 1 : numel(swapBackWells)
                swapIndex = strcmp(imageNames, swapBackWells(index));
                imageNames{swapIndex} = swapBackOriginals{index};
            end
        end
        
        function wellID = sortWellNumbers(wellID) % this function will not sort the wellID-s by name, use sortWellID for sorting both ways
            wellIndices = zeros(numel(wellID), 1);
            for i = 1 : numel(wellID)
                wellIndices(i) = str2double(regexp(wellID{i},'(\d{1,2})', 'match', 'once'));
            end
            [unneeded, indices] = sort(wellIndices);
            wellID = wellID(indices);
        end
        
        function [wellIDs, wellID_ImageLocations] = getWellIDOfArray(nameArray, pattern)
            wellIDs = cell(0,0);
            for pic = 1 : numel(nameArray)
                try
                    wellIDs{end+1} = regexp(nameArray{pic},'([A-Z]{1,2}\d{1,2})', 'match', 'once');
                catch
                    ''
                end
            end
            
            wellIDs = ImageImporter.sortWellID(wellIDs)';
            wellID_ImageLocations = cell(numel(wellIDs), 1);
            
            for pic = 1 : numel(nameArray)
               wellID = regexp(nameArray{pic},'([A-Z]{1,2}\d{1,2})', 'match', 'once');
               wellID = ImageImporter.sortWellID({wellID});
               imageLocationIndex = ImageImporter.getImageInWellIndexOfString(nameArray{pic});
               index = find(strcmp(wellIDs, wellID{1}));
               wellID_ImageLocations{index} = [wellID_ImageLocations{index}, imageLocationIndex];
            end
            
            for index = 1 : numel(wellID_ImageLocations)
                wellID_ImageLocations{index} = unique(wellID_ImageLocations{index});
            end
        end
        
        function [wellIDs, wellID_ImageLocations, varargout] = getWellIDOfFolder(folder, pattern)
            fileListArray = dir([folder, '\*.tif']);

            %% reorganize the fileListArray to get all the file names

            patMatrix = cell(length(fileListArray), 3);
            nameArray = cell(length(fileListArray),1);
            for i = 1 : length(fileListArray)
                nameArray{i} = fileListArray(i).name;
                if ~ischar(pattern)
                    patMatrix{i, 1} = ImageImporter.findWellIDOfString(fileListArray(i).name);
                    patMatrix{i, 2} = num2str(ImageImporter.getImageInWellIndexOfString(fileListArray(i).name));
                    patMatrix{i, 3} = ImageImporter.getImageChannelNameOfString(fileListArray(i).name);
                end
            end
            if ~ischar(pattern)
                ia = ismember(cell2table(patMatrix, 'VariableNames', {'A', 'B', 'C'}), cell2table(pattern, 'VariableNames', {'A', 'B', 'C'}));
                nameArray = nameArray(ia);
            else
           
                for pic = numel(nameArray) : -1 : 1
                    pic
                    if ~isempty(regexp(nameArray{pic}, pattern, 'once'))

                    else
                        nameArray(pic) = [];
                    end
                end
            end
            wellIDs = cell(0,0);
            for pic = 1 : numel(nameArray)
                wellIDs{end+1} = regexp(nameArray{pic},'([A-Z]{1,2}\d{1,2})', 'match', 'once');
            end
            
            wellIDs = ImageImporter.sortWellID(wellIDs)';
            wellID_ImageLocations = cell(numel(wellIDs), 1);
            
            for pic = 1 : numel(nameArray)
               wellID = regexp(nameArray{pic},'([A-Z]{1,2}\d{1,2})', 'match', 'once');
               wellID = ImageImporter.sortWellID({wellID});
               imageLocationIndex = ImageImporter.getImageInWellIndexOfString(nameArray{pic});
               index = find(strcmp(wellIDs, wellID{1}));
               wellID_ImageLocations{index} = [wellID_ImageLocations{index}, imageLocationIndex];
            end
            
            for index = 1 : numel(wellID_ImageLocations)
                wellID_ImageLocations{index} = unique(wellID_ImageLocations{index});
            end
            varargout{1} = nameArray;
            
        end
        
        function focusNames = organizeImageNameArrayByWells(nameArray, pattern)
            wellID = ImageImporter.getWellIDOfStringArray(nameArray, '.tif');
            [handles.wellID, wellID_location_indices] = ImageImporter.getWellIDOfArray(nameArray, pattern);
            %handles.focusImageNames = nameArray;
            for pic = 1 : numel(nameArray)
                wellIDName = ImageImporter.findWellIDOfString(nameArray{pic});
                wellIDIndex = strcmp(wellID, wellIDName);
                imagingLocation = ImageImporter.getImageInWellIndexOfString(nameArray{pic});
                imagingLocationIndex = wellID_location_indices{wellIDIndex} == imagingLocation;    
                focusNames{wellIDIndex}{imagingLocationIndex, 1} = nameArray{pic};
            end
        end
        
        function [masks, wellIDOut, focusNames] = loadMasks(nameArray, imageDir, pattern)
            [handles.wellID, wellID_location_indices] = ImageImporter.getWellIDOfArray(nameArray, pattern);
            files = dir(imageDir);
            try
                files(1:2) = [];
            catch MException
                rethrow(MException)
            end
            nameArray = cell(0, 0);
            for index = 1 : numel(files)
                if ~isempty(strfind(files(index).name, '.tif'))
                    nameArray{end+1} = files(index).name;
                end
            end
            %nameArray = ImageImporter.sortWellID(nameArray);
            masks = cell(numel(nameArray), 1);
            for index = 1 : numel(nameArray)
                masks{index} = imread([imageDir, '\', nameArray{index}]);
            end

            %answer = questdlg('Do you want to remove images, that do not have a mask?');
            %if strcmp(answer, 'Yes')
            wellID = ImageImporter.getWellIDOfStringArray(nameArray, '.tif');
            %handles.focusImageNames = nameArray;
            for pic = 1 : numel(masks)
                wellIDName = ImageImporter.findWellIDOfString(nameArray{pic});
                wellIDIndex = strcmp(wellID, wellIDName);
                imagingLocation = ImageImporter.getImageInWellIndexOfString(nameArray{pic});
                imagingLocationIndex = wellID_location_indices{wellIDIndex} == imagingLocation;    
                handles.masks{wellIDIndex}{imagingLocationIndex} = masks{pic};
                focusNames{wellIDIndex}{imagingLocationIndex, 1} = nameArray{pic};
            end


            indices = zeros(numel(wellID), 1);
            for index = 1 : numel(wellID)
                indices(index) = find(strcmp(handles.wellID, wellID{index}) == 1);
            end
            wellIDOut = handles.wellID(indices);
            handles.masks = handles.masks(indices);

            masks = handles.masks;
        end
    end  
end

