function [binary] = handmadeToBinary(originalImage)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
originalImage = double(originalImage);
manual = sum(originalImage(:,:,1:3),3)/3;
manual(manual~=255) = 0;
manual2=logical(manual);
se = strel('disk', 1);
binary = imdilate(logical(manual2), se);
end