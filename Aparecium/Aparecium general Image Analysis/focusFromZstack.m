function [ResultImg] = focusFromZstack(strings1)  
    img = imread(strings1{1});% open images from initial array
    for c = 2:length(strings1)%cycling through images and adding it one by one through 3rd dimension 
        img = cat(3,img,imread(strings1{c}));
    end
    ResultImg = max(img, [], 3); %finding max value in 3 dimensional array and merge all into the resulting image 
end