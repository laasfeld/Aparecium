function callback = createCallback(subfunction)
    mainHandle = str2func(['ApareciumCommonImporterFunctions.', subfunction]);
    callback = @ (hObject, eventdata) mainHandle(hObject, eventdata, guidata(hObject)); 
end