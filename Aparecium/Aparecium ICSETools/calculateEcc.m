function ecc = calculateEcc(bw)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[yCoords, xCoords] = find(bw == 1);
centerY = mean(yCoords);
centerX = mean(xCoords);

xValues = xCoords - centerX;
yValues = yCoords - centerY;

xDir = 1/12 + sum(xValues.^2)/numel(xValues);
yDir = 1/12 + sum(yValues.^2)/numel(yValues);
mixedDir = sum(yValues.*xValues);

delta = yDir - xDir;
summed = yDir + xDir; 

shared = sqrt(delta^2 + 4*mixedDir^2);
a = summed + shared;
b = summed - shared;
ecc = sqrt(a - b)/sqrt(a);

end

