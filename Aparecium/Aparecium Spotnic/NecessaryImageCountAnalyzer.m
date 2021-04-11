mainDir = '\\172.17.6.224\Users\Robin\2019.11.15_Robin\-20\2';
subdirs = dir(mainDir);
subdirs(1:2) = [];

imageStruct = containers.Map;
for dirIndex = 1 : numel(subdirs)
    for i=1:size(subdirs, 1)
        dirInfo = dir(fullfile(mainDir, subdirs(i).name));
        dirInfo(1:2) = [];
        for imageFile = 1 : numel(dirInfo)
            if ~isempty(strfind(dirInfo(imageFile).name, '.tif'));
                info = imfinfo(fullfile(mainDir, subdirs(i).name, dirInfo(imageFile).name));
                frame = zeros(512, 512, numel(info));
                for k = 1 : numel(info)
                    frame(:,:,k) = imread(fullfile(mainDir, subdirs(i).name, dirInfo(imageFile).name), k);
                end
                imageStruct(fullfile(mainDir, subdirs(i).name, dirInfo(imageFile).name)) = frame;
            end
        end
    end
end

spotAnalysisResults = cell(10, 1);
parfor k = 4 : 10
    C = combnk(1:10,k);
    spotAnalysisResults{k} = cell(min(size(C, 1), 25), 1);
    CToUse = C(randperm(size(C, 1), min(size(C, 1), 25)), :);
    for comb = 1 : size(CToUse, 1)
        spotAnalysisResults{k}{comb} = cell(numel(subdirs), 1);
        tic
        for dirIndex = 1 : numel(subdirs)  
            result = spotDetection(500, [mainDir,'/', subdirs(dirIndex).name], false, CToUse(comb, :), 99, imageStruct);
            if ~isempty(result)
                spotAnalysisResults{k}{comb}{dirIndex} = cell2mat(result(:,2));
            end
        end
        toc
        disp([num2str(k), ' ', num2str(comb)]); 
    end
end