
% load Zstacks
path = '\\172.17.6.224\Users\Anni\170127_150017_ZstackAnalysis_ligandi väljatõrjumine\170127_150147_Plate 1\'
C01 = imread([path, 'C01_06_1_1Z0_Bright Field_001.tif']);
slopes = zeros(size(C01, 1), size(C01, 2), 4);
slopes(:,:,1) = stackLinearRegPartial(path, 'C01_06_1_1Z0_Bright Field_001.tif', 'stdev', [5:12]);
slopes(:,:,2) = stackLinearRegPartial(path, 'E01_05_1_1Z0_Bright Field_001.tif', 'stdev', [5:12]);
slopes(:,:,3) = stackLinearRegPartial(path, 'G01_04_1_1Z0_Bright Field_001.tif', 'stdev', [5:12]);
slopes(:,:,4) = stackLinearRegPartial(path, 'H04_02_1_1Z0_Bright Field_001.tif', 'stdev', [5:12]);

% load handmade images
handmade = zeros(size(C01, 1), size(C01, 2), 4);
handmade(:,:,1) = handmadeToBinary(imread('D:\käsitsi tehtud Hekid\C01_06_1_1Z8_Bright Field_001_membranes.tif'));
handmade(:,:,2) = handmadeToBinary(imread('D:\käsitsi tehtud Hekid\E01_05_1_1Z8_Bright Field_001_membranes.tif'));
handmade(:,:,3) = handmadeToBinary(imread('D:\käsitsi tehtud Hekid\G01_04_1_1_Z7_Bright Field_001.tif'));
handmade(:,:,4) = handmadeToBinary(imread('D:\käsitsi tehtud Hekid\H04_02_1_1Z7_Bright Field_001_membranes.tif'));

for image = 1 : 4
        cc = bwconncomp(imfill(handmade(:,:,image)));
        handTest = zeros(904,1224);
    for i = 1 : numel(cc.PixelIdxList)
        handTest(cc.PixelIdxList{i}) = i;
    end
    if image == 1
        imwrite(uint16(handTest), 'C01.png')
    elseif image == 2
        imwrite(uint16(handTest), 'E01.png')
    elseif image == 3
        imwrite(uint16(handTest), 'G01.png')
    elseif image == 4
        imwrite(uint16(handTest), 'H01.png')
    end
end