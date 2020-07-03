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
        analyzedImages = {''};
        analyzeQuality = 0;
        nameArray = [];
        secondaryNameArray = []
        masks = [];
        maskNameArray = [];
        detectionChannelRegex = 'Bright Field';
        quantificationChannelRegex = 'RFP';
        lowerBound = 2; % 2 is default value for Quantitative analysis of fluorescent ligand binding to dopamine D3 receptors using live cell microscopy.
        higherBound = 5; % 5 is default value for Quantitative analysis of fluorescent ligand binding to dopamine D3 receptors using live cell microscopy.
    end
    
    methods
        function this = ImageImporter()
            
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
                answer = questdlg('This folder contains no subfolders, did you mean to analyze the selected folder?', 'question', 'Yes', 'No', 'Yes')
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
            end
            %% Save the directory names that were selected

            
            this.usedDirectories = chosenDirectories;
            %% store all the filenames needed for the calculations
            % loop through all the folders

            % get well ID-s
            load plate96WellLayout
            ID = reshape(plate96WellLayout,1,96);
            
            
            this.nameArray = cell(length(chosenDirectories), 1);
            this.experimentDataStructure = cell(length(chosenDirectories), 1);
            this.masks = cell(length(chosenDirectories), 1);
            for folder = 1 : length(chosenDirectories)
                
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

                    [BFnameArray, standardFocus, this.masks{folder}] = focusAndQualityAnalyzer([mainDir,'\',chosenDirectories{folder}], this.detectionChannelRegex, [this.lowerBound this.higherBound]);
                    this.maskNameArray{folder} = BFnameArray;
                    %create a more sophisticated pattern
                    pat = '^(';             

                    for nameIndex = 1 : numel(BFnameArray)
                        for imageInWellIndes = 1 : numel(BFnameArray{nameIndex})
                            if ~isempty(BFnameArray{nameIndex}{imageInWellIndes})
                                wellID = ImageImporter.findWellIDOfString(BFnameArray{nameIndex}{imageInWellIndes});
                                imageInWellIndex = num2str(ImageImporter.getImageInWellIndexOfString(BFnameArray{nameIndex}{imageInWellIndes}));
                                pat = [pat, wellID, '_\d{1,2}_\d{1}_', imageInWellIndex, '(Z|_)|'];
                            end                           
                        end
                    end                
                    % remove last | character to correct the pattern
                    pat(end) = [];
                    pat = [pat,')(\w*)', this.quantificationChannelRegex];
                    
                    try
                        secondaryNameArray = focusAndQualityAnalyzer([mainDir,'\',chosenDirectories{folder}], pat, [0 0], standardFocus);
                    catch MException
                        save('imageImporterMaskAutosave.mat', 'this', 'BFnameArray', 'standardFocus', 'pat')
                    end
                    nameArray = this.removeIncompatibleImages(BFnameArray, secondaryNameArray, folder);
                else
                    fileListArray = dir([mainDir,'\',chosenDirectories{folder},'\*.tif']);
                    nameArray = cell(length(fileListArray),1);
                    for i = 1 : length(fileListArray)
                        nameArray{i} = fileListArray(i).name;
                    end
                end
                
                %% reorganize the fileListArray to get all the file names

                this.wellID{folder} = cell(0,0);
                this.wellID{folder} = ImageImporter.getWellIDOfStringArray(nameArray, '.tif');
                this.time{folder, 1} = 0;
                this.numberOfChannels{folder} = 6;%% a standard parameter for now
                this.generateExperimentDataStructure(folder);
            end
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
        
        
        
        function nameArray = removeIncompatibleImages(this, nameArray, secondaryNameArray, folder)

            unwrappedNameArray = vertcat(nameArray{:});
            unwrappedSecondaryNameArray = vertcat(secondaryNameArray{:});
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
            this.nameArray{folder} = unwrappedNameArray(sort(nameArrayIndices));
            this.secondaryNameArray{folder} = unwrappedSecondaryNameArray(sort(secondaryNameArrayIndices));
            nameArray = unwrappedNameArray(sort(nameArrayIndices));
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
            filePath = [this.mainDirectory,'\',this.usedDirectories{folderIndex},'\'];
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
        
        function nameArrayMatchEquivalent = generateNameArrayMatchEquivalent(nameArray)
            unwrappedNameArray = vertcat(nameArray{:});            
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
            wellIDCell = ImageImporter.getWellIDOfStringArray({name}, '[A-Z]{1,100}');
            wellID = wellIDCell{1};
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
        
        function wellID = sortWellID(wellID)% sorts the cell array according to cell naming logic instead of standard string and number logic. 
            oneLetterArray = cell(0,0);
            twoLetterArray = cell(0,0);
            swapBackWells = cell(0,0);
            swapBackOriginals = cell(0,0);
            for i = 1 : numel(wellID)
                if isequal(numel(regexp(wellID{i},'([A-Z]{1,2})', 'match', 'once')), 1) && isequal(numel(regexp(wellID{i},'([0-9]{1,2})', 'match', 'once')), 2);
                    oneLetterArray{end + 1} = wellID{i};
                elseif isequal(numel(regexp(wellID{i},'([A-Z]{1,2})', 'match', 'once')), 2) && isequal(numel(regexp(wellID{i},'([0-9]{1,2})', 'match', 'once')), 2);
                    twoLetterArray{end + 1} = wellID{i};
                elseif isequal(numel(regexp(wellID{i},'([A-Z]{1,2})', 'match', 'once')), 1) && isequal(numel(regexp(wellID{i},'([0-9]{1,2})', 'match', 'once')), 1);
                    oneLetterArray{end + 1} = [wellID{i}(1), '0',wellID{i}(2)];
                    swapBackWells{end + 1} = [wellID{i}(1), '0',wellID{i}(2)];
                    swapBackOriginals{end + 1} = wellID{i}; 
                elseif isequal(numel(regexp(wellID{i},'([A-Z]{1,2})', 'match', 'once')), 2) && isequal(numel(regexp(wellID{i},'([0-9]{1,2})', 'match', 'once')), 1);
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

        function wellID = sortWellNumbers(wellID) % this function will not sort the wellID-s by name, use sortWellID for sorting both ways
            wellIndices = zeros(numel(wellID), 1);
            for i = 1 : numel(wellID)
                wellIndices(i) = str2double(regexp(wellID{i},'(\d{1,2})', 'match', 'once'));
            end
            [unneeded, indices] = sort(wellIndices);
            wellID = wellID(indices);
        end
        

        
        function [wellIDs, wellID_ImageLocations] = getWellIDOfFolder(folder, pattern)
            fileListArray = dir([folder, '\*.tif']);

            %% reorganize the fileListArray to get all the file names

            nameArray = cell(length(fileListArray),1);
            for i = 1 : length(fileListArray)
                nameArray{i} = fileListArray(i).name;
            end
            wellIDs = cell(0,0);

            for pic = numel(nameArray) : -1 : 1
                 if ~isempty(regexp(nameArray{pic}, pattern, 'once'))

                 else
                     nameArray(pic) = [];
                 end
            end

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
            
        end
    end  
end

