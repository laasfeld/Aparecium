function [ResultImg] = focusFromZstack(strings1)
    img = imread(strings1{1});
    for c = 2:length(strings1)
        img = cat(3,img,imread(strings1{c}));
    end
    ResultImg = max(img, [], 3);
end