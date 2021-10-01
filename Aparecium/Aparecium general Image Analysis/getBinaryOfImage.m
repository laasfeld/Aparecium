function binary = getBinaryOfImage(filePath, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    folderSeparators = strfind(filePath,'\');
    if numel(varargin) > 0
        prefix = varargin{1};
    else
        prefix = 'Binary';
    end
    %try
    %    binaryPath = [filePath(1:folderSeparators(end-1)),filePath(folderSeparators(end-1)+1:end)];
    %catch
        binaryPath = [filePath(1:folderSeparators(end-1)),prefix,filePath(folderSeparators(end-1)+1:end)];
    %end
    int8Image = imread(binaryPath);
    if islogical(int8Image)
        binary = int8Image;
    else 
        binary(size(int8Image, 1), size(int8Image, 2)) = false;
        
        binary(int8Image(:,:,1)==255) = true;
    end
end

