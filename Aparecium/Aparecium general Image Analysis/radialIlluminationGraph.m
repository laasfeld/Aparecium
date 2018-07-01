function [ output_args ] = radialIlluminationGraph(images)
%RADIALILLUMINATIONGRAPH Summary of this function goes here
%   Detailed explanation goes here
img = images{1};
for c = 2:length(images)
    img = cat(3,img,images{c});
end
ResultImg = max(img, [], 3);
images = cell(0,0);
images{1} = ResultImg;
distances = zeros(0,0);
intensities = cell(0,0);
for imageIndex = 1 : numel(images)
   imageIndex
   centerY = size(images{imageIndex}, 1)/2;
   centerX = size(images{imageIndex}, 2)/2;
   for row = 1 : size(images{imageIndex}, 1)
       row
       for column = 1 : size(images{imageIndex}, 2) 
           distance = sqrt( (centerY-row)^2 + (centerX-column)^2);
           illuminance = images{imageIndex}(row, column);
           index = find(distances==distance);
           if isempty(index)
              intensities{end+1} = zeros(0,0);
              intensities{end}(end+1)=illuminance;
              distances(end+1) = distance;
           else
               intensities{index}(end+1)= illuminance;
           end
       end
   end
end
for i = 1 : numel(intensities)
int(i) = mean(intensities{i});
end
scatter(distances, int)
end



