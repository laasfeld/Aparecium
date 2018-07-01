function [cellularImage, outsideCellHalo] = handmadeToUnbiasedBackground(originalImage)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% cellular - punane kanal peab olema 255, sinine ja roheline peavad olema 0
redChannel = originalImage(:,:,1);
redChannelCellular = redChannel;
redChannelCellular(redChannel~=255) = 0;

redChannelHalo = redChannel;
redChannelHalo(redChannel==0) = 255;
redChannelHalo(redChannel~=255) = 0;

greenChannel = originalImage(:,:,2);
greenChannelCellular = greenChannel;
greenChannelCellular(greenChannel==0) = 255;
greenChannelCellular(greenChannel~=255) = 0;

greenChannelHalo = greenChannel;
greenChannelHalo(greenChannel==0) = 255;
greenChannelHalo(greenChannel~=255) = 0;

blueChannel = originalImage(:,:,3);
blueChannelCellular = blueChannel;
blueChannelCellular(blueChannel==0) = 255;
blueChannelCellular(blueChannel~=255) = 0;

blueChannelHalo = blueChannel;
blueChannelHalo(blueChannel~=255) = 0;

cellularImage = reshape(logical(redChannelCellular).*logical(~greenChannelCellular).*logical(~blueChannelCellular), size(redChannel));
outsideCellHalo = reshape(logical(~redChannelHalo).*logical(~greenChannelHalo).*logical(blueChannelHalo), size(redChannel));
end

