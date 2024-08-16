function this = updateImageNameStructure(this, primaryNameArray, secondaryNameArray, secondaryChannelName, folder, masks)
    unwrappedNameArray = this.assureUnwrappedNameArray(primaryNameArray);          
    unwrappedSecondaryNameArray = this.assureUnwrappedNameArray(secondaryNameArray);

    unwrappedNameArray = reshape(unwrappedNameArray, numel(unwrappedNameArray), 1);
    unwrappedSecondaryNameArray = reshape(unwrappedSecondaryNameArray, numel(unwrappedSecondaryNameArray), 1);

    nameArrayMatchEquivalent = ImageImporter.generateNameArrayMatchEquivalent(primaryNameArray);
    secondaryNameArrayMatchEquivalent = ImageImporter.generateNameArrayMatchEquivalent(secondaryNameArray);

    nameArrayMatchEquivalent(cellfun(@isempty, nameArrayMatchEquivalent)) = {'first_channel_placeholder'};
    secondaryNameArrayMatchEquivalent(cellfun(@isempty, secondaryNameArrayMatchEquivalent)) = {'second_channel_placeholder'};

    [~, nameArrayIndices, secondaryNameArrayIndices] = intersect(nameArrayMatchEquivalent, secondaryNameArrayMatchEquivalent);
    if isempty(this.imageNameStructure{folder})
        this.imageNameStructure{folder} = struct();
    end
    
    for matchEquivalentIndex = 1 : numel(nameArrayIndices)
        this.imageNameStructure{folder}.(nameArrayMatchEquivalent{nameArrayIndices(matchEquivalentIndex)}).detectionChannelName = primaryNameArray{nameArrayIndices(matchEquivalentIndex)};
        if ~isempty(secondaryChannelName)
            this.imageNameStructure{folder}.(nameArrayMatchEquivalent{nameArrayIndices(matchEquivalentIndex)}).(secondaryChannelName).name = secondaryNameArray{secondaryNameArrayIndices(matchEquivalentIndex)};
        end
        this.imageNameStructure{folder}.(nameArrayMatchEquivalent{nameArrayIndices(matchEquivalentIndex)}).secondaryChannelNames = this.quantificationChannelPrefixes;
        if isfield(this.imageNameStructure{folder}.(nameArrayMatchEquivalent{nameArrayIndices(matchEquivalentIndex)}), 'mask')
            this.imageNameStructure{folder}.(nameArrayMatchEquivalent{nameArrayIndices(matchEquivalentIndex)}).mask = or(this.imageNameStructure{folder}.(nameArrayMatchEquivalent{nameArrayIndices(matchEquivalentIndex)}).mask, masks{secondaryNameArrayIndices(matchEquivalentIndex)});
        else
            this.imageNameStructure{folder}.(nameArrayMatchEquivalent{nameArrayIndices(matchEquivalentIndex)}).mask = masks{secondaryNameArrayIndices(matchEquivalentIndex)};
        end
    end

    missingIndices = setdiff(1 : numel(unwrappedNameArray), nameArrayIndices);
    for primaryNameArrayIndex = missingIndices
        if isfield(this.imageNameStructure{folder}, nameArrayMatchEquivalent{primaryNameArrayIndex})
            this.imageNameStructure{folder} = rmfield(this.imageNameStructure{folder}, (nameArrayMatchEquivalent{primaryNameArrayIndex}));
        end
    end
%             
end