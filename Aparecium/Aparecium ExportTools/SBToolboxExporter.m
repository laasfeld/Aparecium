classdef SBToolboxExporter <  ExportPanelController
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private)
        tableHandle = [];
        experimentParamsNames = [];
        experimentParamNameTable = [];
        outputTableStruct = [];
        groups = [];
        loadingBar = [];
    end
    
    methods
        function this = SBToolboxExporter()
            
        end
        
        function addLoadingBar(this, loadingBar)
            this.loadingBar = loadingBar;
        end
        
        function addExperiment(this, experiment, varargin)
            this.experiment = experiment;
            this.experimentParamsNames = this.experiment.getTreatments();
            treatments = this.convertToCellArrayOfStrings(this.experiment.getTreatments());
            data = [treatments', treatments'];
            set(this.experimentParamNameTable, 'data', data);
        end                          
      
        function subgroups = getSubgroupsOfGroup(this, group)
            subgroups = cell(0,0);
            for subgroup = this.subgroupStartValue : numel(this.groups{group})
                if isfield(this.outputTableStruct{group}{subgroup}, 'success') && isequal(this.outputTableStruct{group}{subgroup}.success, 1)
                    subgroups{end+1} = subgroup;
                end
            end
        end
        
        function subgroupNames = getSubgroupNamesOfGroup(this, group)
            subgroupNames = cell(0,0);
            for subgroup = this.subgroupStartValue : numel(this.groups{group})
                if isfield(this.outputTableStruct{group}{subgroup}, 'success') && isequal(this.outputTableStruct{group}{subgroup}.success, 1)
                    subgroupNames{end+1} = this.subgroupNames{group}{subgroup};
                end
            end
        end
        
        function setTableHandle(this, tableHandle)
           this.tableHandle = tableHandle;           
        end
        
        function setExperimentParamNameTable(this, tableHandle)
            this.experimentParamNameTable = tableHandle;
        end
        
        function getNewExperimentParamsNames(this)
            data = get(this.experimentParamNameTable, 'Data');
            this.experimentParamsNames = data(:,2);
        end

        function calculateNewTable(this, exportMode, outputVariable)

           [data, this.groups] = this.calculationMethod.calculate(this.experiment, this.groupStructure, this.sharedBlankStructure, this.timewiseBlankStructure);
           if isequal(this.subgroupNames, [])
                this.subgroupNames = generateStandardSubgroupNames(data, 1);
           end
           channelNames = this.calculationMethod.getChannelNames();
           data = this.mergeOrAverage(data, exportMode);
           this.convertDataToSBToolboxFormat(data, this.groups, channelNames, outputVariable, exportMode);

        end
        
        function paramNames = readParamsNames(this)
           data = get(this.experimentParamNameTable, 'data'); 
           paramNames = data(:, 2);          
        end
        
        function exportData = mergeOrAverage(this, data, exportMode)
            this.experimentParamsNames = this.readParamsNames();
            timePoints = this.timeController.getCycleTimes();
            switch exportMode
                case 'Average'
                    for group = 1 : size(data, 2)
                        for subgroup = this.subgroupStartValue : numel(data{group})
                            measurements = [];
                            for subgroupElement = 1 : numel(data{group}{subgroup})
                                measurements = [measurements, cell2mat(data{group}{subgroup}{subgroupElement})];
                            end
                            cycles = this.experiment.getNumberOfCycles();
                            exportData{group}{subgroup}.minimum = min(measurements', [], 1)';
                            exportData{group}{subgroup}.maximum = max(measurements', [], 1)';
                            exportData{group}{subgroup}.average = mean(measurements', 1)';
                            %exportData{group}{subgroup}.timePoints = this.experiment.getCycleTimeMoments();
                            time = [];
                            if this.experiment.getFastKinetics()
                                for subgroupElement = 1 : numel(data{group}{subgroup})
                                    wellIndex = this.experiment.getIndexOfUsedWell(this.groups{group}{subgroup}{subgroupElement}); 
                                    time = [time; timePoints(wellIndex, :)];
                                end
                            else
                                for subgroupElement = 1 : numel(data{group}{subgroup})
                                    %wellIndex = this.experiment.getIndexOfUsedWell(this.groups{group}{subgroup}{subgroupElement}); 
                                    time = [time; timePoints(1, :)];
                                end 
                                
                            end
                            exportData{group}{subgroup}.timePoints = mean(time, 1);
                            treatments = this.experiment.getTreatments();
                            for subgroupElement = 1 : numel(data{group}{subgroup})
                                [treatmentsOfWell, concentrationsOfWell] = this.experiment.getTreatmentsOfWell(this.groups{group}{subgroup}{subgroupElement}, 1);
                                for treatment = 1 : numel(treatments)
                                    exportData{group}{subgroup}.initialConditions{treatment} = [this.experimentParamsNames{treatment},'(0) = ',num2str(concentrationsOfWell{treatment})];
                                end
                            end 
                        end
                    end
                case 'Merge'
                    for group = 1 : size(data, 2)
                        for subgroup = this.subgroupStartValue : numel(data{group})
                            measurements = [];
                            for subgroupElement = 1 : numel(data{group}{subgroup})
                                measurements = cell2mat(data{group}{subgroup}{subgroupElement});
                                cycles = this.experiment.getNumberOfCycles();
                                exportData{group}{subgroup}{subgroupElement}.minimum = measurements;
                                exportData{group}{subgroup}{subgroupElement}.maximum = measurements;
                                exportData{group}{subgroup}{subgroupElement}.average = measurements;
                                %exportData{group}{subgroup}.timePoints = this.experiment.getCycleTimeMoments();
                                wellIndex = this.experiment.getIndexOfUsedWell(this.groups{group}{subgroup}{subgroupElement}); 
                                if this.experiment.getFastKinetics()
                                    exportData{group}{subgroup}{subgroupElement}.timePoints = timePoints(wellIndex, :);
                                else
                                    exportData{group}{subgroup}{subgroupElement}.timePoints = timePoints(1, :);
                                end
                                treatments = this.experiment.getTreatments();
                                
                                [treatmentsOfWell, concentrationsOfWell] = this.experiment.getTreatmentsOfWell(this.groups{group}{subgroup}{subgroupElement}, 1);
                                for treatment = 1 : numel(treatments)
                                    exportData{group}{subgroup}{1}.initialConditions{treatment} = [this.experimentParamsNames{treatment},'(0) = ',num2str(concentrationsOfWell{treatment})];
                                end                            
                            end
                        end
                    end                
            end
        end
        
        function showTableData(this, group, subgroup)
            data = this.outputTableStruct{group}{subgroup}.SBTable;
            set(this.tableHandle, 'Data', data, 'ColumnEditable', [false true true true true]);
        end
        
        function sendTableToWorkspace(this, group, subgroup)            
            assignin('base', ['Aparecium_SB_Table_group', num2str(group), '_', num2str(subgroup - 1)] , this.outputTableStruct{group}{subgroup}.SBTable);
        end
        
        function exportWithDialogue(this)
            if isdeployed
                load([pwd, '\', 'settings.mat']);
            else
                load settings
            end
            startingPath = settings.SBToolbox;
            FilePath = uigetdir(startingPath, 'Select destination folder (should be named Experiments)');
            groupNames = this.experiment.getGroups();
            this.loadingBar.vizualize();
            eventTimes = this.experiment.getEventTimes();
            for well = 1 : numel(eventTimes)
               eventTimes{well} = eventTimes{well}*this.timeController.getUnitConversionConstant(); 
            end
            for group = 1 : numel(this.groups)
                for subgroup = this.subgroupStartValue : numel(this.groups{group})
                    this.loadingBar.setLoadingBarPercent( 100* (((group-1)/numel(this.groups))+(subgroup-1)/(numel(this.groups{group})*numel(this.groups))));
                    outputValue = this.outputTableStruct{group}{subgroup}.outputValue;
                    mkdir(FilePath,[outputValue, '_Group_', groupNames{group}, '_', this.subgroupNames{group}{subgroup}]);
                    tempFilePath = [FilePath,'\',outputValue,'_Group_',groupNames{group}, '_', this.subgroupNames{group}{subgroup}];
                    outputFilenameMIDAS = [tempFilePath, '\', this.outputTableStruct{group}{subgroup}.path, '.xls'];
                    outputFilenameEXP = [tempFilePath, '\', this.outputTableStruct{group}{subgroup}.path, '.exp'];
                    initialConditions = this.outputTableStruct{group}{subgroup}.initialConditions;
                    representingWellIndex = this.experiment.getIndexOfUsedWell(this.groups{group}{subgroup}{1}); 
                    concentrationChangeEvent = this.experiment.getConcentrationChangeEvents();
                    expFileWriter(this.outputTableStruct{group}{subgroup}.path, initialConditions, representingWellIndex, concentrationChangeEvent, eventTimes, this.experimentParamsNames, outputFilenameEXP)
                    xlswrite(outputFilenameMIDAS, this.outputTableStruct{group}{subgroup}.SBTable);
                end
            end
            this.loadingBar.devizualize();
        end
        
        function exportWithName(this, folderName)

            FilePath = folderName;
            groupNames = this.experiment.getGroups();
            this.loadingBar.vizualize();
            eventTimes = this.experiment.getEventTimes();
            for well = 1 : numel(eventTimes)
               eventTimes{well} = eventTimes{well}*this.timeController.getUnitConversionConstant(); 
            end
            for group = 1 : numel(this.groups)
                for subgroup = this.subgroupStartValue : numel(this.groups{group})
                    this.loadingBar.setLoadingBarPercent( 100* (((group-1)/numel(this.groups))+(subgroup-1)/(numel(this.groups{group})*numel(this.groups))));
                    outputValue = this.outputTableStruct{group}{subgroup}.outputValue;
                    mkdir(FilePath,[outputValue, '_Group_', groupNames{group}, '_', this.subgroupNames{group}{subgroup}]);
                    tempFilePath = [FilePath,'\',outputValue,'_Group_',groupNames{group}, '_', this.subgroupNames{group}{subgroup}];
                    outputFilenameMIDAS = [tempFilePath, '\', this.outputTableStruct{group}{subgroup}.path, '.xls'];
                    outputFilenameEXP = [tempFilePath, '\', this.outputTableStruct{group}{subgroup}.path, '.exp'];
                    initialConditions = this.outputTableStruct{group}{subgroup}.initialConditions;
                    representingWellIndex = this.experiment.getIndexOfUsedWell(this.groups{group}{subgroup}{1}); 
                    concentrationChangeEvent = this.experiment.getConcentrationChangeEvents();
                    expFileWriter(this.outputTableStruct{group}{subgroup}.path, initialConditions, representingWellIndex, concentrationChangeEvent, eventTimes, this.experimentParamsNames, outputFilenameEXP)
                    xlswrite(outputFilenameMIDAS, this.outputTableStruct{group}{subgroup}.SBTable);
                end
            end
            this.loadingBar.devizualize(); 
        end
        
        function updateExperimentParamNameTable(this)
            originalParameterNames =  this.experiment.getTreatments();
            tableData = {originalParameterNames', this.experimentParamsNames'};
            set(this.experimentParamNameTable, 'data', tableData);
        end
        
        function convertDataToSBToolboxFormat(this, data, groups, channelNames, outputValue, exportMode)
            groupNames = this.experiment.getGroups();
            fastKinetics = this.experiment.getFastKinetics();
            for group = 1 : size(data, 2)
                for subgroup = this.subgroupStartValue : numel(data{group})
                    this.outputTableStruct{group}{subgroup}.success = 0;
                    
                    nameInfo = [outputValue,'_Group_',groupNames{group}, '_', this.subgroupNames{group}{subgroup}];
                    
                    noteInfo={'no user defined notes'};
                    componentNotes=[{'note for time'},{['note for ',outputValue]},{['note for ',outputValue,'+']},{['note for ',outputValue,'+']}];
                    components=[{'time'},{outputValue},{[outputValue,'+']},{[outputValue,'-']}];
                    %components=[{strcat('time/', this.timeController.getTimeUnit())},{outputValue},{[outputValue,'+']},{[outputValue,'-']}];
                    Header(4, 5) = {''};
                    Header(1, 1) = {'Name'};
                    Header(1, 2) = {nameInfo};
                    Header(2, 1) = {'Notes'};
                    Header(2, 2) = noteInfo;
                    Header(3, 1) = {'Componentnotes'};
                    Header(3, 2 : end) = componentNotes;
                    Header(4, 1) = {'Components'};
                    Header(4, 2 : end) = components;

                    numberOfCycles = this.timeController.getNumberOfCycles();
                    cyclesInUse = this.timeController.getCyclesInUse();
                    timeMoments = this.timeController.getCycleTimes();
                    %time = data{group}{subgroup}.timePoints;
                    %timepoints = numel(time);

                    experimentData(6,5) = {''};
                    
                    if isequal(exportMode, 'Merge')
                        row = 0;
                        numberOfRows = 0;
                        for timeIndex = 1 : numberOfCycles;
                            for subgroupElement = 1 : numel(this.groups{group}{subgroup})
                                numberOfRows = numberOfRows + 1;
                            end
                        end
                        experimentData = cell(numberOfRows, 5);
                        experimentData(1,1) = {'Values'};
                        for timeIndex = 1 : numberOfCycles; % for now, assume that all wells were measured for equal number of cycles
                             for subgroupElement = 1 : numel(this.groups{group}{subgroup})
                                row = row + 1;
                                experimentData{row, 2} = data{group}{subgroup}{subgroupElement}.timePoints(cyclesInUse(timeIndex));
                                experimentData{row, 3} = data{group}{subgroup}{subgroupElement}.average(cyclesInUse(timeIndex));
                                experimentData{row, 4} = data{group}{subgroup}{subgroupElement}.maximum(cyclesInUse(timeIndex));
                                experimentData{row, 5} = data{group}{subgroup}{subgroupElement}.minimum(cyclesInUse(timeIndex)); 
                             end
                        end
                    elseif isequal(exportMode, 'Average')
                        try
                            time = data{group}{subgroup}.timePoints;
                            timepoints = numel(time);
                            experimentData = cell(numberOfCycles, 5);
                            experimentData(1,1) = {'Values'};
                            for timeIndex = 1 : numberOfCycles
                                experimentData(timeIndex,2) = {time(cyclesInUse(timeIndex))};
                                experimentData(timeIndex,3) = {data{group}{subgroup}.average(cyclesInUse(timeIndex))};
                                experimentData(timeIndex,4) = {data{group}{subgroup}.maximum(cyclesInUse(timeIndex))};
                                experimentData(timeIndex,5) = {data{group}{subgroup}.minimum(cyclesInUse(timeIndex))};           
                            end
                        catch MException
                           disp(['Could not create table for group ', num2str(group),  ' ', this.subgroupNames{group}{subgroup}]);   
                        end
                    end
          
                    this.outputTableStruct{group}{subgroup}.SBTable = [Header;experimentData];
                    this.outputTableStruct{group}{subgroup}.path = [outputValue,'_Group_',groupNames{group}, '_', this.subgroupNames{group}{subgroup}];
                    if isequal(exportMode, 'Merge')
                        this.outputTableStruct{group}{subgroup}.initialConditions = data{group}{subgroup}{1}.initialConditions;
                    elseif isequal(exportMode, 'Average')
                        this.outputTableStruct{group}{subgroup}.initialConditions = data{group}{subgroup}.initialConditions;
                    end
                    this.outputTableStruct{group}{subgroup}.outputValue = outputValue;
                    this.outputTableStruct{group}{subgroup}.groups = groups;
                    this.outputTableStruct{group}{subgroup}.group = group;
                    this.outputTableStruct{group}{subgroup}.subgroup = subgroup;

                    this.outputTableStruct{group}{subgroup}.experimentParamsNames = this.experimentParamsNames;
                    this.outputTableStruct{group}{subgroup}.success = 1;       
                end
            end
        end 
        
        function handles = cellEditCallbackFunction(this, hObject, eventdata, handles, group, subgroup)
           data = get(hObject, 'data');
           if (isequal(eventdata.Indices(1), 3) && eventdata.Indices(2)>1 ) || ( isequal(eventdata.Indices(1), 2) && isequal(eventdata.Indices(2), 2))...
                   || ( isequal(eventdata.Indices(1), 1) && isequal(eventdata.Indices(2), 2))
           
               this.outputTableStruct{group}{subgroup}.SBTable = data;
           else
               data{eventdata.Indices(1), eventdata.Indices(2)} = eventdata.PreviousData;
               set(hObject, 'data', data);
               this.outputTableStruct{group}{subgroup}.SBTable = data;
           end
        end 
        
        function sendToWorkspace(this)
            assignin('base', 'SBStructure', this.outputTableStruct);
        end
    end
end