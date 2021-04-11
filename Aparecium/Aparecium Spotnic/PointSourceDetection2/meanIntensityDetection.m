function spotNumber=meanIntensityDetection

folderName = uigetdir; % the folder in which images exists

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collect tif files names and path from folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dirInfo = dir(fullfile(folderName,'*.tif'));

tifFilesNames={};
for i=1:size(dirInfo, 1)
    tifFilesNames{i,1} = fullfile(folderName, dirInfo(i).name);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check tif files in subfolders and if exist collect tif files names and path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dirInfo = dir(folderName);
dirInfo(~[dirInfo.isdir]) = [];


for k = 3 : size(dirInfo,1)
    subDirInfo = dir(fullfile(folderName, dirInfo(k).name, '*.tif'));
    if size(subDirInfo, 1) ~= 0
        for i=1:size(subDirInfo, 1)
            tifFilesNames{end+1,1} = fullfile(folderName, dirInfo(k).name, subDirInfo(i).name);
        end
    else        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Detect mean intensity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1 : size(tifFilesNames,1)
    frame = double(imread(tifFilesNames{i}));
    tifFilesNames{i,2}=mean(mean(frame, 2));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
meanIntensity=tifFilesNames;
xlswrite(fullfile(folderName,'meanIntensity'),meanIntensity);
