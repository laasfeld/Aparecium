function this = standardizeImageNameStructure(this)
    for folder = 1 : numel(this.imageNameStructure)
        structOfFolder = this.imageNameStructure{folder};
        matchEquivalents = fields(this.imageNameStructure{folder});
        BFnameArray = cell(1, numel(matchEquivalents));
        for fieldIndex = 1 : numel(matchEquivalents)
            BFnameArray{fieldIndex} = this.imageNameStructure{folder}.(matchEquivalents{fieldIndex}).detectionChannelName;
            wellID = ImageImporter.getWellIDOfStringArray({structOfFolder.(matchEquivalents{fieldIndex}).detectionChannelName}, '.*');
            this.imageNameStructure{folder}.(matchEquivalents{fieldIndex}).wellID = wellID{1};
            this.imageNameStructure{folder}.(matchEquivalents{fieldIndex}).imageInWellIndex = ImageImporter.getImageInWellIndexOfString(structOfFolder.(matchEquivalents{fieldIndex}).detectionChannelName);
        end           
   end
end
