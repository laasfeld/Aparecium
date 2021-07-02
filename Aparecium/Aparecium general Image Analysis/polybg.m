function bg = polybg(image)           
    Z = double(reshape(image, numel(image), 1));
    X = repmat(1 : size(image, 2), size(image, 1), 1);
    Y = repmat(1 : size(image, 1), size(image, 2), 1)';
    X_reshaped = reshape(X, size(image, 1) * size(image, 2), 1);
    Y_reshaped = reshape(Y, size(image, 1) * size(image, 2), 1);
    polyfitBGfunction = fit([X_reshaped Y_reshaped], Z, 'poly33');
    polyfitBGImage = polyfitBGfunction([X_reshaped Y_reshaped]);
    bg = reshape(polyfitBGImage, size(image, 1), size(image, 2));         
end