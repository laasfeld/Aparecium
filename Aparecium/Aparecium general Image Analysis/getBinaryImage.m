function binaryOut = getBinaryImage(binaryImage)
%Returns binary image as logical array if the input is image itself,
%bwpacked image or image path
%   Detailed explanation goes here
if strcmp(class(binaryImage), 'uint32')
    binaryOut = bwunpack(binaryImage);
elseif strcmp(class(binaryImage), 'logical')
    binaryOut = binaryImage;
elseif strcmp(class(binaryImage), 'char')
    binaryOut = imread(binaryImage);   
end

end

