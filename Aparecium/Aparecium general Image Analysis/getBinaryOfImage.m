function binary = getBinaryOfImage(filePath)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    folderSeparators = strfind(filePath,'\');
    %try
    %    binaryPath = [filePath(1:folderSeparators(end-1)),filePath(folderSeparators(end-1)+1:end)];
    %catch
        binaryPath = [filePath(1:folderSeparators(end-1)),'Binary',filePath(folderSeparators(end-1)+1:end)];
    %end
    int8Image = imread(binaryPath);
    if islogical(int8Image)
        binary = int8Image;
    else 
        binary(size(int8Image, 1), size(int8Image, 2)) = false;
        
        binary(int8Image(:,:,1)==255) = true;
    end
end

