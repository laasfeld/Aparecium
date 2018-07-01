function [ handles ] = changeConfiguration(filename, handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    load(filename,'dimensionalityTR','namesTR','unitsTR','valuesTR');
    handles = changeDimensionality(handles, num2str(dimensionalityTR));
    for treatment = 1 : size(valuesTR, 2)
       valuesTR{treatment} = regexprep(num2str(valuesTR{treatment}),'       ',' '); 
       falseValues{treatment} = false;
    end
    data = [namesTR, valuesTR', unitsTR', falseValues', falseValues'];
    set(handles.treatments_Table, 'Data', data);
end

