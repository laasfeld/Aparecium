function image = cellXBinary(config, image)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
fileSet = CellXFileSet(1, image);
cellXSegmenter = CellXSegmenter(config, fileSet);
cellXSegmenter.run();
image = zeros(size(image));
seeds = cellXSegmenter.seeds;
for i = 1 : numel(seeds)
    %for pixelIndex = 1 : numel(seeds(i).membranePixelListLindx)
    for pixelIndex = 1 : numel(seeds(i).perimeterPixelListLindx)
        image(seeds(i).perimeterPixelListLindx(pixelIndex)) = 1;
        %image(seeds(i).membranePixelListLindx(pixelIndex)) = 1;
    end
end

end

