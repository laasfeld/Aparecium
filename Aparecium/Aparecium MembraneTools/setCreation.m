imageSize = 61;
sourceFolder = 'C:\Users\Kasutaja\Desktop\Masin�pe HEK rakkude anal��siks\Original focus images';
%createBatchCellMaskSet('C:\Users\Kasutaja\Desktop\Masin�pe HEK rakkude anal��siks\Manual training images - 4 classes', sourceFolder, '' , 'D:\Masin�pe HEK rakkude maskide jaoks\cellMask', imageSize);
createBatchCellMaskSet('C:\Users\Kasutaja\Desktop\Masin�pe HEK rakkude anal��siks\Manual test images - 4 classes', sourceFolder, '' , 'D:\Masin�pe HEK rakkude maskide jaoks\testSetCellMask', imageSize);