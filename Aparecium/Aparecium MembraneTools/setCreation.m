imageSize = 61;
sourceFolder = 'C:\Users\Kasutaja\Desktop\Masinõpe HEK rakkude analüüsiks\Original focus images';
%createBatchCellMaskSet('C:\Users\Kasutaja\Desktop\Masinõpe HEK rakkude analüüsiks\Manual training images - 4 classes', sourceFolder, '' , 'D:\Masinõpe HEK rakkude maskide jaoks\cellMask', imageSize);
createBatchCellMaskSet('C:\Users\Kasutaja\Desktop\Masinõpe HEK rakkude analüüsiks\Manual test images - 4 classes', sourceFolder, '' , 'D:\Masinõpe HEK rakkude maskide jaoks\testSetCellMask', imageSize);