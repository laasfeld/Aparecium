function registredImage = register_images(baseImage, imageToRegister)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
[optimizer, metric] = imregconfig("multimodal");
[registredImage, RReg] = imregister(imageToRegister, baseImage, "translation", optimizer, metric);
%transform = imregtform(imageToRegister, baseImage, "translation", optimizer, metric);
end