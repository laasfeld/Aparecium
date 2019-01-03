function handles = changeDimensionality(handles, dimensionality)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
if isa(dimensionality, 'double')
    dimensionality = floor(dimensionality);
elseif isa(dimensionality, 'char')
    dimensionality = floor(str2double(dimensionality));
end

if isnan(dimensionality) || dimensionality < 1
    set(handles.ChooseDimensionalityText,'String','Only positive integers allowed','ForegroundColor','red');
    set(handles.ChooseDimensionality,'String',num2str(handles.dimensionality));
    set(handles.ChooseDimensionality,'BackgroundColor','red');
    pause(1);
    set(handles.ChooseDimensionality,'BackgroundColor','white');
    set(handles.ChooseDimensionalityText,'String','Choose the dimensionality of the experiment :','ForegroundColor','black');
    return;
end
handles.dimensionality = dimensionality;

set(handles.ChooseDimensionality,'String',num2str(dimensionality));

emptyRow = {'', '', '', 'false', 'false'};

handles.treatments_TableData = get(handles.treatments_Table, 'data');

numberOfRows = size(handles.treatments_TableData, 1);
if(numberOfRows <= dimensionality - 1)
    for columns = numberOfRows : dimensionality -1
        handles.treatments_TableData = [handles.treatments_TableData; emptyRow] ; 
        handles.midasTableController.addTreatmentColumn(' ', '', '');
    end
elseif (numberOfRows > dimensionality)
    for column = numberOfRows : -1 : dimensionality + 1
        handles.treatments_TableData(column, :) = [] ; 
        handles.midasTableController.deleteLastTreatmentColumn();
    end   
else
    
end

set(handles.treatments_Table, 'Data', handles.treatments_TableData);



end

