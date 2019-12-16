function [ handles ] = changeConfiguration(filename, handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    load(filename,'dimensionalityTR','namesTR','unitsTR','valuesTR', 'treatmentStructure');
    handles = changeDimensionality(handles, num2str(dimensionalityTR));
    for treatment = 1 : size(valuesTR, 2)
       valuesTR{treatment} = regexprep(num2str(valuesTR{treatment}),'       ',' '); 
       falseValues{treatment} = false;
    end
    data = [namesTR, valuesTR', unitsTR', falseValues', falseValues'];
    set(handles.treatments_Table, 'Data', data);
    if exist('treatmentStructure')
        handles.treatmentStructure = treatmentStructure;
        answer = questdlg('Configuration file contains treatment layout. Do you want to apply layout?', 'Question' ,'Yes', 'No', 'No');
        handles.fromTreatmentStructure = answer;
    else
        handles.treatmentStructure = [];
        handles.fromTreatmentStructure = 'No';
    end
end

