function [ output_args ] = writeTiffStack(image, name)
    imwrite(image(:,:,1), name, 'tif');
    for i = 2 : size(image, 3)
        imwrite(image(:,:,i), name, 'tif', 'WriteMode', 'append');
    end
end

