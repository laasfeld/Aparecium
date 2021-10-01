function [slopes] = stackLinearRegPartial(path, firstImageName, type, combination)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    directory = dir(path);
    fileNames = cell(numel(directory), 1);
    for fileIndex = 1 : numel(directory)
        fileNames{fileIndex} = directory(fileIndex).name;
    end
    ZIndex = strfind(firstImageName, 'Z');
    ZIndex = ZIndex(end); % for avoiding situations where the image name contains several Z-s, for example in the well name
    rigthFileNames = [];
    for fileIndex = 1 : numel(fileNames)
        deltaLength = numel(fileNames{fileIndex}) - numel(firstImageName);
        if( ~isequal(strfind(fileNames{fileIndex}, firstImageName(1:ZIndex)), []) && ~isequal(strfind(fileNames{fileIndex}, firstImageName(ZIndex+2+deltaLength:end)), [])) 
            rigthFileNames{end + 1} = fileNames{fileIndex};
        else

        end
       
    end
    images = cell(numel(rigthFileNames), 1);
    focus = zeros(numel(rigthFileNames), 1);
    for index = 1 : numel(rigthFileNames)
        %img = Cytation5TIFFImage([path, rigthFileNames{index}] );
        deltaLength = numel(rigthFileNames{index}) - numel(firstImageName);
        
        if deltaLength == 0
            focus(index) = str2num(rigthFileNames{index}(ZIndex+1))+1;
        else
            focus(index) = str2num(rigthFileNames{index}(ZIndex+1:ZIndex+2))+1;
        end
            
        %focus(index) = img.getImageFocus();
        %img = img.getImage();
        %images{index} = img;
        images{index} = imread(fullfile(path, rigthFileNames{index}));
        disp(['reading ', rigthFileNames{index}]);
    end
    sortedCombination = sort(combination);
    [X, b] = sort(focus);
    try
        X = X(sortedCombination);
    catch MException
        % 
        rethrow(MException)
        %sortedCombination = (3:10)
        %X = X(sortedCombination);
    end
        
    regImages = images(b(sortedCombination));
    stack = regImages{1};
    %stack = images{5};
    for index = 2 : numel(regImages)
       stack = cat(3, stack, regImages{index}); 
    end
    
    stack = double(stack);
    %X = [1; 3; 5];
    x = [ones(numel(X),1) X];
    slopes = zeros(size(stack, 1), size(stack, 2));
%     intercepts = zeros(size(stack, 1), size(stack, 2));
%    R2 = zeros(size(stack, 1), size(stack, 2));
     for col = 1 : 1224
         for row = 1:904
             b = x\reshape(stack(row,col,:), numel(X),1);
             slopes(row, col) = b(2);
%             intercepts(row, col) = b(1);
%             y = reshape(stack(row,col,:), numel(X),1);
%             yCalc2 = X.*b(2) + b(1);
%             R2(row, col) = 1 - sum((y - yCalc2).^2)/sum((y - mean(y)).^2);
         end
     end
    
    
    
    if strcmp(type, 'stdev')
        normalizedSlopes = (slopes-min(min(slopes)))/max(max(slopes-min(min(slopes))));
        disk = strel('disk',4);
        neighborhood = getnhood(disk);
        stdevImage = stdfilt(images{sortedCombination(end)}, neighborhood);
        normalizedStdevImage = (stdevImage-min(min(stdevImage)))/max(max(stdevImage-min(min(stdevImage))));
        slopes = (1 - normalizedStdevImage).* normalizedSlopes;
    else
       slopes = (slopes-min(min(slopes)))/max(max(slopes-min(min(slopes))));
    end
    %normalizedR2 = (R2-min(min(R2))/max(max(R2-min(min(R2)))));
    %normalizedIntercept = (intercepts-min(min(intercepts)))/max(max(intercepts-min(min(intercepts))));
    
    %imwrite( (slopes-min(min(slopes)))/max(max(slopes-min(min(slopes)))), ['C:\Users\Kasutaja\Desktop\Masinõpe HEK rakkude analüüsiks\13_10_17 slope+stdev images\', firstImageName], 'tif');
    %imwrite(normalizedSlopes, ['C:\Users\Kasutaja\Desktop\Masinõpe HEK rakkude analüüsiks\13_10_17 slope images\', firstImageName], 'tif');
    %imwrite(normalizedStdevImage, ['C:\Users\Kasutaja\Desktop\Masinõpe HEK rakkude analüüsiks\13_10_17 stdev images\', firstImageName], 'tif');
    %imwrite(normalizedR2, ['C:\Users\Kasutaja\Desktop\Masinõpe HEK rakkude analüüsiks\13_10_17 R2 images\', firstImageName], 'tif');
    %imwrite(normalizedIntercept, ['C:\Users\Kasutaja\Desktop\Masinõpe HEK rakkude analüüsiks\13_10_17 intercept images\', firstImageName], 'tif');
end



