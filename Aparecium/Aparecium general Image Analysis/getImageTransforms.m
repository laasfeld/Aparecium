function baseNameTransformMap = getImageTransforms(base_folder, baseChannel, shiftableChannel)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

folder = dir(base_folder);
folder(1:2) = [];
baseChannelNames = cell(0, 0);
baseChannelNameEquivalents = cell(0, 0);
shiftableChannelNames = cell(0, 0);
shiftableChannelNameEquivalents = cell(0, 0);

for imageIndex = 1 : numel(folder)
    if strfind(folder(imageIndex).name, baseChannel)
        baseChannelNames{end + 1} = folder(imageIndex).name;
    elseif strfind(folder(imageIndex).name, shiftableChannel)
        shiftableChannelNames{end + 1} = folder(imageIndex).name;
    end
end
baseChannelNameEquivalents = ImageImporter.generateNameArrayMatchEquivalent({baseChannelNames});
shiftableChannelNameEquivalents = ImageImporter.generateNameArrayMatchEquivalent({shiftableChannelNames});

baseIndexNameMap = containers.Map(baseChannelNames, baseChannelNameEquivalents);
shiftableNameIndexMap = containers.Map(shiftableChannelNameEquivalents, shiftableChannelNames);
baseNameShiftableNameMap = containers.Map();

for element = keys(baseIndexNameMap)
    baseNameShiftableNameMap(element{1}) = shiftableNameIndexMap(baseIndexNameMap(element{1}));
end

baseNameTransformMap = containers.Map();
counter = 0
for element = keys(baseNameShiftableNameMap)
    element = element{1};
    disp(element)
    baseNameTransformMap(element) = register_image_transform(imread(fullfile(base_folder, baseNameShiftableNameMap(element))), imread(fullfile(base_folder, element)));
    
    disp(baseNameTransformMap(element));
    counter = counter + 1;
    if counter > 24
        break;
    end
        
end

end

function transform = register_image_transform(baseImage, imageToRegister)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
[optimizer, metric] = imregconfig("multimodal");
transform = imregtform(imageToRegister, baseImage, "translation", optimizer, metric);
end

