function result = saveConfiguration(handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    dimensionalityTR = handles.dimensionality; % it is used in uisave, ignore warning
    data = get(handles.treatments_Table, 'Data');
    namesTR = data(:, 1); % it is used in uisave, ignore warning
    valuesTR = data(:, 2)'; % it is used in uisave, ignore warning
    unitsTR = data(:, 3)'; % it is used in uisave, ignore warning
    saveTreatmentStructure = true;
    try
        treatmentStructure = handles.plateSimulatorInterface.getTreatmentStructure();
    catch
        saveTreatmentStructure = false;
    end
    fileChooser = FileChooser();
    startingPath = fileChooser.chooseConfigurationFileSave(); 
    [fileName, filePath] = uiputfile([startingPath,'\','CF-',handles.fileName,'.MAT']);
    if isequal(fileName, 0) || isequal(filePath, 0)
        result = 0;
    elseif ~isequal(fileName, 0) && ~isequal(filePath, 0)
        if saveTreatmentStructure
            save( [filePath, fileName], 'dimensionalityTR','namesTR','valuesTR','unitsTR', 'treatmentStructure');
        else
            save( [filePath, fileName], 'dimensionalityTR','namesTR','valuesTR','unitsTR');
        end
        result = 1;
        fileChooser.registerConfigurationFileSavePath(filePath);
    end
end

