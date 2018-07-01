function saveConfiguration(handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    dimensionalityTR = handles.dimensionality; % it is used in uisave, ignore warning
    data = get(handles.treatments_Table, 'Data');
    namesTR = data(:, 1); % it is used in uisave, ignore warning
    valuesTR = data(:, 2)'; % it is used in uisave, ignore warning
    unitsTR = data(:, 3)'; % it is used in uisave, ignore warning
    if isdeployed
        load([pwd, '\', 'settings.mat']);
    else
        load settings
    end  
    startingPath = settings.Configurations;
    uisave({'dimensionalityTR','namesTR','valuesTR','unitsTR'},[startingPath,'\','CF-',handles.fileName,'.MAT']);

end

