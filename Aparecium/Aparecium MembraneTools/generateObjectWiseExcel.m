function [ output_args ] = generateObjectWiseExcel(results, path)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

finalTableArray = cell(numel(results{1}.imageData), 1);
tableRows = [];
for well = 1 : numel(results{1}.imageData)
    finalTable = [];
    counter = 1;
    for imageIdx = 1 : numel(results{1}.imageData{well})
        im = results{1}.imageData{well}{imageIdx}.image;
        cc = bwconncomp(im);
        % read primary image
        im1 = imread([path, '/', results{1}.imageData{well}{imageIdx}.imageName]);
        res = regionprops('table',cc, im1, 'Area', 'Eccentricity', 'MeanIntensity');
        res.Properties.VariableNames = {'Area', 'Eccentricity', 'DAPI_intensity'};
        im2 = imread([path, '/', results{1}.imageData{well}{imageIdx}.secondaryImageName]);
        res2 = regionprops('table',cc, im2, 'MeanIntensity');
        res2.Properties.VariableNames = {'RFP_intensity'};
        subtable = [res res2];
        subtable = subtable(subtable{:,1} > 600, :);
        if isequal(counter, 1)
            finalTable = subtable;            
        else         
            finalTable = [finalTable; subtable];
        end
        counter = counter + 1;
    end
    tableRows(well) = size(finalTable, 1);
    finalTableArray{well} = finalTable;
end

exportableCell = cell(max(tableRows(well))+2, numel(results{1}.imageData)*4);
for well = 1 : numel(results{1}.imageData)
    tableRowsWell = size(finalTableArray{well}, 1);
    exportableCell(3:tableRowsWell + 2, (well - 1)*4+1:well*4) = table2cell(finalTableArray{well});
    
    exportableCell(2, (well - 1)*4+1:well*4) = finalTableArray{well}.Properties.VariableNames;
    exportableCell{1, (well - 1)*4+1} = results{1}.ID{well};
    
end

end

