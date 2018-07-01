function [ maxDiameter ] = maxObjectDiameter(objectPixels)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
maxDistanceSquare = 0;
distanceSquare = zeros( (size(objectPixels, 1)^2 - size(objectPixels, 1))/2 ,1);
counter = 0;
for firstPixel = 1 : size(objectPixels, 1) - 1
    for secondPixel = firstPixel + 1 : size(objectPixels, 1)
        counter = counter + 1;
        distanceSquare(counter) = (objectPixels(firstPixel, 1) - objectPixels(secondPixel, 1))^2 + (objectPixels(firstPixel, 2) - objectPixels(secondPixel, 2))^2;
    end
end
maxDiameter = sqrt(max(distanceSquare));
end

