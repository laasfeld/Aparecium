function stack = stackFromImages(path, firstImageName, type, combination)
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
        images{index} = imread([path, rigthFileNames{index}]);
        disp(['reading ', rigthFileNames{index}]);
    end
    sortedCombination = sort(combination);
    [X, b] = sort(focus);
    try
        X = X(sortedCombination);
    catch MException
        %'siin'
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
    
end



