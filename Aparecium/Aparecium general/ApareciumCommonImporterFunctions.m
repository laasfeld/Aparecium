classdef ApareciumCommonImporterFunctions
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    
    end
    
    methods (Static)
        
        % --- Executes on button press in LoadConfigurationFile.
        function LoadConfigurationFile_Callback(hObject, eventdata, handles)
            % hObject    handle to LoadConfigurationFile (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            fileChooser = FileChooser();
            [fullFilePath, fileName] = fileChooser.chooseConfigurationFile();
            handles = changeConfiguration(fullFilePath, handles);
            guidata(hObject, handles);
            ApareciumCommonImporterFunctions.treatments_Table_CellEditCallback(handles.treatments_Table, eventdata, handles);
            handles = guidata(hObject);
            if strcmp(handles.fromTreatmentStructure, 'Yes')
                handles.midasTableController.updateTreatments(handles.treatmentStructure);
                handles.plateSimulatorInterface.addExperiment(handles.apareciumExperimentInput);
                handles.simPlateHandle = handles.plateSimulatorInterface.generatePlateSimulator(handles); %% does not show the PlateSimulator
                handles.plateSimulatorInterface.regeneratePlateSimulatorFromTreatmentStructure(handles.treatmentStructure);
                set(handles.simPlateHandle, 'visible', 'off');
                drawnow();
            else
                
            end
            successBox('Configuration file successfully loaded', 'Success');
            guidata(hObject, handles);
        end
        
        % --- Executes on button press in SaveConfigurationFile.
        function SaveConfigurationFile_Callback(hObject, eventdata, handles)
            % hObject    handle to SaveConfigurationFile (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            result = saveConfiguration(handles);
            if isequal(result, 1)
                successBox('Configuration file saved', 'Success');
            end
        end
        
        function ChooseDimensionality_Callback(hObject, eventdata, handles)
            % hObject    handle to ChooseDimensionality (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hints: get(hObject,'String') returns contents of ChooseDimensionality as text
            %        str2double(get(hObject,'String')) returns contents of ChooseDimensionality as a double
            dimensionality = get(hObject,'String');
            handles = changeDimensionality(handles, dimensionality);
            guidata(hObject, handles);
        end
        
        % --- Executes when entered data in editable cell(s) in treatments_Table.
        function treatments_Table_CellEditCallback(hObject, eventdata, handles)
            % hObject    handle to treatments_Table (see GCBO)
            % eventdata  structure with the following fields (see UITABLE)
            %	Indices: row and column indices of the cell(s) edited
            %	PreviousData: previous data for the cell(s) edited
            %	EditData: string(s) entered by the user
            %	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
            %	Error: error string when failed to convert EditData to appropriate value for Data
            % handles    structure with handles and user data (see GUIDATA)
            drawnow;
            pause(0.05);
            handles.treatments_TableData = get(hObject, 'data');
            data = get(hObject,'Data'); % get the data cell array of the table
            if ~isempty(eventdata) && sum(strcmp(fieldnames(eventdata), 'Indices')) % needed to make it work with both object (newer matlab versions) and struct (older ones)
                if isequal(eventdata.Indices(2), 4) % if the column of the edited cell is the delete column
                    if eventdata.EditData && handles.dimensionality > 1 % if the checkbox was set to true
                        data{eventdata.Indices(1),eventdata.Indices(2)} = true; % set the data value to true
                        data(eventdata.Indices(1), :) = [];
                        handles.dimensionality = handles.dimensionality - 1;
                        handles.midasTableController.deleteTreatmentColumnByIndex(eventdata.Indices(1));
                    else % if the checkbox was set to false
                        data{eventdata.Indices(1),eventdata.Indices(2)} = false; % set the data value to false
                    end
                elseif isequal(eventdata.Indices(2), 5) % if the column of the edited cell is the auto concentration column
                    data{eventdata.Indices(1), eventdata.Indices(2)} = false;
                    set(hObject, 'Data', data);
                    guidata(hObject, handles);
                    drawnow;
                    concentrations = autoSequenceGenerator();
                    data{eventdata.Indices(1), 2} = concentrations;       
                end
            end
            set(hObject, 'Data', data);
            handles = changeDimensionality(handles, num2str(handles.dimensionality));
            handles = updateMidasHeaders(handles);
            handles.apareciumExperimentInput.updateTreatments(handles.treatments_TableData);
            guidata(hObject, handles);
        end        
        
        % --- Executes when entered data in editable cell(s) in channels_Table.
        function channels_Table_CellEditCallback(hObject, eventdata, handles)
            % hObject    handle to channels_Table (see GCBO)
            % eventdata  structure with the following fields (see UITABLE)
            %	Indices: row and column indices of the cell(s) edited
            %	PreviousData: previous data for the cell(s) edited
            %	EditData: string(s) entered by the user
            %	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
            %	Error: error string when failed to convert EditData to appropriate value for Data
            % handles    structure with handles and user data (see GUIDATA)
            drawnow;
            pause(0.05);
            channelData = get(hObject, 'data');
            channelNames = channelData(:,2);
            handles.apareciumExperimentInput.setChannelNames(channelNames);
            updateMidasChannels(handles);
            guidata(hObject, handles);
        end
        
        
        % --- Executes on button press in saveMIDASChannelNames.
        function saveMIDASChannelNames_Callback(hObject, eventdata, handles)
            % hObject    handle to saveMIDASChannelNames (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            channelData = get(handles.channels_Table, 'data');
            channelNames = channelData(:, 2);
            originalChannelNames = channelData(:, 1);
            for channel = 1 : numel(channelNames)
               ChannelManager.addNewChannel(originalChannelNames{channel}, channelNames{channel}); 
            end
        end
        
        % --- Executes on button press in OpenPlateSimulator.
        function OpenPlateSimulator_Callback(hObject, eventdata, handles)
            % hObject    handle to OpenPlateSimulator (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            handles.plateSimulatorInterface.addExperiment(handles.apareciumExperimentInput);
            handles.simPlateHandle = handles.plateSimulatorInterface.generatePlateSimulator(handles);
            if isequal(handles.apareciumExperimentInput.hasChanged, 0) && isequal(handles.plateSimulatorInterface.attemptMidasInitialize, 1)
                treatmentStructure = handles.midasTableController.getTreatmentStructure();
                handles.plateSimulatorInterface.regeneratePlateSimulatorFromTreatmentStructure(treatmentStructure);
            elseif isfield(handles, 'treatmentStruct') && strcmp(handles.treatmentStructure, 'Yes');
                treatmentStructure = handles.treatmentStructure;
                handles.plateSimulatorInterface.regeneratePlateSimulatorFromTreatmentStructure(treatmentStructure) 
            end
            handles = ApareciumCommonImporterFunctions.setUIModeToPlateSim(handles);
            ApareciumCommonImporterFunctions.figure1_ResizeFcn(handles.figure1, eventdata, handles);
            guidata(hObject, handles);
        end
        
        function treatments_Table_CreateFcn(hObject, eventdata, handles)
            % hObject    handle to treatments_Table (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    empty - handles not created until after all CreateFcns called
            set(hObject,'Data', {'', '', '', 'false', 'false'});
            guidata(hObject, handles);
        end
        
        % --- Executes on button press in simPlateDone.
        function simPlateDone_Callback(hObject, eventdata, handles)
            % hObject    handle to simPlateDone (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            children = handles.figure1.Children;
            for i = 1 : numel(children)
                type = children(i).Type;
                if strcmp(type, 'uipanel')
                   set(children(i), 'visible', 'on'); 
                end
            end
            set(handles.figure1, 'Color', [225/255, 226/255, 251/255]);
            pause(0.1) % makes the transition slightly smoother
            set(handles.simPlateHandle, 'visible', 'off');
            
            treatmentStructure = handles.plateSimulatorInterface.getTreatmentStructure();
            handles.midasTableController.updateTreatments(treatmentStructure);
            drawnow()
        end      
        
        function handles = setUIModeToPlateSim(handles)
            % hide all panels
            children = handles.figure1.Children;
            for i = 1 : numel(children)
                type = children(i).Type;
                if strcmp(type, 'uipanel')
                   set(children(i), 'visible', 'off'); 
                end
            end
            
            %set(handles.loadFilePanel, 'visible', 'off');
            %set(handles.MIDASPreviewPanel, 'visible', 'off');
            %set(handles.ExperimentConfigurationPanel, 'visible', 'off');
            set(handles.figure1, 'Color', 'white');
            doneCallbackHandle = @ApareciumCommonImporterFunctions.simPlateDone_Callback;            
            doneHandler(handles.plateSimulatorInterface.PlateSimulator.done, handles, doneCallbackHandle);
        end        
        
        function includeEventToMIDAS_Callback(hObject, eventdata, handles)
            % hObject    handle to includeEventToMIDAS (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hint: get(hObject,'Value') returns toggle state of includeEventToMIDAS
            if get(hObject,'Value')
                success = handles.midasTableController.useEvents();
                if isequal(success, 0)
                    set(hObject, 'Value', 0);
                end
            else
                handles.midasTableController.doNotUseEvents();
            end
        end
        
        % --- Executes on button press in fastKinetics.
        function fastKinetics_Callback(hObject, eventdata, handles)
            % hObject    handle to fastKinetics (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            fastKinetics = get(hObject, 'Value');
            try
                timeColumn = generateTimeColumn(handles.experimentDataStructure, fastKinetics);
                handles.midasTableController.setNewTimeData(timeColumn);
            catch
                set(hObject, 'Value', false);
                warndlg('Oops, it looks like the configuration file for fast kinetics compensation is missing for this plate type. Contact author for help');
            end
            guidata(hObject, handles);
            % Hint: get(hObject,'Value') returns toggle state of fastKinetics
        end
        
        function inputTimeUnit_Callback(hObject, eventdata, handles)
            % hObject    handle to inputTimeUnit (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hints: contents = get(hObject,'String') returns inputTimeUnit contents as cell array
            %        contents{get(hObject,'Value')} returns selected item from inputTimeUnit
            midasUnits = get(handles.outputTimeUnit, 'String');
            midasUnitIndex = get(handles.outputTimeUnit, 'Value');
            midasUnit = midasUnits{midasUnitIndex};

            inputUnits = get(handles.inputTimeUnit, 'String');
            inputUnitIndex = get(handles.inputTimeUnit, 'Value');
            inputUnit = inputUnits{inputUnitIndex};

            handles.midasTableController.recalculateTimeUnits(inputUnit, midasUnit);
            handles.midasTableController.setTimeUnit(midasUnit);
        end
        
        function outputTimeUnit_Callback(hObject, eventdata, handles)
            % hObject    handle to outputTimeUnit (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hints: contents = get(hObject,'String') returns outputTimeUnit contents as cell array
            %        contents{get(hObject,'Value')} returns selected item from outputTimeUnit
            midasUnits = get(hObject, 'String');
            midasUnitIndex = get(hObject, 'Value');
            midasUnit = midasUnits{midasUnitIndex};

            inputUnits = get(handles.inputTimeUnit, 'String');
            inputUnitIndex = get(handles.inputTimeUnit, 'Value');
            inputUnit = inputUnits{inputUnitIndex};

            handles.midasTableController.recalculateTimeUnits(inputUnit, midasUnit);
            handles.midasTableController.setTimeUnit(midasUnit);

            guidata(hObject, handles);
        end
        
        function timeShift_Callback(hObject, eventdata, handles)
            % hObject    handle to timeShift (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hints: get(hObject,'String') returns contents of timeShift as text
            %        str2double(get(hObject,'String')) returns contents of timeShift as a double
            timeShift = str2double(get(hObject,'String'));
            handles.midasTableController.recalculateTimeShift(timeShift);
            guidata(hObject, handles)
        end
        
        function plateName_Callback(hObject, eventdata, handles)
            % hObject    handle to plateName (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hints: get(hObject,'String') returns contents of plateName as text
            %        str2double(get(hObject,'String')) returns contents of plateName as a double
            plateName = get(hObject, 'String');
            handles.midasTableController.changePlateName(plateName);
            guidata(hObject, handles);
        end
        
        function SaveMIDASFile_Callback(hObject, eventdata, handles)
            % hObject    handle to SaveMIDASFile (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hint: get(hObject,'Value') returns toggle state of SaveMIDASFile
            if(handles.midasTableController.channelNamesAreValid())
                set(hObject, 'enable', 'off');
                set(hObject, 'String', 'Please wait');
                drawnow;
                pause(0.05);
                inputStruct.data = handles.midasTableController.getMidasTable();
                inputStruct.fileName = handles.fileName;
                result = saveMidasFile(inputStruct);
                if(result)
                    successBox('MIDAS file saved', 'Success');
                end
                set(hObject, 'enable', 'on');
                set(hObject, 'String', 'Save MIDAS file');
            else
                h = warndlg('The channel names are not valid. The channel name can not start with a number or contain the following characters:"+ - * / ^ [ ] ( ) { }" or any other matlab functions', 'Warning');
            end
        end
        
        function moveToMidasTools_Callback(hObject, eventdata, handles)
            % hObject    handle to moveToMidasTools (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hint: get(hObject,'Value') returns toggle state of moveToMidasTools
            if(handles.midasTableController.channelNamesAreValid())
                set(handles.figure1, 'visible' ,'off');
                pause(0.05);
                handles.midasTableController.setEventDataEqualToData();
                MIDASTools(handles.midasTableController, 'fromMidasTable');
            else
                h = warndlg('The channel names are not valid. The channel name can not start with a number or contain the following characters:"+ - * / ^ [ ] ( ) { }" or any other matlab functions', 'Warning');
            end
        end
        
        function moveToExportWizard_Callback(hObject, eventdata, handles)
            % hObject    handle to moveToExportWizard (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            if(handles.midasTableController.channelNamesAreValid())
                handles.midasTableController.setEventDataEqualToData();
                ExportTools(handles.midasTableController);
            else
                 h = warndlg('The channel names are not valid. The channel name can not start with a number or contain the following characters:"+ - * / ^ [ ] ( ) { }" or any other matlab functions', 'Warning');
            end
        end
        
        function figure1_ResizeFcn(hObject, eventdata, handles)
            pos = get(hObject, 'Position');
            try
                set(handles.simPlateHandle, 'Position',[0,0, pos(3), pos(4)]);
                drawnow;
            catch
                 % plate simulator handle does not exist, no need for special resize 
            end
            guidata(hObject, handles)
        end
        
        function loadStopwatchTime_Callback(hObject, eventdata, handles)
            % hObject    handle to loadStopwatchTime (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            fileChooser = FileChooser();
            stopwatchFilePath = fileChooser.getStopwatchPath();
            [handles.stopwatchTimes, handles.stopwatchLabels] = readStopwatch(stopwatchFilePath);
            handles.apareciumExperimentInput.setStopwatchTimes(handles.stopwatchTimes);
            handles.apareciumExperimentInput.setStopwatchLabels(handles.stopwatchLabels);
            successBox('Stopwatch file successfully loaded', 'Success');
            try
            	set(handles.measurementStartStopwatch, 'enable', 'on');
            catch
                
            end
            guidata(hObject, handles);
        end
        
        function measurementStartStopwatch_Callback(hObject, eventdata, handles)
            listString = cell(size(handles.stopwatchTimes));
            stopwatchLabels = handles.stopwatchLabels;
            for timeIndex = 1 : numel(handles.stopwatchTimes)
                alignmentSpace = repmat('&nbsp;', 1, max(cellfun(@numel, stopwatchLabels)) - numel(stopwatchLabels{timeIndex}));
                listString{timeIndex} = ['<html><tt>',stopwatchLabels{timeIndex},' : ', alignmentSpace, datestr(seconds(handles.stopwatchTimes(timeIndex)),'HH:MM:SS'), ' (',num2str(handles.stopwatchTimes(timeIndex)),' s)', '</html>'];
            end
            [Selection, ok] = listdlg('ListString' ,listString,'ListSize',[600 300], 'SelectionMode', 'single','Name','Select measurement start stopwatch timepoint');
            if ok
                set(handles.timeShift, 'String', num2str(handles.stopwatchTimes(Selection)));
                ApareciumCommonImporterFunctions.timeShift_Callback(handles.timeShift, eventdata, handles);
            end
        end
    end    
end