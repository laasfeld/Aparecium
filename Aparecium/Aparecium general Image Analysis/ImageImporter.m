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
    end
    
    methods
        function this = ImageImporter()
            
        end
        
        function userChooseImageFolders(this)

            mainDir = uigetdir('','Choose the folder which contains folders with all the image files for all the timepoints');

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

                    [BFnameArray, standardFocus, this.masks{folder}] = focusAndQualityAnalyzer([mainDir,'\',chosenDirectories{folder}], 'Bright Field', [2 5]);
                    
                    %create a more sophisticated pattern
                    pat = '^(';
                    nameIndex = 1;
                    if numel(BFnameArray) > 1
                        for nameIndex = 1 : numel(BFnameArray)-1
                            if(BFnameArray{nameIndex}(4) == '_')
                                pat = [pat, BFnameArray{nameIndex}(1:3),'|'];
                            else
                                pat = [pat, BFnameArray{nameIndex}(1:4),'|'];
                            end
                        end
                    end
                    if(BFnameArray{nameIndex}(4) == '_')
                        pat = [pat, BFnameArray{end}(1:3), ')(\w*)RFP'];
                    else
                        pat = [pat, BFnameArray{end}(1:4), ')(\w*)RFP'];
                    end
                    %this.nameArray{folder} = BFnameArray;
                    %nameArray = BFnameArray;
                    %for index = 1 : numel(BFnameArray)
                    %   this.secondaryNameArray{folder}{index} = regexprep(BFnameArray{index}, 'Bright Field', 'RFP'); 
                    %end
                    try
                        secondaryNameArray = focusAndQualityAnalyzer([mainDir,'\',chosenDirectories{folder}], pat,[0 0], standardFocus);
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
%                 for well = 1 : length(ID)
%                      for pic = 1 : numel(nameArray)
%                          if isequal(numel(ID{well}), 3) && isequal(strcmp(ID{well}(2), '0'), 1)
%                             secondType = [ID{well}(1), ID{well}(3)];
%                          else
%                             secondType = ID{well};
%                          end
%                          if ~isequal(strfind(nameArray{pic}, ID{well}), [])
%                              index = strfind(nameArray{pic}, ID{well}) + numel(ID{well});
%                              if strcmp(nameArray{pic}(index), '_')
%                                  if isequal(sum(cell2mat(strfind(this.wellID{folder}, ID{well}))),0)
%                                     this.wellID{folder}{end+1,1} = ID{well};
%                                     break;
%                                  end
%                              end
%                          elseif ~isequal(strfind(nameArray{pic}, secondType), [])
%                              index = strfind(nameArray{pic}, ID{well}) + numel(ID{well});
%                              if strcmp(nameArray{pic}(index), '_')
%                                  if isequal(sum(cell2mat(strfind(this.wellID{folder}, ID{well}))),0)
%                                     this.wellID{folder}{end+1,1} = secondType;
%                                     break;
%                                  end
%                              end
%                          end
%                      end
%                 end
                this.time{folder, 1} = 0;
                this.numberOfChannels{folder} = 6;%% a standard parameter for now
                this.generateExperimentDataStructure(folder);
            end
        end
        
        function nameArray = removeIncompatibleImages(this, nameArray, secondaryNameArray, folder)
            tempNameArray = cell(0,0);
            tempSecondaryNameArray = cell(0,0);
            for nameIndex = 1 : numel(nameArray)
               for secondaryNameIndex = 1 : numel(secondaryNameArray)
                   if(strcmp(nameArray{nameIndex}(1:6), secondaryNameArray{secondaryNameIndex}(1:6)))
                      tempNameArray{end + 1} = nameArray{nameIndex};
                      tempSecondaryNameArray{end + 1} = secondaryNameArray{secondaryNameIndex};
                   end
               end
            end
            this.nameArray{folder} = tempNameArray;
            this.secondaryNameArray{folder} = tempSecondaryNameArray;
            nameArray = tempNameArray;
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
                    twoLetterArray{end + 1} = [wellID{i}(1:2), '0',wellID{i}(2)];
                    swapBackWells{end + 1} = [wellID{i}(1), '0',wellID{i}(2)];
                    swapBackOriginals{end + 1} = wellID{i}; 
                end
            end
            swapBackWells = unique(swapBackWells);
            oneLetterArray = ImageImporter.sortWellNumbers(unique(oneLetterArray));
            twoLetterArray = ImageImporter.sortWellNumbers(unique(twoLetterArray));
            
            oneLetterArray = unique(oneLetterArray);
            twoLetterArray = unique(twoLetterArray);
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
        
        function wellID = getWellIDOfStringArrayOld(nameArray, pattern)
            load plate96WellLayout

            a = ExtendedRowLabels;
            for i = 1 : numel(a);
                for j = 1 : 48
                    if j < 10
                        plate96WellLayout{j, i} = [a{i},'0', num2str(j)];
                    else
                        plate96WellLayout{j, i} = [a{i}, num2str(j)];
                    end
                end
            end
            ID = reshape(plate96WellLayout,1,numel(plate96WellLayout));

            wellID = cell(0,0);

            for pic = size(nameArray,1) : -1 : 1
                 if ~isempty(regexp(nameArray{pic}, pattern, 'once'))

                 else
                     nameArray(pic) = [];
                 end
            end

            for well = 1 : length(ID)
                well
                 if isequal(numel(ID{well}), 3) && isequal(strcmp(ID{well}(2), '0'), 1)
                    secondType = [ID{well}(1), ID{well}(3)];
                 elseif isequal(numel(ID{well}), 4) && isequal(strcmp(ID{well}(3), '0'), 1)
                    secondType = [ID{well}(1:2), ID{well}(4)]; 
                 else
                    secondType = ID{well};
                 end

                 for pic = 1 : numel(nameArray)
                     if ~isequal(strfind(nameArray{pic}, ID{well}), []) 
                         if isequal(sum(cell2mat(strfind(wellID, ID{well}))),0) % make sure that the well is unique
                            index = strfind(nameArray{pic}, ID{well});
                            if isequal(index(1), 1) % make sure that the found match is at the start of the name, otherwise it indicates Z stack and this is not a match
                                wellID{end+1,1} = ID{well};
                                nameArray(~cellfun(@isempty, strfind(nameArray, ID{well}))) = [];
                                break;
                            else
                                'siin'
                            end
                         end
                     elseif ~isequal(strfind(nameArray{pic}, secondType), [])
                          if ~isequal(strfind(nameArray{pic}, secondType), [])
                             index = strfind(nameArray{pic}, secondType);
                             if ~isequal(index(1), 1) % make sure that the found match is at the start of the name, otherwise it indicates Z stack and this is not a match
                                 continue;
                             else
                                 'siin'
                             end
                             wellNameLenghtParam = numel(ID{well}) - 1;
                             if  numel(nameArray{pic}) >= index + wellNameLenghtParam && ~isempty(str2num(nameArray{pic}(index + wellNameLenghtParam))) % to avoid matches like A1 in something like A10_ we check that a number is not following
                                continue;
                             end
                         end
                         if isequal(sum(cell2mat(strfind(wellID, ID{well}))),0)
                            wellID{end+1,1} = secondType;
                            break;
                         end
                     end                         
                 end
            end
        end
        
        function wellID = getWellIDOfFolder(folder, pattern)
            fileListArray = dir([folder, '\*.tif']);

            %% reorganize the fileListArray to get all the file names

            nameArray = cell(length(fileListArray),1);
            for i = 1 : length(fileListArray)
                nameArray{i} = fileListArray(i).name;
            end
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
        
        function wellID = getWellIDOfFolderOld(folder, pattern) % this function has been replaced by a new one which is more general and around 10 times faster
                load plate96WellLayout
            
                a = ExtendedRowLabels;
                for i = 1 : numel(a);
                    for j = 1 : 48
                        if j < 10
                            plate96WellLayout{j, i} = [a{i},'0', num2str(j)];
                        else
                            plate96WellLayout{j, i} = [a{i}, num2str(j)];
                        end
                    end
                end
                ID = reshape(plate96WellLayout,1,numel(plate96WellLayout));
                
                fileListArray = dir([folder, '\*.tif']);

                %% reorganize the fileListArray to get all the file names

                nameArray = cell(length(fileListArray),1);
                for i = 1 : length(fileListArray)
                    nameArray{i} = fileListArray(i).name;
                end
                wellID = cell(0,0);
                
                for pic = size(nameArray,1) : -1 : 1
                     if ~isempty(regexp(nameArray{pic}, pattern, 'once'))
                         
                     else
                         nameArray(pic) = [];
                     end
                end
                
                for well = 1 : length(ID)
                    %well
                     if isequal(numel(ID{well}), 3) && isequal(strcmp(ID{well}(2), '0'), 1)
                        secondType = [ID{well}(1), ID{well}(3)];
                     elseif isequal(numel(ID{well}), 4) && isequal(strcmp(ID{well}(3), '0'), 1)
                        secondType = [ID{well}(1:2), ID{well}(4)]; 
                     else
                        secondType = ID{well};
                     end
                     
                     for pic = 1 : size(nameArray,1)
                         if ~isequal(strfind(nameArray{pic}, ID{well}), []) 
                             if isequal(sum(cell2mat(strfind(wellID, ID{well}))),0) % make sure that the well is unique
                                index = strfind(nameArray{pic}, ID{well});
                                if isequal(index(1), 1) % make sure that the found match is at the start of the name, otherwise it indicates Z stack and this is not a match
                                    wellID{end+1,1} = ID{well};
                                    nameArray(~cellfun(@isempty, strfind(nameArray, ID{well}))) = [];
                                    break;
                                else
                                    %'siin'
                                end
                             end
                         elseif ~isequal(strfind(nameArray{pic}, secondType), [])
                              if ~isequal(strfind(nameArray{pic}, secondType), [])
                                 index = strfind(nameArray{pic}, secondType);
                                 if ~isequal(index(1), 1) % make sure that the found match is at the start of the name, otherwise it indicates Z stack and this is not a match
                                     continue;
                                 else
                                     %'siin'
                                 end
                                 index = index(1); % in case of image from Z10 for example two Z-s are found, we are interested only in the first one of them
                                 wellNameLenghtParam = numel(ID{well}) - 1;

                                 if  numel(nameArray{pic}) >= index + wellNameLenghtParam && ~isempty(str2num(nameArray{pic}(index + wellNameLenghtParam))) % to avoid matches like A1 in something like A10_ we check that a number is not following
                                    continue;
                                 end
                             end
                             if isequal(sum(cell2mat(strfind(wellID, ID{well}))),0)
                                wellID{end+1,1} = secondType;
                                break;
                             end
                         end                         
                     end
                end
        end
    end
    
end

