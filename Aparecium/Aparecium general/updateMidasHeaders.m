function [ handles ] = updateMidasHeaders(handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

dimensionality = handles.dimensionality;

for treatment = 1 : dimensionality
    treatmentName = handles.treatments_TableData{treatment, 1};
    treatmentUnit = handles.treatments_TableData{treatment, 3};
    handles.midasTableController.changeTreatmentHeader(treatmentName, treatment, treatmentUnit);
end
end

