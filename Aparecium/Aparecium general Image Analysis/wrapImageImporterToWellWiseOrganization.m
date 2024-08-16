function this = wrapImageImporterToWellWiseOrganization(this)
       
    %% set up variable sizes
    this.secondaryNameArray = cell(1, numel(this.imageNameStructure));
    this.nameArray = cell(1, numel(this.imageNameStructure));
    this.masks = cell(1, numel(this.imageNameStructure));

    for folderIndex = 1 : numel(this.imageNameStructure)
        structOfFolder = this.imageNameStructure{folderIndex};
        matchEquivalents = fields(structOfFolder);

        
        wellIDsOfFolder = this.wellID{folderIndex};
        wellIDsOfNameStructure = cell(1, numel(matchEquivalents));
        imageIndicesOfWellOfNameStructure = cell(1, numel(matchEquivalents));

        BFnameArray = cell(1, numel(matchEquivalents));
        for fieldIndex = 1 : numel(matchEquivalents)
            wellIDsOfNameStructure{fieldIndex} = structOfFolder.(matchEquivalents{fieldIndex}).wellID;
            imageIndicesOfWellOfNameStructure{fieldIndex} = structOfFolder.(matchEquivalents{fieldIndex}).imageInWellIndex;
        end

        counter = 1;
        
        for wellIndex = 1 : numel(wellIDsOfFolder)
            fieldCounter = 1;
            
            % from https://se.mathworks.com/matlabcentral/answers/2015-find-index-of-cells-containing-my-string
            exact_match_mask = strcmp(wellIDsOfNameStructure, wellIDsOfFolder{wellIndex});
            suitableIndices = find(exact_match_mask);
            for imageInWellIndex = 1 : numel(suitableIndices)
                this.nameArray{folderIndex}{counter} = structOfFolder.(matchEquivalents{suitableIndices(imageInWellIndex)}).detectionChannelName;

                secondaryChannelNames = structOfFolder.(matchEquivalents{suitableIndices(imageInWellIndex)}).secondaryChannelNames;
                for secondaryChannelIndex = 1 : numel(secondaryChannelNames)
                    this.secondaryNameArray{folderIndex}{counter}{secondaryChannelIndex} = structOfFolder.(matchEquivalents{suitableIndices(imageInWellIndex)}).(secondaryChannelNames{secondaryChannelIndex}).name;
                    this.masks{folderIndex}{wellIndex}{imageInWellIndex} = structOfFolder.(matchEquivalents{suitableIndices(imageInWellIndex)}).mask;
                    
                end
                counter = counter + 1;
            end
        end              
    end
end