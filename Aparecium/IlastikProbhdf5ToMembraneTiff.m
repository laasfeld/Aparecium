for i = 1 : 128
    [a, b, c] = fileparts(d2(i).name);
    if isequal(c, '.h5')
        d2(i).name
        name_to_read = ['D:\Original_slope_and_stdev_images\', d2(i).name]
        exportedData = hdf5read(name_to_read, 'exported_data');
        [x, I] = max(exportedData, [], 1);
        binaryImage = I==3;
        fixed_name = regexprep(regexprep(regexprep(d2(i).name, 'Bright_Field', 'Bright Field'), '.h5', '.tif'), '_Probabilities', '');
        imwrite(squeeze(binaryImage)', ['D:\Original_slope_and_stdev_images\Binary_results\', fixed_name], 'tif')
    end
end